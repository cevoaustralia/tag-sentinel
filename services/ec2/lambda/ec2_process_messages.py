import os
import boto3
from botocore import exceptions
import logging
import abc
import sys
import json
#When testing lambda locally
sys.path.append('../../../common')
from base_processor import base_processor

class ec2_process_messages(base_processor) :
    """
    Concrete class to process SQS messages for EC2 instances
    """
    def __init__(self):
        self.config = {}
        self.sns_region = None
        #Initialize parent class
        super(ec2_process_messages,self).__init__()

    def get_interesting_messages(self):
        logging.info("Get relevant messages to be implemented here")

    def tag_or_delete(self):
        logging.info("Tag or delete to be implemented here")

def lambda_handler(event, context):
    """
    Handler to be invoked from aws lambda
    """
    processor = ec2_process_messages()
    processor.config_logging()
    
    logging.info("event: " + json.dumps(event))

if __name__ == "__main__":
    lambda_handler({}, {})
