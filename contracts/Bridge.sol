pragma solidity ^0.4.17;

import "./libraries/SafeMath.sol";
import "./Connector.sol";


//This is the basic wrapped Ether to a different chain contract. 
//All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
  /*You push money when you transfer (delete money here).  If it doesn't go through, you can check to see if transfer ID went through
  --How do we deal with livliness assumption? (do we?)
-We need to add ERC20 functionality to represent the Ether transferred from the other contract
  */
contract Bridge is Connector,Wrapped_Token{

  using SafeMath for uint256;

  /***VARIABLES***/
  string public bridgedChain;
  uint public total_deposited_supply;
  uint public total_locked;
  address public connector_Address;
  uint transNonce;


  /***STORAGE***/
  mapping(address => uint) deposited_balances;
  mapping(address => uint) locked_amount;
  
  /***MODIFIERS***/
  /// @dev Access modifier for Owner functionality
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  /***EVENTS***/

  event Locked(address _from, uint _value);

  /***FUNCTIONS***/

  //This function creates tokens equal in value to the amount sent to the contract
  function deposit() public payable {
    require(msg.value > 0);
    deposited_balances[msg.sender] = deposited_balances[msg.sender].add(msg.value);
    total_deposited_supply = total_deposited_supply.add(msg.value);
  }

  /*
  * This function 'unwraps' an _amount of Ether in the sender's balance by transferring Ether to them
  *
  * @param "_amount": The amount of the token to unwrap
  */
  function withdraw(uint _value) public {
    require(balances[msg.sender] >= _value);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    total_supply = total_supply.sub(_value);
    msg.sender.transfer(_value);
  }


  /*
  * This function 'unwraps' an _amount of Ether in the sender's balance by transferring Ether to them
  *
  * @param "_amount": The amount of the token to unwrap
  */
  function destroyToken(uint _value) public {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    total_supply = total_supply.sub(_value);
    msg.sender.transfer(_value);
  }

  //Returns the balance associated with the passed in _owner
  function depositedBalanceOf(address _owner) public constant returns (uint) { return balances[_owner]; }

/*
  * Allows for a transfer of tokens to _to
  *
  * @param "_to": The address to send tokens to
  * @param "_amount": The amount of tokens to send
  */
  function transferOver(uint _amount) public{
    require (balances[msg.sender] >= _amount && _amount > 0);
      locked_amount[msg.sender] = locked_amount[msg.sender].add(_amount);
      time_locked[msg.sender] = now;
      balances[msg.sender] = balances[msg.sender].sub(_amount);
      Locked(msg.sender,_amount);
      transNonce += 1;
      pushToOtherChain(_amount,msg.sender,transNonce);
  }

  //Should we have an ID and amount to allow people to withdraw if transfer doesn't go through? -- but why wouldn't it go through?
  //The bool is for if it's ETH or if this is the sidechian sending back the token(?)
  function receiveTransfer(bool isETH, uint _amount, address _reciever,uint transfer_Id){


  }

  function getMethod() public constant returns(bytes4,bytes4){
       return this.receiveTransfer.selector;
  }


  /*
  * Allows for a transfer of tokens to _to
  * @param "_to": The address to send tokens to
  * @param "_amount": The amount of tokens to send
  */
  function requestUnlock(uint _amount) public payable{
    require(time_locked[msg.sender] + 2*86400/24 < now)
    connector.checkChild(msg.sender);
  }

}
