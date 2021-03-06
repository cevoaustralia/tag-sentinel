COLLECTOR_STACK	?= ec2-region-sentinel
REGIONS		:= $(shell aws ec2 describe-regions --query 'Regions[].RegionName' --output text )
TARGET_REGIONS	:= $(addprefix region., $(REGIONS))
ACCOUNT		:= $(shell aws iam list-account-aliases --query 'AccountAliases[]' --output text )
SOURCE_BUCKET 	?= sentinel-$(ACCOUNT)
LAMBDA_REGION	?= ap-southeast-2
LAMBDA_STACK	?= ec2-process-messages
ZIPFILE		:= sentinel_ec2_processor
ZIPDIR		:= lambda
REV		:= $(shell git log -1 --pretty=format:%h)

.PHONY: deploy deploysentinel createBucket getconfig zip $(REGIONS) $(TARGET_REGIONS)

all:
	@echo "make deploy: Create or update the CloudFormation stack"

zip:
	$(MAKE) -C lambda $@

getconfig:
	aws s3 cp s3://$(SOURCE_BUCKET)/config/config-sentinel.json lambda/config-sentinel.json

uploadLambda: getconfig zip
	aws s3 cp lambda/$(ZIPFILE).zip s3://$(SOURCE_BUCKET)/$(ZIPDIR)/$(ZIPFILE)-$(REV).zip

deploylambda: uploadLambda
	AWS_DEFAULT_REGION=$(LAMBDA_REGION) ./deploy_lambda_stack.sh $(LAMBDA_STACK) $(SOURCE_BUCKET) $(ZIPDIR)/$(ZIPFILE)-$(REV).zip

deploy: deploysentinel

deploysentinel: $(TARGET_REGIONS)

$(TARGET_REGIONS): region.%: %
	AWS_DEFAULT_REGION=$< ./deploy_sentinel_stack.sh $(COLLECTOR_STACK)
