import tornado.ioloop
import tornado.web
import json
import operator
import boto3


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
dynamodb_client = boto3.resource('dynamodb') 

def lambda_handler(event, context):
    print(event)
    graph = Graph()
    table = dynamodb_client.Table('user')
    tmp = table.scan()
    dict1 = {}
    for item in tmp['Items']:
        dict1[item['UID']] = []
        pair = (item['firstName'], item['lastName'], item['pic_url'])
        dict1[item['UID']].append(pair)
        
    print(dict1)
    remoteConn = DriverRemoteConnection('ws://neptunedbinstance-3f8bwqre3vsy.cft44vxyghsh.us-east-1.neptune.amazonaws.com:8182/gremlin','g')
    g = graph.traversal().withRemote(remoteConn)
    # a=g.V().hasLabel('User').has('uid', '1834389').next()
    # b=g.V().hasLabel('User').has('uid', '594112').next()
    # g.V(a).addE('Friend').to(b).iterate()
    key = event["userId"]
    friends= g.V().hasLabel('User').has('uid', key).\
             both('FRIEND').aggregate('friends'). \
             valueMap().toList()
    list2 = []
    for item in friends:
        tmplist=[]
        uid = item["uid"]
        tmplist.append(uid[0])
        for tmp in dict1[uid[0]][0]:
            tmplist.append(tmp)
        list2.append(tmplist)
    return {
        'statusCode': 200,
        'body': list2
    }
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
            if(count == 3):
                break
    print(list1)
    remoteConn.close()
    # TODO implement
    return {
        'statusCode': 200,
        'body': list1
    }

