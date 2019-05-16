import os
import sys
import logging
import time
from azure.eventhub import EventHubClient, Receiver, Offset

"""
SET VARIABLES
"""

##EVENT HUB DETAILS
ADDRESS = 'amqps://eventhubsnamespace/eventhub'
USER = "SharedAccessPolicyName"
KEY = "SharedAccessPolicyKey"


CONSUMER_GROUP = "$default"
OFFSET = Offset("-1")
PARTITION = "0"

##COUNTER
total = 0

"""
PROCESS DATA
"""

##SET CLIENT
client = EventHubClient(ADDRESS, debug=False, username=USER, password=KEY)

##PROCESS QUEUED DATA
try:
    receiver = client.add_receiver(CONSUMER_GROUP, PARTITION, prefetch=5000)
    client.run()
    start_time = time.time()
    for event_data in receiver.receive(timeout=100):
        jsonstring = event_data.body_as_json()
        devicename = jsonstring['device']
        reading = jsonstring['reading']
        print(f"Device: {devicename} | Reading: {reading}")
        total += 1

    end_time = time.time()
    client.stop()
    run_time = end_time - start_time
    print("Received {} messages in {} seconds".format(total, run_time))

except KeyboardInterrupt:
    pass
finally:
    client.stop()