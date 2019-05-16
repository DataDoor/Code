import sys
import logging
import datetime
import time
import os
import random
import json
from azure.eventhub import EventHubClient, Sender, EventData

"""
SET VARIABLES
"""

##EVENT HUB DETAILS
ADDRESS = 'amqps://eventhubsnamespace/eventhub'
USER = "SharedAccessPolicyName"
KEY = "SharedAccessPolicyKey"


try:
    if not ADDRESS:
        raise ValueError("No EventHubs URL supplied.")

    ##Create Event Hubs client
    client = EventHubClient(ADDRESS, debug=False, username=USER, password=KEY)
    sender = client.add_sender(partition="0")
    client.run()
    try:
        start_time = time.time()
        #while 1==1:
        for i in range(100):
            devicenumber = random.randint(1,1000)
            readingnumber = random.random()
            print(f"Device: {devicenumber}, Reading: {readingnumber}")
            eventjson= json.dumps({'device': devicenumber, 'reading': readingnumber})
            sender.send(EventData(str(eventjson)))
    except:
        raise
    finally:
        end_time = time.time()
        client.stop()
        run_time = end_time - start_time
        logger.info("Runtime: {} seconds".format(run_time))

except KeyboardInterrupt:
    pass