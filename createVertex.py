import os
import random
import csv
import uuid
import requests
import json



with open('data.json', 'r') as outfile:
    answer = json.load(outfile)
list1 = []
for item in answer:
    list1.append(item["id"])
file1 = open("vertex.text","w")
file1.writelines("g.\n")
count = 0
for item in answer:
    #print(first_names[firstR],last_names[LastR])
    
    str = ".addV('User').property('uid', '" + item["id"] + "')\n"
    file1.writelines(str)
    count += 1
list = []
for i in range(1000):
    person1 = random.randint(0,100-1)
    person2 = random.randint(0,100-1)
    while(person1 == person2):
        person2 = random.randint(0,100-1)
    
    while( ((person1, person2) in list) or ((person2, person1) in list)):
        person1 = random.randint(0,100-1)
        person2 = random.randint(0,100-1)
        while(person1 == person2):
               person2 = random.randint(0,100-1)
    pair = (person1, person2)
    list.append(pair)
    str="a=g.V().hasLabel('User').has('uid', '"+list1[person1] + "').next()\n"
    file1.writelines(str)
    str="b=g.V().hasLabel('User').has('uid', '"+list1[person2] + "').next()\n"
    file1.writelines(str)
    str="g.V(a).addE('FRIEND').to(b).iterate()\n"
    file1.writelines(str)
file1.close()
