# tag-sentinel - WIP
Serverless tag policy tool

# Overview

This tool uses a set of AWS services :
- Cloudwatch events : to detect a series of supported events on AWS api calls, also to trigger targets in a scheduled fashion
- SQS : to add events in json format for later processing
- SNS : to push messages and add subscribers as you need for notifications
- Lambda : To process messages sent to SQS and also to implement slack notifications as a subscriber of the SNS

## Dependencies
- ##### Deployment
  - Tested on multiple linux flavours
  - [Make](https://www.gnu.org/software/make/)
  - [AWS Cli](https://aws.amazon.com/cli/)

- ##### Running lambda functions locally
  - `pip to be added..`

## How to install
This tool has been designed to add AWS resources as modules, so that they can be provisioned in separate, for example if you want sentinel to verify tag policies on RDS instances then there will be an RDS module. This is the list of supported modules

- [EC2 instances](services/ec2)
