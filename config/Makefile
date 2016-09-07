BUCKET_REGION ?= ap-southeast-2
EDITOR ?= vim
REV=$(shell git log -1 --pretty=format:%h)
ACCOUNT=$(shell aws iam list-account-aliases --query 'AccountAliases[]' --output text )
SOURCE_BUCKET ?= sentinel-$(ACCOUNT)

.PHONY: config getconfig createBucket

createBucket:
	aws s3 mb s3://$(SOURCE_BUCKET) --region $(BUCKET_REGION)
	aws s3api put-bucket-versioning --bucket $(SOURCE_BUCKET) --versioning-configuration Status=Enabled

getconfig:
	aws s3 cp s3://$(SOURCE_BUCKET)/config/config-sentinel.json config-sentinel.json

config:
	aws s3 cp s3://$(SOURCE_BUCKET)/config/config-sentinel.json config-sentinel.json || cp config-sentinel-sample.json config-sentinel.json
	$(EDITOR) config-sentinel.json < /dev/tty > /dev/tty
	read -p "Upload sentinel configuration to S3 [Y/n]: " upload ; [ "$${upload:0:1}" != "n" ] && \
					 aws s3 cp config-sentinel.json s3://$(SOURCE_BUCKET)/config/ || \
		true
