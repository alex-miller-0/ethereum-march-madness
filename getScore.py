import sys
import requests
import json
from contract import getCheckTx

def main(addr):
    print addr
    res = req(addr)

def req(addr):
    contract_addr = '0x0'
    url = 'http://localhost:8545'
    headers = {'content-type': 'application/json'}
    data = {
        "method": "eth_call",
        "jsonrpc": "2.0",
        "params": [{ "to": contract_addr, "data": getCheckTx(addr)}],
        "id": 1
    }
    response = requests.post(url, data=json.dumps(data), headers=headers).json()
    print(response)
    return response

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print 'Please include your address, e.g. python getScore.py 0x...A'
    main(sys.argv[2])
