pragma solidity ^0.4.17;

import "./libraries/SafeMath.sol";
import "usingOraclize.sol"

/*To do
-time getter
-update mappings when price getter
-how much gas do we need to send with it

*/
//This is the basic wrapped Ether to a different chain contract. 
//All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
contract Connector is usingOraclize{

  using SafeMath for uint256;

  address public partnerBridge; //address of bridge contract on other chain
  string public api;
  string public parameters;

  event LogUpdated(string value);
  event LogNewOraclizeQuery(string description);
  
  /***MODIFIERS***/
  /// @dev Access modifier for Owner functionality
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  	//we need to append address to end of data_string

  function checkChild(uint _transferId) internal payable returns(uint){
      if (oraclize_getPrice("URL") * 2  > this.balance) {
          LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      } else {
          LogNewOraclizeQuery("Oraclize query was sent for locked balance");
          var param_string  = strConcat(paramaters,_transferId,'}, "latest"]}')
          oraclize_query("URL",api,param_string);
          //oraclize_query("URL","json(https://ropsten.infura.io/).result",'{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}');
	 }
  }

   function __callback(bytes32 myid, string result) {
        require (msg.sender == oraclize_cbAddress());
       	var _result = smt(result);
       	var _value = _result[0];
       	var _owner = _result[1];
		if(isMainChain){
			deposited_balances[_owner] = deposited_balances[_owner].add(_amount);
			total_deposited_supply = total_deposited_supply.add(_amount);
		}
		else{
			balances[_owner] = balances[_owner].add(_amount);
		}
        LogUpdated(result);
    }

  	//up to through the data parameter
    function createQuery_value(string _api, string _params) public onlyOwner(){
    	api = _api;
    	parameters = _params;
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

	function strConcat(string _a, string _b, string _c) internal returns (string) {
	    return strConcat(_a, _b, _c, "", "");
	}

	function smt(string _s) {
        var s = _s.toSlice();
        var delim = ",".toSlice();
        var parts = new uint[](s.count(delim));
        for(uint i = 0; i < parts.length; i++) {
           parts[i] = s.split(delim).toString();
        }
    }
}

