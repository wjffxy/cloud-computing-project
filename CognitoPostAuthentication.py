import json
import boto3
import random

dynamodb_client = boto3.resource('dynamodb') 
dynamodb = boto3.client('dynamodb') 
def lambda_handler(event, context):
    # return {
    #     'statusCode': 200,
    #     'body': event
    # }
    personname = event["userName"]
    table = dynamodb_client.Table('useridentity')
    tmp = table.scan()
    personname_list = []
    dict1 = {}
    print(personname)
    for item in tmp['Items']:
        dict1[item['personname']] = item['UID']
        personname_list.append(item['personname'])
    if  personname in personname_list:
        return {
            'statusCode': 200,
            'body': dict1[personname]
        }
