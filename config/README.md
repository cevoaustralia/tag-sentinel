# Configuration Module
This should be the first module to be deployed, it is easy to configure, you just have to get familiar with the sample [configuration file](config-sentinel-sample.json).

# Dependencies
  - Vim editor
# Deployment

  - The first time you deploy this module need to create the s3 bucket, such bucket will be used to store the configuration file and also to deploy the lambda functions, to do so just execute this make:

    ```make createBucket```

  - The next command will create (will rename the sample configuration file to the real name for you) or retrieve the configuration file from s3, it will also prompt you so you can start making changes, when you save changes will ask if you want to upload the file back to s3 :

    ```make config```

  - If you only want to download the configuration file (provided you have uploaded it before) you can use :

    ```make getconfig```

# The configuration file explained

  The parameters in the [config sample file](config-sentinel-sample.json) are :

  ```
  {
    "general" : {
      "logging-level" : "WARNING",
      "sns-topic-name" : "SentinelSNSTopic",
    },
    "ec2" : {
      "warning-only" : false,
      "action"  : "stop",
      "queue-name" : "SentinelEC2EventQueue",
      "tags-to-watch" : ["application"],
      "pending-deletiong-tag" : "sentinel-pending-deletion",
      "report-tags" : [
        "Name", "aws:cloudformation:stack-name"
      ],
    },

    "slackNotifications" : {
      "endpoint": "your-slack-endpoint",
      "channel": "#select-channel",
      "botname": "Cevo-Sentinel",
      "emoji": ":police_car:"
    }
  }
```

## general

Parameter | Description | Possible values
--- | --- | ---
sns-topic-name | The SNS topic name once the notification module has been deployed | Name not ARN
logging-level | Specifies the minimum level of logging for lambda functions (python style)| CRITICAL, ERROR, WARNING, INFO, DEBUG, NOTSET

## ec2
Parameter | Description | Possible values
--- | --- | ---
warning-only | Specifies if tag-sentinel should take any action on untagged resources or just want to send a friendly warning. | true,false
action | The action to perform on untagged ec2 instances when warning-only is disabled (false), resources other than ec2 instances have default actions in their respective modules | stop, terminate
queue-name | The name of the queue created when deploying the ec2 module | -
tags-to-watch | the list of tags to watch on ec2 resources| Comma separated list
pending-deletiong-tag | The key of the tag that tag-sentinel uses to mark instances before it evaluates the existence of the watched tags | The tag name (string)
report-tags | List of tags to be searched by tag-sentinel to be included in the notification messages | -

## slackNotifications
Specifies slack channel endpoint that will be used by a lambda function as a topic subscriber
