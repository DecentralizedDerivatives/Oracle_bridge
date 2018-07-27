pragma solidity ^0.4.21;

import "./libraries/SafeMath.sol";

/**
* This is the basic wrapped Ether contract. 
* All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
*/
contract MinerRewarder{

  using SafeMath for uint256;

  /*
  Parties submit block headers  and a block number from the other chain
  --We then verify that their address is in there (they were the miner)
  --Then call oracle which will match the hash of their block header with the blockhash on the other chain
  
  Issues:
  Parties have to submit block for block? Can you submit multiple?
  Still relies on a central API...what happens if they provide real chain but bad API?
  I guess we could use Proof-of-Work oracle, but then what are the incentives?
  */

    struct Details{
        string API;
        string enode;
        address owner;
        uint balance;
        uint reward;
    }
    
  mapping(uint => Details) sidechains;
  uint[] chain_ids;
  mapping (uint => uint) chain_index;
  

  // function setChain(){

  // }

  // function fundChain() payable public{

  // }

  // function removeChain() public {

  // }

  // function getDetails(uint _id) public constant returns(string,string,address,uint,uint){

  // }

  // function chainRemover() internal{

  // }

}