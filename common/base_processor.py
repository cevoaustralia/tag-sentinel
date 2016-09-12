#!/usr/bin/env python
# vim: set tabstop=2 shiftwidth=2 expandtab:
import os
import boto3
import json
from botocore import exceptions
import logging
import abc
import sys

class base_processor(object) :
    __metaclass__ = abc.ABCMeta

    def __init__(self) :
        if not "general" in self.config :
            self.config = self.get_config()
        #Get region where lambda is running
        self.sns_region = os.getenv('AWS_DEFAULT_REGION')

    def get_config(self):
        """
        load tag-sentinel configuration
        """
        try :
            return json.loads( (open ('config-sentinel.json').read() ) )
        except Exception as e:
            logging.critical(e)

    def all_regions(self):
        """
        Get a generator with all the available aws regions
        """
        ec2 = boto3.client("ec2")
        regions = ec2.describe_regions()
        for region in regions['Regions']:
            yield region['RegionName']

    def receive_messages(self, sqs, url):
        """
        Receive messages from SQS
        """
        msgs = sqs.receive_message(
            QueueUrl=url,
            MaxNumberOfMessages=10,
            WaitTimeSeconds=2
        )
        try :
            for msg in msgs['Messages']:
                struct = {
                    "Body": msg['Body'],
                    "ReceiptHandle": msg['ReceiptHandle'],
                    "Url": url,
                }
                yield struct
        except Exception as e:
            logging.warning(e)

    def get_messages_from_region(self, region, queueName):
        """
        Get sqs messages for a partirular region
        """
        logging.info("Checking region " + region)
        sqs = boto3.client("sqs", region_name=region)
        try:
            qurl = sqs.get_queue_url(QueueName=queueName)
        except:
            logging.warning("No queue in " + region)
            return

        url = qurl['QueueUrl']
        visible = sqs.get_queue_attributes(
            QueueUrl=url,
            AttributeNames=['ApproximateNumberOfMessages']
        )

        logging.info("Queue on region "+ region + " has " + visible['Attributes']['ApproximateNumberOfMessages'] + " messages visible")

        if int(visible['Attributes']['ApproximateNumberOfMessages']) > 0:
            index = 1
            theMessages = {}
            #Call receive_messages for every message due to the way short polling works, see more at
            #http://boto3.readthedocs.io/en/latest/reference/services/sqs.html#SQS.Client.receive_message
            while ( index <= int(visible['Attributes']['ApproximateNumberOfMessages']) ):
                for msg in self.receive_messages(sqs, url):
                    msg['Region'] = region
                    msg['Client'] = sqs
                    theMessages[index] = msg
                    index+=1
            return theMessages

    def get_messages(self, queueName):
        """
        Get sqs messages for all regions
        """
        regionMessages = {}
        for region in self.all_regions():
            theMessages = self.get_messages_from_region(region, queueName)
            if theMessages is None :
                continue
            regionMessages[region] = theMessages
        return regionMessages

    def delete_message(self, msg):
        """
        Delete message from queue
        """
        # print "Deleting uninteresting message: " + msg['Body']
        sqs = msg['Client']
        try:
            resp = sqs.delete_message(
                QueueUrl=msg['Url'],
                ReceiptHandle=msg['ReceiptHandle']
            )
            logging.info("Got response from deleting message: " + str(resp))
        except Exception as e:
            logging.warning("Can't delete message: " + msg['Body'])
            logging.warning(e)

    @abc.abstractmethod
    def get_interesting_messages(self):
        """
        Concrete classes will filter messages relevant to a particular service
        """
        return

    def notify(self, message):
        """
        Publish message to sns topic
        """

        logging.info("Publishing to sns will be implemented here ")

    @abc.abstractmethod
    def tag_or_delete(self, context, message):
        """
        Concrete classes will implement rules to tag or delete
        """
        return

    def config_logging(self):
        """
        Configure logging level and format
        """
        #Setting up logging level according to enforce-o-tron's json configuration
        logging.getLogger().setLevel(self.config.get("general").get("logging-level"))
        #Give logging some format love
        logging.basicConfig(format="[%(asctime)s] %(levelname)s : %(message)s")
