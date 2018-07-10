pragma solidity ^0.4.21;

import "./libraries/SafeMath.sol";
import "./Oraclize/Oraclize_API.sol";
import "./Wrapped_Token.sol";
import "./libaries/Strings.sol"



//This is the basic wrapped Ether to a different chain contract. 
//All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
  /*You push money when you transfer (delete money here).  If it doesn't go through, you can check to see if transfer ID went through
  --How do we deal with livliness assumption? (do we?)
-We need to add ERC20 functionality to represent the Ether transferred from the other contract
  */
contract Bridge is usingOraclize, Wrapped_Token{

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
  /***FUNCTIONS***/

  constructor() public  {
    //enter your custom OAR here:
       OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
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
  function lockforTransfer(uint _amount) payable public returns(uint){
    transNonce += 1;
    require (balances[msg.sender] >= _amount && _amount > 0);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    total_supply = total_supply.sub(_amount);
    emit Locked(msg.sender,_amount);
    transferDetails[transNonce] = Details({
      amount:_amount,
      owner:msg.sender,
      transferId:transNonce
      });
    transferList[msg.sender].push(transNonce);
    return(transNonce);
  }


    //we need to append address to end of data_string
  function checkChild(uint _id) public payable{
      if (oraclize_getPrice("URL") * 2  > msg.value) {
          emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      } else {
          emit LogNewOraclizeQuery("Oraclize query was sent for locked balance");
          string memory _params  = createQuery_value(_id);
          bytes32 queryId = oraclize_query("URL",api,_params);
   }
  }

  //now callback a result of _transID and value

  function __callback(bytes32 myid, string result) public {
        require (msg.sender == oraclize_cbAddress());
        uint startIdx = 0;
        if(hasZeroXPrefix(_hexData)) {
            startIdx = 2;
        }
        bytes memory bts = bytes(_hexData);
        //take the first 64 bytes and convert to uint
        uint _amount = hexToUint(substr(_hexData, startIdx,64+startIdx));
        //id is at the end and will be 64 bytes. So grab its starting idx first.
        uint idStart = bts.length - 64;
        //the address portion will end where the id starts.
      uint addrEnd = idStart-1;
        //parse the last 40 bytes of the address hex.
      address _owner = parseAddr(substr(_hexData, addrEnd-40, addrEnd));
        //then extract the id
      uint _transId = hexToUint(substr(_hexData, idStart, bts.length));
        require(pulledTransaction[_transId] == false);
      balances[_owner] = balances[_owner].add(_amount);
    pulledTransaction[_transId] = true;
        emit LogUpdated(result);
    }


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
      string memory _id = fromB32(_s_id);
      string memory _code = strConcat(fromCode(method_data),_id);
      string memory _part = ' {"jsonrpc":"2.0","id":60,"method":"eth_call","params":[{"to":';
      string memory _params2 = strConcat(_part,partnerBridge,',"data":"',_code,'"},"latest"]}');
      return _params2;
    }

}