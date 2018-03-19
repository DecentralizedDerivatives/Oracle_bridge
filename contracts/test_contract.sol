//deployed on Ropsten at:0x76a83b371ab7232706eac16edf2b726f3a2dbe82
pragma solidity ^0.4.17;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract test_contract { 
	uint public last_a;

	function double(uint a) public returns(uint) { 
	  last_a = a;
	  return 2*a;   
	 }
	 
	 function getLastA() public constant returns(uint){
	     return last_a;
	 }
	 
	 function getMethod() public constant returns(bytes4){
	     return this.getLastA.selector;
	 }
	 
	function bytes32ToString(bytes32 x) constant returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
    }
}


contract ExampleContract is usingOraclize {

    uint public lastValue;
    event LogPriceUpdated(string price);
    event Print(uint _value);
    event LogNewOraclizeQuery(string description);

    function ExampleContract() payable {
        updatePrice();
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        lastValue = uint(result);
        LogPriceUpdated(result);
        Print(lastValue);
    }

    function updatePrice() payable {
        if (oraclize_getPrice("URL") > this.balance) {
            LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL","json(https://ropsten.infura.io/).result",'{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}');
        }
    }
}

/*
Here is how to get the call data:
Do 'getMethod()' above of your function.
Get result...e.g. 0xad3b80a8
So you get: 
var contract_data = 0xad3b80a8
var contract_address = 0x76a83b371ab7232706eac16edf2b726f3a2dbe82 // where your contract is deployed
Now here is your call:
url post - json(https://ropsten.infura.io/).result
params -   {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}

So your query will give you:
["json(https://ropsten.infura.io/).result"," {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}"]