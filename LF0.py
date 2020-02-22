import tornado.ioloop
import tornado.web
import json

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


def lambda_handler(event, context):
    graph = Graph()
    uid1 = event["userId1"] 
    uid2 = event["userId2"]

    remoteConn = DriverRemoteConnection('ws://neptunedbinstance-3f8bwqre3vsy.cft44vxyghsh.us-east-1.neptune.amazonaws.com:8182/gremlin','g')
    g = graph.traversal().withRemote(remoteConn)
    friends= g.V().hasLabel('User').has('uid', uid1).\
             both('FRIEND').aggregate('friends'). \
             valueMap().toList()
    list2 = []
    for item in friends:
        uid = item["uid"]
        list2.append(uid[0])
    if uid2 in list2:
        return {
            'statusCode': 400
        }
    a=g.V().hasLabel('User').has('uid', uid1).next()
    b=g.V().hasLabel('User').has('uid', uid2).next()
   
    g.V(a).addE('FRIEND').to(b).iterate()
    remoteConn.close()
    # TODO implement
    return {
        'statusCode': 200
    }

