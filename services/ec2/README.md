# Tag-Sentinel - EC2 Instances
Verify if your EC2 instances comply with tagging policies, if an instance belongs to an ASG, it will be excluded. This module contains these stacks :

- **Sentinel stack**

  - Cloudwatch event rules to detect creation of new EC2 instances, events can be controlled in [this json file](cfstack/cw_eventRules.json)
  - SQS to push the previous events in form of messages to be processed later

EC2 Sentinels are deployed in all supported regions by default:

Run the make task to deploy to all regions

`make deploy`

If you want tag-sentinel to work in only one region you can pass the REGIONS variable as a parameter

`make deploy REGIONS=ap-southeast-2`
