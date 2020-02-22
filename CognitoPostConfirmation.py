import json
import boto3
import random

dynamodb_client = boto3.resource('dynamodb') 
dynamodb = boto3.client('dynamodb') 

def lambda_handler(event, context):
    print(event)
    personname = event["userName"]
    table = dynamodb_client.Table('user')
    tmp = table.scan()
    uid_list = []
    for item in tmp['Items']:
        uid_list.append(item['UID'])
    index = random.randint(0,len(uid_list)-1)
    print(index)
    data = dynamodb.query(
        ExpressionAttributeValues= {
            ':s': {'S': str(uid_list[index])}
            
        },
        KeyConditionExpression= 'UID = :s',
        ProjectionExpression= 'UID',
        TableName= 'useridentity'
    )
    print(data)
    while(True):
        if len(data['Items']) == 0:
            break
        index = random.randint(0,len(uid_list)-1)
        data = dynamodb.query(
            ExpressionAttributeValues= {
                ':s': {'S': str(uid_list[index])}
                
            },
            KeyConditionExpression= 'UID = :s',
            ProjectionExpression= 'UID',
            TableName= 'useridentity'
        )
    item = {'UID': {'S': str(uid_list[index])},
            'personname': {'S': str(personname)}
              }
    dynamodb.put_item(TableName='useridentity', Item=item)
    return {
        'statusCode': 200,
        'body': uid_list[index]
    }
