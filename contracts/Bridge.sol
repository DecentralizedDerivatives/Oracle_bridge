pragma solidity ^0.4.17;

import "./libraries/SafeMath.sol";
import "usingOraclize.sol"


//This is the basic wrapped Ether to a different chain contract. 
//All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
contract Bridge is usingOraclize{

  using SafeMath for uint256;

  /*Variables*/

  //ERC20 fields
  string public bridgedChain;
  uint public total_supply;
  uint last_check;


  struct{
    uint time_sent;
    uint _amount_reqlocked;
  }

  //ERC20 fields
  mapping(address => uint) balances;
  mapping(address => uint) locked_amount;
  mapping(bytes32 => uint) locked_amount;

  /*Events*/

  event Transferred(address indexed _from, address indexed _to, uint _value);
  event StateChanged(bool _success, string _message);

  /*Functions*/

  //This function creates tokens equal in value to the amount sent to the contract
  function deposit() public payable {
    require(msg.value > 0);
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    total_supply = total_supply.add(msg.value);
  }

  /*
  * This function 'unwraps' an _amount of Ether in the sender's balance by transferring Ether to them
  *
  * @param "_amount": The amount of the token to unwrap
  */
  function withdraw(uint _value) public {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    total_supply = total_supply.sub(_value);
    msg.sender.transfer(_value);
  }

  //Returns the balance associated with the passed in _owner
  function balanceOf(address _owner) public constant returns (uint bal) { return balances[_owner]; }

  function balanceLocked(address _owner) public constant returns (uint bal) { return locked_amount[_owner]; }


  function setBridge(string _chain) public{
    bridgedChain = "json(http://localhost:9545).result";
  }
  /*
  * Allows for a transfer of tokens to _to
  *
  * @param "_to": The address to send tokens to
  * @param "_amount": The amount of tokens to send
  */
  function lockforTransfer(uint _amount) public returns (bool success) {
    if (balances[msg.sender] >= _amount
    && _amount > 0
    && locked_amount[msg.sender] + _amount > locked_amount[msg.sender]) {
      locked_amount[msg.sender] = locked_amount[msg.sender].add(_amount);
      return true;
    } else {
      return false;
    }
  }


  /*
  * Allows for a transfer of tokens to _to
  *
  * @param "_to": The address to send tokens to
  * @param "_amount": The amount of tokens to send
  */
  function requestUnlock(uint _amount) public returns (bool success){
    if (locked_amount[msg.sender] >= _amount
    && _amount > 0
    && locked_amount[msg.sender] + _amount > locked_amount[msg.sender]) {
      blocked_amount[msg.sender] = locked_amount[msg.sender].add(_amount);
      return true;
    } else {
      return false;
    }
  }

  function checkChild() internal returns(uint _amount){

  }

  function _callback() public returns(bool _success)public{
    
  }
}
