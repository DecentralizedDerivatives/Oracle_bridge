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
  bool isMainChain;


  struct Locked{
    uint amount;
    address owner;

  }
  /***STORAGE***/
  mapping(address => uint) deposited_balances;
  mapping(uint => Locked) transferDetails; //maps a transferId to an amount
  mapping(address => uint[]) transferList; //list of all transfers from an address;

  /***MODIFIERS***/
  /// @dev Access modifier for Owner functionality
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  /***EVENTS***/

  event Locked(address _from, uint _value);

  /***FUNCTIONS***/
  /*
  * This function 'unwraps' an _amount of Ether in the sender's balance by transferring Ether to them
  *
  * @param "_amount": The amount of the token to unwrap
  */
  function withdraw(uint _value) public {
    require(deposited_balances[msg.sender] >= _value);
    deposited_balances[msg.sender] = deposited_balances[msg.sender].sub(_value);
    total_deposited_supply = total_deposited_supply.sub(_value);
    msg.sender.transfer(_value);
  }


  //Returns the balance associated with the passed in _owner
  function depositedBalanceOf(address _owner) public constant returns (uint) { return deposited_balances[_owner]; }


  function getTransfer(uint _transferId) public returns(uint,address){
    Locked memory _locked = transferDetails[_transferId];
    return(_locked.amount,_locked.owner)
  }
/*
  * Allows for a transfer of tokens to _to
  *
  * @param "_to": The address to send tokens to
  * @param "_amount": The amount of tokens to send
  */
  function lockforTransfer(uint _amount, bool _eth) payable public returns(uint){
    transNonce += 1;
    if(isMainChain){
       require(msg.value >= _amount && _amount > 0);
       total_locked = total_locked.add(_amount);
    }
    else{
        require (balances[msg.sender] >= _amount && _amount > 0);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        total_supply = total_supply.sub(_amount);
    }
    Locked(msg.sender,_amount);
    Locked[transNonce].push({
      amount:_amount,
      owner:msg.sender
      })
    transferList[msg.sender].push(transNonce);
    return(transNonce)
  }

  function getMethod() public constant returns(bytes4,bytes4){
       return this.getTransfer.selector;
  }

}
