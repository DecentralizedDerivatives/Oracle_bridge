pragma solidity ^0.4.21;

import "./libraries/SafeMath.sol";
import "./Oraclize/Oraclize_API.sol";



//This is the basic wrapped Ether to a different chain contract. 
//All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
  /*You push money when you transfer (delete money here).  If it doesn't go through, you can check to see if transfer ID went through
  --How do we deal with livliness assumption? (do we?)
-We need to add ERC20 functionality to represent the Ether transferred from the other contract
  */
contract Bridge is usingOraclize{

  using SafeMath for uint256;

  /***VARIABLES***/
  uint public total_deposited_supply;
  uint transNonce;
  string public partnerBridge; //address of bridge contract on other chain
  string private api;
  address public owner;
  bytes4 private method_data;
  uint public stake;

  /***STORAGE***/
  mapping(address => uint) deposited_balances;
  mapping (bytes32 => address) query;

  /***EVENTS***/
  event JoinedBookClub(address _from);
  event LogUpdated(string value);
  event LogNewOraclizeQuery(string description);

    /***MODIFIERS***/
  /// @dev Access modifier for Owner functionality
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  /***FUNCTIONS***/

  function Bridge() public {
      method_data = this.departingMember.selector;
      owner = msg.sender;
      setAPI("json(https://ropsten.infura.io/).result");
  }

  function setFee(uint _fee) public onlyOwner(){
    stake = _fee;
  }
 

  function setOwner (address _owner) public onlyOwner(){
    owner = _owner;
  }

  function isMember(address _user) public constant returns(bool){
    bool _val = false;
    if(deposited_balances[_user] > 0){
      _val = true;
    }
    return _val;
  }


  function joinBookClub() payable public returns(uint){
    //require(msg.value == stake && deposited_balances[msg.sender] == 0);
    deposited_balances[msg.sender] = 1;
    total_deposited_supply += msg.value;
    emit JoinedBookClub(msg.sender);
  }


    //we need to append address to end of data_string

  function checkChild(address _user) public payable{
      if (oraclize_getPrice("URL") * 2  > msg.value) {
          emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      } else {
          emit LogNewOraclizeQuery("Oraclize query was sent for locked balance");
          string memory _params  = createQuery_value(toAsciiString(_user));
          bytes32 queryId = oraclize_query("URL",api,_params);
          query[queryId] = _user;
   }
  }

   function __callback(bytes32 myId, string result) public {
        require (msg.sender == oraclize_cbAddress());
        uint _res = parseInt(result);
        if(_res == 1){
          address _User = query[myId];
          _User.transfer(stake);
        }
    }

  function setPartnerBridge(string _connected) public onlyOwner(){
    partnerBridge = strConcat('"',_connected,'"');
  }


  //try: "json(https://localhost:8545).result"
  function setAPI(string _api) public onlyOwner(){
      api = _api; //"json(https://ropsten.infura.io/).result"
    }

    //can make internal once it works
    //check id (60 is an open, so we can try it)
    function createQuery_value(string _member_address) public constant returns(string){
      string memory _code = strConcat(fromCode(method_data),"000000000000000000000000",_member_address);
      string memory _part = ' {"jsonrpc":"2.0","id":4,"method":"eth_call","params":[{"to":';
      string memory _params2 = strConcat(_part,partnerBridge,',"data":"',_code,'"},"latest"]}');
      return _params2;
    }


  function departingMember(address _former) public returns(uint){
  }


  function fromCode(bytes4 code) public view returns (string) {                                                                                    
    bytes memory result = new bytes(10);                                                                                                         
    result[0] = byte('0');
    result[1] = byte('x');
    for (uint i=0; i<4; ++i) {
        result[2*i+2] = toHexDigit(uint8(code[i])/16);
        result[2*i+3] = toHexDigit(uint8(code[i])%16);
    }
    return string(result);
}

    function toHexDigit(uint8 d) pure internal returns (byte) {                                                                                      
    if (0 <= d && d <= 9) {                                                                                                                      
        return byte(uint8(byte('0')) + d);                                                                                                       
    } else if (10 <= uint8(d) && uint8(d) <= 15) {                                                                                               
        return byte(uint8(byte('a')) + d - 10);                                                                                                  
    }                                                                                                                                            
    revert();                                                                                                                                    
}                                                                                                                                                

function toAsciiString(address x) returns (string) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        byte hi = byte(uint8(b) / 16);
        byte lo = byte(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);            
    }
    return string(s);
}
function char(byte b) returns (byte c) {
    if (b < 10) return byte(uint8(b) + 0x30);
    else return byte(uint8(b) + 0x57);
}

}