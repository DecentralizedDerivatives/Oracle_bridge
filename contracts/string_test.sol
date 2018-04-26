pragma solidity ^0.4.22;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
//https://ethereum.stackexchange.com/questions/28641/simplest-way-to-use-a-variable-in-an-oraclize-query?rq=1

contract Bridge{

  /***VARIABLES***/
  string public partnerBridge; //address of bridge contract on other chain
  string public api;
  string public parameters;
  uint public lastvalue;
  bytes4 method_data;



  function Bridge() public {
       method_data = this.retrieveData.selector;
  }

    //we need to append address to end of data_string

  function checkChild(string _transferId) returns (string){
          var _parameters  = createQuery_value(_transferId);
          return _parameters;
          //oraclize_query("URL","json(https://ropsten.infura.io/).result",'{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}');
  }


//should return 1500

//mock bridge - 0x8c9aed038274ecf28a4f435fe731e2ff249166dc
// (date) 1524441600
  address[] public contracts;
  mapping(uint => uint) internal oracle_values;
  //mock contract (so we can read a number from ropsten)
    function retrieveData(uint _date) public constant returns (uint) {
        return oracle_values[_date];
    }


  function setPartnerBridge(string _connected) public{
    partnerBridge = _connected;
  }
  
  function setAPI(string _api, string _params) public returns(string){
      api = strConcat(_api,_params); // "json(https://ropsten.infura.io/).result, ","jsonrpc:2.0,id:3,method:eth_call,params:[{to:"
      return api;  //
  }

    //can make internal once it works
    function createQuery_value(string _id) public returns(string){
      string memory _code = strConcat(fromCode(method_data),_id);
      string memory params2 = strConcat(api,partnerBridge,"data:",_code,"},latest]}");
      return params2;
      //.concat(_id.toSlice()).concat("},".toSlice()).concat('latest"]}"'.toSlice()); // "abcdef"
    }

    function toHexDigit(uint8 d) pure internal returns (byte) {                                                                                      
    if (0 <= d && d <= 9) {                                                                                                                      
        return byte(uint8(byte('0')) + d);                                                                                                       
    } else if (10 <= uint8(d) && uint8(d) <= 15) {                                                                                               
        return byte(uint8(byte('a')) + d - 10);                                                                                                  
    }                                                                                                                                            
    revert();                                                                                                                                    
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

function fund() public payable{

}

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        lastValue = uint(result);
        LogPriceUpdated(result);
        Print(lastValue);
    }

    function checkChild(string _query)public {
        if (oraclize_getPrice("URL") > this.balance) {
            LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL",_query);
        }

}
