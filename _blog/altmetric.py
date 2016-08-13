import hashlib
import os
import json
import requests
import time

def altmetric(query, version='v1', refresh=False, throttle=1):
    """Return dictionary of altmetric data for query.
    query is a string like: doi/10.1007/s00799-016-0173-7

    Results are cached in ~/.altmetric_data, unless refresh is True.
    throttle is a delay in seconds to avoid too many requests too fast.

    see http://api.altmetric.com

    """
    m = hashlib.md5()
    
    url = 'http://api.altmetric.com/' + version + '/' + query
    m.update(url.encode('utf-8'))
    md5 = m.hexdigest()

    datafile = os.path.join('/Users/jkitchin/.altmetric_data', md5)

    if os.path.exists(datafile) and not refresh:
        with open(datafile) as f:
            results = json.loads(f.read())
    else:
        req = requests.get(url)
        if req.status_code != 404:
            results = req.json()
        else:
            results = {}
        with open(datafile, 'w') as f:
            f.write(json.dumps(results))
        if throttle:
            time.sleep(throttle)  # throttle how many requests we make.

    return results
