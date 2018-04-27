pragma solidity ^0.4.21;

import "./libraries/SafeMath.sol";
import "./Oraclize/Oraclize_API.sol";
import "./Wrapped_Token.sol";
import "./libraries/Strings.sol";



//This is the basic wrapped Ether to a different chain contract. 
//All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
  /*You push money when you transfer (delete money here).  If it doesn't go through, you can check to see if transfer ID went through
  --How do we deal with livliness assumption? (do we?)
-We need to add ERC20 functionality to represent the Ether transferred from the other contract
  */
contract Bridge is usingOraclize, Wrapped_Token{

  using SafeMath for uint256;
  using Strings for *;

  /***VARIABLES***/
  string public bridgedChain;
  uint public total_deposited_supply;
  uint public total_locked;
  uint transNonce;
  address public partnerBridge; //address of bridge contract on other chain
  string api;
  string parameters;
  address public owner;
  bytes4 method_data;
  bool isMainChain;

  struct Details{
    uint amount;
    address owner;
    uint transferId;
  }
  /***STORAGE***/
  mapping(address => uint) deposited_balances;
  mapping(uint => Details) transferDetails; //maps a transferId to an amount
  mapping(address => uint[]) transferList; //list of all transfers from an address;
  mapping(uint => bool) pulledTransaction;
  /***EVENTS***/
  event Locked(address _from, uint _value);
  event LogUpdated(string value);
  event LogNewOraclizeQuery(string description);
  /***FUNCTIONS***/

  function Bridge() public {
       method_data = this.getTransfer.selector;
       owner = msg.sender;
  }
 
  /***MODIFIERS***/
  /// @dev Access modifier for Owner functionality
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  function setOwner (address _owner) public onlyOwner(){
    owner = _owner;
  }
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


  function getTransfer(uint _transferId) public returns(uint,address,uint){
    Details memory _locked = transferDetails[_transferId];
    return(_locked.amount,_locked.owner,_locked.transferId);
  }
/*
  * Allows for a transfer of tokens to _to
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
    transferDetails[transNonce] = Details({
      amount:_amount,
      owner:msg.sender,
      transferId:transNonce
      });
    transferList[msg.sender].push(transNonce);
    return(transNonce);
  }


    //we need to append address to end of data_string

  function checkChild(string _transferId) internal payable{
      if (oraclize_getPrice("URL") * 2  > this.balance) {
          LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      } else {
          LogNewOraclizeQuery("Oraclize query was sent for locked balance");
          var _parameters  = createQuery_value(_transferId);
          oraclize_query("URL",_api, _parameters);
          //oraclize_query("URL","json(https://ropsten.infura.io/).result",'{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}');
   }
  }

   function __callback(bytes32 myid, string result) public {
        require (msg.sender == oraclize_cbAddress());
        var _result = smt(result);
        var _amount= _result[0];
        address _owner = _result[1];
        var _transId = _result[2];
        require(pulledTransaction[_transId] == false);
    if(isMainChain){
      deposited_balances[_owner] = deposited_balances[_owner].add(_amount);
      total_deposited_supply = total_deposited_supply.add(_amount);
    }
    else{
      balances[_owner] = balances[_owner].add(_amount);
    }
    pulledTransaction[_transId] = true;
        LogUpdated(result);
    }

  function smt(string _s)public returns(uint[3]){
        var s = _s.toSlice();
        var delim = ",".toSlice();
        var parts = new uint[](s.count(delim));
        for(uint i = 0; i < parts.length; i++) {
           parts[i] = s.split(delim).toString();
        }
    }


  function setPartnerBridge(address _connected) public onlyOwner(){
    partnerBridge = strConccat('"',_connected,'"');
  }


  function setAPI(string _api, string _params) public onlyOwner(){
      api = _api; //"json(https://ropsten.infura.io/).result"
    }

    //can make internal once it works
    function createQuery_value(string _id) public constant returns(string){
      bytes32 _s_id = bytes32(_u_id);
      string memory _id = fromB32(_s_id);
      string memory _code = strConcat(fromCode(method_data),_id);
      string memory _part = ' {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":';
      string memory _params2 = strConcat(_part,partnerBridge,',"data":"',_code,'"},"latest"]}');
      return _params2;
    }

        function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
}

function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
    return strConcat(_a, _b, _c, _d, "");
}

function strConcat(string _a, string _b, string _c) internal returns (string) {
    return strConcat(_a, _b, _c, "", "");
}

function strConcat(string _a, string _b) internal returns (string) {
    return strConcat(_a, _b, "", "", "");
}
}
