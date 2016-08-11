#!/bin/bash

if [ $# -ne 1 ]; then
    echo $#
    echo "usage: $0 <stack>"
    exit 1
fi

STACK=$1

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
    log "Creating stack $STACK"
    local OUT=$( aws cloudformation create-stack \
        --stack-name $STACK \
        --capabilities CAPABILITY_IAM \
        --template-body file://cfstack/$STACK.json
    )
    wait_completion $STACK || return 1
}

update_stack () {
    local STACK=$1
    log "Updating stack $STACK"
    local OUT=$( aws cloudformation update-stack \
        --stack-name $STACK \
        --capabilities CAPABILITY_IAM \
        --template-body file://cfstack/$STACK.json
    )
    wait_completion $STACK $LAMBDA_REGION || return 1
}

describe_stack_output() {
  local STACK=$1
  local OUTPUTKEY=$2
  log "Querying specific output $OUTPUTKEY on stack $STACK "
  QUEUE=$( aws cloudformation describe-stacks \
        --stack-name $STACK \
        --query Stacks[*].Outputs[?Key==$OUTPUTKEY].OutputValue \
        --output text
  )
  return $?
}

# Rule has to be created using the cli as cloudformation template still does not support it in all regions.
createEventRule() {
  local STACK=$1
  describe_stack_output $STACK "QueueARN" || die "Can't query stack"
  log "Creating event rule using the cli as cloudformation does not support it in all regions yet..."
  local RULE=$( aws events put-rule \
      --name SentinelEC2EventRule \
      --event-pattern file://cfstack/cw_eventRules.json
  )
  return $?
}

addTargetToRule() {
  log "Adding target to event rule"
  local TARGET=$( aws events put-targets \
      --rule SentinelEC2EventRule \
      --targets "{ \"Id\" : \"sentinel-ec2-queuetarget\", \"Arn\" : \"$QUEUE\" }"
  )
  return $?
}
# Create the stack
if [ -z "$( aws cloudformation describe-stacks --stack-name $STACK 2>/dev/null )" ]; then
    create_stack $STACK || die "Can't create stack"
else
    update_stack $STACK || die "Can't update stack"
fi

# Create event rule
createEventRule $STACK || die "Can't create event rule"
addTargetToRule || die "Can't add target to event rule"

log "Complete"
