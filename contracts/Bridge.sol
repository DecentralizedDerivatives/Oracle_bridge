pragma solidity ^0.4.21;

contract Bridge is usingOraclize{

  using SafeMath for uint256;

  /***VARIABLES***/
  string public bridgedChain;
  uint public total_deposited_supply;
  uint public total_locked;
  uint transNonce;
  string public partnerBridge; //address of bridge contract on other chain
  string api;
  string parameters;
  address public owner;
  bytes4 method_data;

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
  event Print(string _string);
  /***FUNCTIONS***/

  constructor() public {
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
  * @param "_to": The addreDetails memory _locked = transferDetails[_transferId];ss to send tokens to
  * @param "_amount": The amount of tokens to send
  */
  function lockforTransfer() payable public returns(uint){
    require(msg.value > 0);
       total_locked = total_locked.add(msg.value);
    emit Locked(msg.sender,msg.value);
        transNonce += 1;
    transferDetails[transNonce] = Details({
      amount:msg.value,
      owner:msg.sender,
      transferId:transNonce
      });
    transferList[msg.sender].push(transNonce);
    return(transNonce);
  }


    //we need to append address to end of data_string

  function checkChild(uint _transferId) internal{
      if (oraclize_getPrice("URL") * 2  > msg.value) {
          emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      } else {
          emit LogNewOraclizeQuery("Oraclize query was sent for locked balance");
          string memory _parameters  = createQuery_value(_transferId);
          oraclize_query("URL",api, _parameters);
          Print(api);
          Print(_parameters);
          //oraclize_query("URL","json(https://ropsten.infura.io/).result",'{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}');
   }
  }

   function __callback(bytes32 myid, string result) public {
        require (msg.sender == oraclize_cbAddress());
        uint _amount= parseInt(Strings.substring(result,1,32));
        address _owner =  parseAddr(Strings.substring(result,1,32));
        uint _transId = parseInt(Strings.substring(result,1,32));
        require(pulledTransaction[_transId] == false);
      deposited_balances[_owner] = deposited_balances[_owner].add(_amount);
      total_deposited_supply = total_deposited_supply.add(_amount);
      pulledTransaction[_transId] = true;
        emit LogUpdated(result);
    }

    "0x0000000000000000000000000000000000000000000000000b1a2bc2ec500000000000000000000000000000c69c64c226fea62234afe4f5832a051ebc8605400000000000000000000000000000000000000000000000000000000000000001"


    //Note: It takes an address as a string
  function setPartnerBridge(string _connected) public onlyOwner(){
    partnerBridge = strConcat('"',_connected,'"');
           method_data = this.getTransfer.selector;
  }


  //try: "json(https://localhost:8545).result"
  function setAPI(string _api) public onlyOwner(){
      api = _api; //"json(https://ropsten.infura.io/).result"
    }

    //can make internal once it works
    //check id (60 is an open, so we can try it)
    function createQuery_value(uint u_id) public constant returns(string){
      bytes32 _s_id = bytes32(u_id);
      string memory _id = Strings.fromB32(_s_id);
      string memory _code = strConcat(partnerBridge,',"data":"',Strings.fromCode(method_data),_id,'"},"latest"]}');
      string memory _params2 = strConcat(' {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":',_code);
      return _params2;
    }

}