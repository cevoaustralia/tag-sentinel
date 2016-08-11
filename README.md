# tag-sentinel - WIP
Serverless tag policy tool

## Overview
As your AWS accounts/users grow you need to be able to generate reports around your resource utilization, that is one of the main reasons amazon provides the ability to add Tags to your resources so that you can identify whatever you need and build amazing reports for cost optimization.

Many of our customers ask us about solutions to make sure resources in AWS are propery tagged with the ability to terminate/delete them, or just notify someone if they don't comply with tagging policies that many companies today have in place.

There are a couple of solutions already in place, we decided to build and open source sentinel because it is configurable and you dont need to provision any ec2 instances to run it as it uses these awesome AWS services :

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

## Installation
This tool has been designed to add AWS resources as modules, so that they can be provisioned in separate, for example if you want sentinel to verify tag policies on RDS instances then there will be an RDS module. This is the list of supported modules

- [EC2 instances](services/ec2)
