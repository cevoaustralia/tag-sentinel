COLLECTOR_STACK	?= ec2-region-sentinel
REGIONS		:= $(shell aws ec2 describe-regions --query 'Regions[].RegionName' --output text )
TARGET_REGIONS	:= $(addprefix region., $(REGIONS))

.PHONY: deploy deploysentinel $(REGIONS) $(TARGET_REGIONS)

all:
	@echo "make deploy: Create or update the CloudFormation stack"

zip:
	$(MAKE) -C lambda $@

deploy: deploysentinel

deploysentinel: $(TARGET_REGIONS)

$(TARGET_REGIONS): region.%: %
	AWS_DEFAULT_REGION=$< ./deploy_sentinel_stack.sh $(COLLECTOR_STACK)
