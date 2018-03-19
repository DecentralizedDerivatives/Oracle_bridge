pragma solidity ^0.4.17;

import "./libraries/SafeMath.sol";
import "./Connector.sol";


//This is the basic wrapped Ether to a different chain contract. 
//All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
contract Bridge is Connector{

  using SafeMath for uint256;

  /*Variables*/
  string public bridgedChain;
  uint public total_supply;
  uint public total_locked;
  uint public last_check;
  address public connector_Address;

  Connector_Interface connector;

  mapping(address => uint) balances;
  mapping(address => uint) locked_amount;
  mapping(address => uint) time_locked; //parties must wait X minutes before withdrawing once locked
  
  /***MODIFIERS***/
  /// @dev Access modifier for Owner functionality
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  /*Events*/

  event Locked(address _from, uint _value);

  /*Functions*/

  //This function creates tokens equal in value to the amount sent to the contract
  function deposit() public payable {
    require(msg.value > 0);
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    total_supply = total_supply.add(msg.value);
  }

  /**
  *@Note we have this here so that you can change the oraclize string if necessary (can we figure out a better way?)
  *
  */
  function setConnector(address _conn) public onlyOwner(){
    connector = Connector_Interface(_conn);
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
  function balanceOf(address _owner) public constant returns (uint) { return balances[_owner]; }

  function balanceLocked(address _owner) public constant returns (uint) { return locked_amount[_owner]; }

  function getCurrentTime() public constant returns (uint){
    return now;
  }

  /*
  * Allows for a transfer of tokens to _to
  *
  * @param "_to": The address to send tokens to
  * @param "_amount": The amount of tokens to send
  */
  function lockforTransfer(uint _amount) public returns (bool) {
    if (balances[msg.sender] >= _amount
    && _amount > 0
    && locked_amount[msg.sender] + _amount > locked_amount[msg.sender]) {
      locked_amount[msg.sender] = locked_amount[msg.sender].add(_amount);
      time_locked[msg.sender] = now;
      Locked(msg.sender,_amount);
      return true;
    } else {
      return false;
    }
  }

  function getMethods() public constant returns(bytes4,bytes4){
       return this.balanceLocked.selector;
       return this.getCurrentTime.selector;
  }


  /*
  * Allows for a transfer of tokens to _to
  *
  * @param "_to": The address to send tokens to
  * @param "_amount": The amount of tokens to send
  */
  function requestUnlock(uint _amount) public payable{
    require(time_locked[msg.sender] + 86400/24 < now)
    connector.checkChild(msg.sender);
  }

}
