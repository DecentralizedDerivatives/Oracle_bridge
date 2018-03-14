# Oracle bridge

![Bridge](./public/bridge.jpg)

## General

The Oracle bridge is a simple implementation for linking two EVM chains using 'Oraclize', a data transport layer for connecting API's to our contracts.  

To code allows for parties to lock Ether and tokens on another EVM chain by bridging the chains.  The chains can read the activity on the other chain through API's of two hosted nodes (Infura style).  

The two chains can both be fully public EVM's, and the trust is distributed to the parties hosting the nodes linked in the smart contract.  

## Contracts

### Mainchain
	
#### The Bridge Contract

### Dappchain

#### The Bridge Contract

#### DDA Factory Contract

#### Decentralized Exchange Contract


## Setup

	Start the mainchain at 9545
	Open Ethereum Bridge on mainchain
	Create contract with OARAddress

	Start the dapp chain at 8545
	Open Ethereum Bridge on dapp chain
	Create contract with OARAddress

## Structure

Note - all Ether should be wrapped (just do tokens)

### Variables

    Bridge.sol
        uint lastUpdatedTime; // last succesful Oraclize callback
        uint releasePeriod; //if no Oraclize callback in this period, then all parties can withdraw ETH, (long time frame, e.g. 1 month)


### Functions
    
    Bridge.sol
        deposit() // sends money to the contract
        withdraw() // pull money from contract that is not locked
        lockToken() //lock Ether on the other chain
           This has to be for certain number of blocks/time

        requestUnlock() //sends Oraclize call to other chain
        _callback() //call from Oraclize that unlocks Ether from requested parties



### Walkthrouh


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