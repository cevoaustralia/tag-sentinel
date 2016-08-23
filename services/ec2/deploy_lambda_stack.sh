#!/bin/bash

if [ $# -ne 3 ]; then
    echo $#
    echo "usage: $0 <stack> <config-bucket> <zipfile>"
    exit 1
fi

STACK=$1
BUCKET=$2
ZIPFILE=$3

log () {
    date "+%Y-%m-%d %H:%M:%S $1"
}

die () {
    echo "FATAL: $1"
    exit 1
}

wait_completion () {
    local STACK=$1
    echo -n "Waiting for stack $STACK to complete:"
    while true; do
        local STATUS=$( aws cloudformation describe-stack-events \
            --stack-name $STACK \
            --query 'StackEvents[].{x: ResourceStatus, y: ResourceType}' \
            --output text | \
            grep "AWS::CloudFormation::Stack" | head -n 1 | awk '{ print $1 }'
        )
        case $STATUS in
            UPDATE_COMPLETE_CLEANUP_IN_PROGRESS)    : ;;
            UPDATE_COMPLETE|CREATE_COMPLETE)
                echo "stack $STACK complete"
                return 0 ;;
            *ROLLBACK*)
                echo "stack $STACK rolling back"
                return 1 ;;
            FAILED)
                echo "ERROR updating stack"
                return 1 ;;
            "")
                echo "No output while looking for stack completion"
                return 1 ;;
            *) : ;;
        esac
        echo -n "."
        sleep 5
    done
}

create_stack () {
    local STACK=$1
    local BUCKET=$2
    log "Creating stack $STACK"
    local OUT=$( aws cloudformation create-stack \
        --stack-name $STACK \
        --capabilities CAPABILITY_IAM \
        --template-body file://cfstack/$STACK.json \
        --parameters \
            "ParameterKey=SentinelEC2SourceBucket,ParameterValue=$BUCKET" \
            "ParameterKey=SentinelEC2SourceKey,ParameterValue=$ZIPFILE"
    )
    wait_completion $STACK || return 1
}

update_stack () {
    local STACK=$1
    local BUCKET=$2
    log "Updating stack $STACK"
    local OUT=$( aws cloudformation update-stack \
        --stack-name $STACK \
        --capabilities CAPABILITY_IAM \
        --template-body file://cloudformation/$STACK.json \
        --parameters \
            "ParameterKey=SentinelEC2SourceBucket,ParameterValue=$BUCKET" \
            "ParameterKey=SentinelEC2SourceKey,ParameterValue=$ZIPFILE"
    )
    wait_completion $STACK $LAMBDA_REGION || return 1
}

# Create the stack
if [ -z "$( aws cloudformation describe-stacks --stack-name $STACK 2>/dev/null )" ]; then
    create_stack $STACK $BUCKET || die "Can't create stack"
else
    update_stack $STACK $BUCKET || die "Can't update stack"
fi

log "Complete"
