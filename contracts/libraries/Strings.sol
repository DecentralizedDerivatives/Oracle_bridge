pragma solidity ^0.4.17;

/**
* Library with string conversion functions
*/
library Strings {

    /**
    * Converts bytes4 to string
    */
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

    /**
    * Convert bytes32 to string without the 0x
    */
    function fromB32(bytes32 code) pure internal returns (string) {                                                                                    
        bytes memory result = new bytes(64);                                                                                                         
        for (uint i=0; i<32; ++i) {
            result[2*i] = toHexDigit(uint8(code[i])/16);
            result[2*i+1] = toHexDigit(uint8(code[i])%16);
        }
        return string(result);
    }

    /**
    * Convert hex to byte
    **/
    function toHexDigit(uint8 d) pure internal returns (byte) {                                                                                      
        if (0 <= d && d <= 9) {                                                                                                                      
            return byte(uint8(byte('0')) + d);                                                                                                       
        } else if (10 <= uint8(d) && uint8(d) <= 15) {                                                                                               
            return byte(uint8(byte('a')) + d - 10);                                                                                                  
        }                                                                                                                                            
        revert();                                                                                                                                    
    }
    /**
    * Converts concatenated string and two uint to string
    */
    function substring(string str, uint startIndex, uint endIndex) public constant returns (string) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    /**
    * constants for comparison and conversions below
    */
    byte constant a = byte('a');
    byte constant f = byte('f');
    byte constant A = byte('A');
    byte constant F = byte('F');
    byte constant zero = byte('0');
    byte constant nine = byte('9');

    /**
    * Convert a character to its hex value as a byte. This is NOT
    * very efficient but is a brute-force way of getting the job done.
    * It's possible to optimize this with assembly in solidity but
    * that would require a lot more time.
    */
    function hexCharToByte(uint c) pure internal returns(uint) {
        byte b = byte(c);

        //convert ascii char to hex value
        if(b >= zero && b <= nine) {
            return c - uint(zero);
        } else if(b >= a && b <= f) {
            return 10 + (c - uint(a));
        } else if(b >= A && b <= F) {
            return 10 + (c - uint(A));
        }
    }

    /**
    * Check whether a string has hex prefix.
    */
    function hasZeroXPrefix(string s) pure internal returns(bool) {
        bytes memory b = bytes(s);
        if(b.length < 2) {
            return false;
        }
        return b[1] == 'x';
    }

    /**
     * Convert a hex string to a uint. This is NOT very efficient but
     * gets the job done. Could probably optimize with assembly but would
     * require a lot more time.
     */
    function hexToUint(string s) pure public returns(uint) {
        //convert string to bytes
        bytes memory b = bytes(s);

        //make sure zero-padded
        require(b.length % 2 == 0, "String must have an even number of characters");

        //starting index to parse from
        uint i = 0;
        //strip 0x if present
        if(hasZeroXPrefix(s)) {
            i = 2;
        }
        uint r = 0;
        for(;i<b.length;i++) {
            //convert each ascii char in string to its hex/byte value.
            uint b1 = hexCharToByte(uint(b[i]));

            //shift over a nibble for each char since hex has 2 chars per byte
            //OR the result to fill in lower 4 bits with hex byte value.
            r = (r << 4) | b1;
        }
        //result is hex-shifted value of all bytes in input string.
        return r;
    }

    /**
    * Extract a substring from an input string.
    */
    function substr(string s, uint start, uint end) pure public returns(string) {
        require(end > start, "End must be more than start");
        bytes memory res = new bytes(end-start);
        bytes memory bts = bytes(s);
        require(end <= bts.length, "End must be less than or equal to the length of string");
        require(start >= 0 && start < bts.length, "Start must be between 0 and length of string");

        uint idx = 0;
        for(uint i=start;i<end;++i) {
          //just copy bytes over
            res[idx] = bts[i];
            ++idx;
        }
        return string(res);
    }

    /**
    * Parse a hex string into an address.
    */
    function parseAddr(string _a) internal pure returns (address){
        //address is really a uint160...
        uint iaddr = hexToUint(_a);
        return address(iaddr);
    }

}