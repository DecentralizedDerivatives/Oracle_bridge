# Oracle bridge

![Photocoin](./public/bridge.jpeg)

#Contracts

##Bridge Contracts

###Structure

###General

###Setup
Start the mainchain at 9545
Open Ethereum Bridge on mainchain
Create contract with OARAddress

Start the childchain at 8545
Open Ethereum Bridge on childchain
Create contract with OARAddress

###Functions and Variables 

###Walkthrouh


#### Notes:

All contracts are created by the Decentralized Derivatives Association

Contracts are currently in development and should not be used for real value

## Testing
```
truffle compile
truffle develop
test
```

Further testing runs (with no contract changes) only require `truffle test`.

Should you make any changes to the contract files, make sure you `rm -rf build` before running `truffle compile && truffle test`.