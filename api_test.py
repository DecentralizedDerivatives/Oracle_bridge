import requests,json

'''Test'''
url = "https://api.bitfinex.com/v1/pubticker/ETHUSD"
response = requests.request("GET", url)
price = response.json()['last_price'] 
print(price)

'''How to get it from the real infura api
https://api.infura.io/v1/jsonrpc/network/method[eth_call
https://ethereum.stackexchange.com/questions/3514/how-to-call-a-contract-method-using-the-eth-call-json-rpc-api
'''
url = "https://api.infura.io/v1"
payload =  {"jsonrpc":"2.0","id":1,"method":"eth_blockNumber","params":[]}
response = requests.request("POST", url,data=payload, verify=False, timeout=60)
print(response)
x = response.json()
print(x)