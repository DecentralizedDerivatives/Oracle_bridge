pragma solidity ^0.4.17;

import "./libraries/SafeMath.sol";
import "usingOraclize.sol"


//This is the basic wrapped Ether to a different chain contract. 
//All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
contract Mainchain_Bridge is usingOraclize{

  using SafeMath for uint256;

  /*Variables*/

  //ERC20 fields
  string public childChain = "json(http://localhost:8546).result"; // { return balances[_owner]; }
  uint public total_supply;


  //ERC20 fields
  mapping(address => uint) balances;
  mapping(address => uint) locked_amount;

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

  /*
  * Allows for a transfer of tokens to _to
  *
  * @param "_to": The address to send tokens to
  * @param "_amount": The amount of tokens to send
  */
  function lockforTransfer(address _to, uint _amount) public returns (bool success) {
    if (balances[msg.sender] >= _amount
    && _amount > 0
    && balances[_to] + _amount > balances[_to]) {
      balances[msg.sender] = balances[msg.sender].sub(_amount);
      balances[_to] = balances[_to].add(_amount);
      return true;
    } else {
      return false;
    }
  }

  function unlockEther(uint _amount) public returns (bool success){
    return true;

  }

}
