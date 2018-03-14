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
        recieveToken() //sends Oraclize call to other chain to see if they locked something for this chain
        _callback() //call from Oraclize that unlocks Ether from requested parties
        setBridge() //allows you to put in the name of the bridge
        // This is the hosted api of the other node.  If you are on local host, it looks like this:, but if you want to connect to the mainnet, you would use Infura and it looks like this:



### Walkthrough



### Centralization and other concerns

Rather than be reliant on a POA network or trusted relayers to do the work, the trust in this mechanism is placed on the party hosting the API and the Oraclize service.  It's a different form of trust than relying on a centralized party to validate all transactions and with the use of trusted hardware and other incentive mechanisms for the hosts, this solution provides a method that is easy to deploy, easy to understand, and very close to the true goal of complete trustlessness.  

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