pragma solidity ^0.4.19;

//deployed on Ropsten at: 0xd29d27cfacf7b77a16edac7c2cddf07dc4a603b8 
//.8 Ether stored under transNonce 1
//This one works:
//json(https://ropsten.infura.io/).result
// {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0xd29d27cfacf7b77a16edac7c2cddf07dc4a603b8","data":"0xc16fe9070000000000000000000000000000000000000000000000000000000000000001"}, "latest"]}
contract TestQuery{
  struct Details{
    uint amount;
    address owner;
    uint transferId;
  }

  uint transNonce;
    event Locked(address _from, uint _value);

  mapping(uint => Details) transferDetails; //maps a transferId to an amount
    mapping(address => uint[]) transferList; //list of all transfers from an address;

  function lockforTransfer() payable public returns(uint){
    require(msg.value > 0);
        transNonce += 1;
    transferDetails[transNonce] = Details({
      amount:msg.value,
      owner:msg.sender,
      transferId:transNonce
      });
    transferList[msg.sender].push(transNonce);
    return(transNonce);
  }

  function getTransfer(uint _transferId) public view returns(uint,address,uint){
    Details memory _locked = transferDetails[_transferId];
    return(_locked.amount,_locked.owner,_locked.transferId);
  }

}

//deployed on Rinkeby at: 0x177e66ad4cdf0c0f3df92a744a667108bd95c305
//.8 Ether stored under transNonce 1
//This one works:


pragma solidity ^0.4.21;// <ORACLIZE_API>

contract usingOraclize {
   

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
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

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }
 
    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }
    
    function parseInt(string _a) internal pure returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }

function parseAddr(string _a) internal pure returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }

}
// </ORACLIZE_API>

contract TestQuery is usingOraclize {
  struct Details{
    uint amount;
    address owner;
    uint transferId;
  }
 

  uint transNonce;
    event Locked(address _from, uint _value);
    event Print(string _s);

  mapping(uint => Details) transferDetails; //maps a transferId to an amount
    mapping(address => uint[]) transferList; //list of all transfers from an address;

  function lockforTransfer() payable public returns(uint){
    require(msg.value > 0);
        transNonce += 1;
    transferDetails[transNonce] = Details({
      amount:msg.value,
      owner:msg.sender,
      transferId:transNonce
      });
    transferList[msg.sender].push(transNonce);
    return(transNonce);
  }
  string _int;
  bytes _new;
  event P2 (uint);
//"0x0000000000000000000000000000000000000000000000000b1a2bc2ec500000000000000000000000000000c69c64c226fea62234afe4f5832a051ebc8605400000000000000000000000000000000000000000000000000000000000000001"
    function __callback(string result) public returns(uint,address,uint){
        emit Print(result);
        string memory _int = Strings.substring(result,60,90);
        emit Print(_int);
        emit P2(stringToUint(_int));
        //uint _amount= parseInt(_int);
        //_int =strConcat('0x',Strings.substring(result,91,130)) ;
        //address _owner =  parseAddr(_int);
        //_int =Strings.substring(result,131,194) ;
        //uint _transId = parseInt(_int);
        //return (_amount,_transId,_transId);
    }
function stringToUint(string s) constant returns (uint) {
    bytes memory b = bytes(s);
    uint result = 0;
    for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
        if (b[i] >= 48 && b[i] <= 57) {
            result = result * 10 + (uint(b[i]) - 48); // bytes and int are not compatible with the operator -.
        }
    }
    return result; // this was missing
}


  function getTransfer(uint _transferId) public view returns(string){
    Details memory _locked = transferDetails[_transferId];
    string memory _data = strConcat(uint2str(_locked.amount),",");
    _data = strConcat(_data,'0x',toString(_locked.owner));
    _data = strConcat(_data,",",uint2str(_locked.transferId));
    Print(_data);
    return(_data);
  }
  
    //can make internal once it works
    //check id (60 is an open, so we can try it)
    function createQuery_value(uint u_id) public constant returns(string){
        bytes4 method_data = this.getTransfer.selector;
        string memory partnerBridge = "0xd29d27cfacf7b77a16edac7c2cddf07dc4a603b8";
      bytes32 _s_id = bytes32(u_id);
      string memory _id = Strings.fromB32(_s_id);
      string memory _code = strConcat(partnerBridge,',"data":"',Strings.fromCode(method_data),_id,'"},"latest"]}');
      string memory _params2 = strConcat(' {"jsonrpc":"2.0","id":60,"method":"eth_call","params":[{"to":',_code);
      return _params2;
    }
    
function toString(address x) returns (string) {
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
    function uint2str(uint i) internal pure returns (string){
    if (i == 0) return "0";
    uint j = i;
    uint length;
    while (j != 0){
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint k = length - 1;
    while (i != 0){
        bstr[k--] = byte(48 + i % 10);
        i /= 10;
    }
    return string(bstr);
}


}


//Slightly modified SafeMath library - includes a min function
library Strings {
      function fromCode(bytes4 code) internal pure returns (string) {                                                                                    
    bytes memory result = new bytes(10);                                                                                                         
    result[0] = byte('0');
    result[1] = byte('x');
    for (uint i=0; i<4; ++i) {
        result[2*i+2] = toHexDigit(uint8(code[i])/16);
        result[2*i+3] = toHexDigit(uint8(code[i])%16);
    }
    return string(result);
}


//note no 0x
function fromB32(bytes32 code) pure internal returns (string) {                                                                                    
    bytes memory result = new bytes(64);                                                                                                         
    for (uint i=0; i<32; ++i) {
        result[2*i] = toHexDigit(uint8(code[i])/16);
        result[2*i+1] = toHexDigit(uint8(code[i])%16);
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

function substring(string str, uint startIndex, uint endIndex) public constant returns (string) {
    bytes memory strBytes = bytes(str);
    bytes memory result = new bytes(endIndex-startIndex);
    for(uint i = startIndex; i < endIndex; i++) {
        result[i-startIndex] = strBytes[i];
    }
    return string(result);
}
  


}


