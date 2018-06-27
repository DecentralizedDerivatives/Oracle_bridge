// pragma solidity ^0.4.19;
// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

// //https://ethereum.stackexchange.com/questions/28641/simplest-way-to-use-a-variable-in-an-oraclize-query?rq=1
// /*Note we still need to convert the bytes32 string to a uint*/
// contract Bridge is usingOraclize{

//   /***VARIABLES***/
//   string public partnerBridge; //address of bridge contract on other chain
//   string public api;
//   string public parameters;
//   uint public lastValue;
//   bytes4 method_data;
//   event Print(string);
//   event Print2(bytes32);



//   function Bridge() public {
//        method_data = this.retrieveData.selector;
//        setAPI("json(https://ropsten.infura.io/).result");
//        setPartnerBridge('"0x8c9aed038274ecf28a4f435fe731e2ff249166dc"');
//   }
//   //WORKING:
//   /*
//   json(https://ropsten.infura.io/).result
//    {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x8c9aed038274ecf28a4f435fe731e2ff249166dc","data":"0x5bee29b7000000000000000000000000000000000000000000000000000000005add2200"}, "latest"]}
// */

// //oraclize_query("URL","json(https://ropsten.infura.io/).result",'{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"00x8c9aed038274ecf28a4f435fe731e2ff249166dc","data":"0x5bee29b71524441600"}, "latest"]}');

//  //{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x8c9aed038274ecf28a4f435fe731e2ff249166dc","data":"0x5bee29b71524441600"}, "latest"]}
// //should return 1000

// //mock bridge - 0x8c9aed038274ecf28a4f435fe731e2ff249166dc
// // (date) 1524441600
//   address[] public contracts;
//   mapping(uint => uint) internal oracle_values;
//   //mock contract (so we can read a number from ropsten)
//     function retrieveData(uint _date) public constant returns (uint) {
//         return oracle_values[_date];
//     }


//   function setPartnerBridge(string _connected) public{
//     partnerBridge = _connected;
//   }
  
//   function setAPI(string _api) public returns(string){
//       api = _api; 
//       return api;  //
//   }

//     //can make internal once it works
//     function createQuery_value(uint _u_id) public returns(string){
//       bytes32 _s_id = bytes32(_u_id);
//       string memory _id = fromB32(_s_id);
//       string memory _code = strConcat(fromCode(method_data),_id);
//       string memory _part = ' {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":';
//       string memory _params2 = strConcat(_part,partnerBridge,',"data":"',_code,'"},"latest"]}');
//       checkChild(_params2);
//       return _params2;
//     }

//     function toHexDigit(uint8 d) pure internal returns (byte) {                                                                                      
//     if (0 <= d && d <= 9) {                                                                                                                      
//         return byte(uint8(byte('0')) + d);                                                                                                       
//     } else if (10 <= uint8(d) && uint8(d) <= 15) {                                                                                               
//         return byte(uint8(byte('a')) + d - 10);                                                                                                  
//     }                                                                                                                                            
//     revert();                                                                                                                                    
// }                                                                                                                                                


// function fromHexChar(uint c) public pure returns (uint) {
//     if (byte(c) >= byte('0') && byte(c) <= byte('9')) {
//         return c - uint(byte('0'));
//     }
//     if (byte(c) >= byte('a') && byte(c) <= byte('f')) {
//         return 10 + c - uint(byte('a'));
//     }
//     if (byte(c) >= byte('A') && byte(c) <= byte('F')) {
//         return 10 + c - uint(byte('A'));
//     }
// }

// function fromCode(bytes4 code) public view returns (string) {                                                                                    
//     bytes memory result = new bytes(10);                                                                                                         
//     result[0] = byte('0');
//     result[1] = byte('x');
//     for (uint i=0; i<4; ++i) {
//         result[2*i+2] = toHexDigit(uint8(code[i])/16);
//         result[2*i+3] = toHexDigit(uint8(code[i])%16);
//     }
//     return string(result);
// }

// function toCode(string code) public view returns (bytes32) {                                                                                    
//     bytes32 memory result;               
//     for (uint i=0; i<=64; i++) {
//         result[i] = code[i];
//     }
//     return result;
//   }



// //note no 0x
// function fromB32(bytes32 code) public view returns (string) {                                                                                    
//     bytes memory result = new bytes(64);                                                                                                         
//     for (uint i=0; i<32; ++i) {
//         result[2*i] = toHexDigit(uint8(code[i])/16);
//         result[2*i+1] = toHexDigit(uint8(code[i])%16);
//     }
//     return string(result);
// }


    
//     function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
//     bytes memory _ba = bytes(_a);
//     bytes memory _bb = bytes(_b);
//     bytes memory _bc = bytes(_c);
//     bytes memory _bd = bytes(_d);
//     bytes memory _be = bytes(_e);
//     string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
//     bytes memory babcde = bytes(abcde);
//     uint k = 0;
//     for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
//     for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
//     for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
//     for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
//     for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
//     return string(babcde);
// }

// function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
//     return strConcat(_a, _b, _c, _d, "");
// }

// function strConcat(string _a, string _b, string _c) internal returns (string) {
//     return strConcat(_a, _b, _c, "", "");
// }

// function strConcat(string _a, string _b) internal returns (string) {
//     return strConcat(_a, _b, "", "", "");
// }

// function fund() public payable{

// }

//     function __callback(bytes32 myid, bytes32 result) {
//         require(msg.sender == oraclize_cbAddress());
//         lastValue = uint(result);
//         Print2(result);
//     }

//     function checkChild(string _params)public {
//         if (oraclize_getPrice("URL") > this.balance) {
//             Print("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
//         } else {
//             Print("Oraclize query was sent, standing by for the answer..");
//             oraclize_query("URL",api,_params);
//         }

// }
// /*
// "0x00000000000000000000000000000000000000000000000000000000000003e8"
// */
// function test(bytes32 _val) public pure returns(uint){
//   return uint(_val);
// }

// function stringToBytes32(string memory source) returns (bytes32 result) {
//     bytes memory tempEmptyStringTest = bytes(source);
//     if (tempEmptyStringTest.length == 0) {
//         return 0x0;
//     }

//     assembly {
//         result := mload(add(source,1))
//     }
// }

// }


