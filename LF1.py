import tornado.ioloop
import tornado.web
import json
import operator
import boto3
import os


from gremlin_python.process.graph_traversal import GraphTraversal
from gremlin_python.process.graph_traversal import GraphTraversalSource
from gremlin_python.process.graph_traversal import __
from gremlin_python.process.traversal import Operator

from gremlin_python.process.traversal import Bytecode
from gremlin_python.process.traversal import Bindings
from gremlin_python.process.traversal import P

# in practice, you really only need the 3 imports below

from gremlin_python import statics
from gremlin_python.structure.graph import Graph
from gremlin_python.driver.driver_remote_connection import DriverRemoteConnection
dynamodb = boto3.client('dynamodb') 
ClassDict = {
    "Company" : 1, 
    "EducationalInstitution" : 2,
    "Artist" : 3,
    "Athlete" : 4,
    "OfficeHolder" : 5,
    "MeanOfTransportation": 6 
}

def lambda_handler(event, context):
    graph = Graph()

    remoteConn = DriverRemoteConnection('ws://neptunedbinstance-3f8bwqre3vsy.cft44vxyghsh.us-east-1.neptune.amazonaws.com:8182/gremlin','g')
    g = graph.traversal().withRemote(remoteConn)
    # a=g.V().hasLabel('User').has('uid', '1834389').next()
    # b=g.V().hasLabel('User').has('uid', '594112').next()
    # g.V(a).addE('Friend').to(b).iterate()
    key = event["userId"]
    recommend = g.V().hasLabel('User').has('uid', key).\
                 both('FRIEND').aggregate('friends'). \
                 both('FRIEND'). \
                 where(P.without('friends')). \
                 groupCount().by('uid'). \
                 next()
    friends= g.V().hasLabel('User').has('uid', key).\
             both('FRIEND').aggregate('friends'). \
             valueMap().toList()
    print(friends)
    count = 0
    recommend_list = {k: v for k, v in sorted(recommend.items(), key=lambda item: - item[1])}
    list1 = []
    for item in recommend_list:
        if item != key:
            data=dynamodb.get_item(TableName='user', 
                                      Key={ 'UID':{ 'S': str(item)}}
            )
            pair = (str(item), data['Item']['firstName']['S'],data['Item']['lastName']['S'],data['Item']['pic_url']['S'])
            list1.append(pair)
            count += 1
            if(count == 10):
                break
    prediction(key)
    print(list1)
    remoteConn.close()
    return {
        'statusCode': 200,
        'body': list1
    }
    


def prediction(uid):
    runtime= boto3.client('runtime.sagemaker')
    item = dynamodb.get_item(
        TableName='user',
        Key = {
            "UID" : {
                "S" : uid
            }
        }
    )
    
    payload = {
        "instances":[item["Item"]["Profile"]["S"]]
    }
    print(json.dumps(payload))
    
    response = runtime.invoke_endpoint(EndpointName='blazingtext-2019-12-20-12-10-01-280',
                                      ContentType='application/json',
                                      Body=json.dumps(payload))
    result = json.loads(response['Body'].read().decode())[0]["label"][0][9:]
    
    return result
