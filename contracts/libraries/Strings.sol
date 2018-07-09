pragma solidity ^0.4.17;

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