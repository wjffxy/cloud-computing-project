import os
import random
import csv
import uuid
import boto3

import requests
import json

dynamodb = boto3.resource('dynamodb', region_name='us-east-1', endpoint_url="https://dynamodb-fips.us-east-1.amazonaws.com")



table = dynamodb.Table('user')

with open('data.json') as readfile:
    answer = json.load(readfile)

count = 0
list = []
for item in answer:
    if item['id'] in list:
        print(item['id'])
    list.append(item['id'])
    table.put_item(
        Item={
        'UID': item['id'],
        'firstName': item['firstName'],
        'lastName': item['lastName'],
        'pic_url':item['photoUrl']
        }
    )
    count +=1
    
print(count)
