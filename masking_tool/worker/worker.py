from backend_client import BackendClient
import time
import sys


backend_client = BackendClient()

while True:
    job = None

    try:
        job = backend_client.fetch_next_job()
    except:
        print('Error while fetching next job')
        pass

    if job is None:
        print('No suitable job found')
    else:
        print('Start working on job ' + job['id'])

    # @todo work on job ...

    sys.stdout.flush()  # Flush log output
    time.sleep(10)  #


