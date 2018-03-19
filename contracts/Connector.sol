pragma solidity ^0.4.17;

import "./libraries/SafeMath.sol";
import "usingOraclize.sol"
import "./Bridge.sol";

/*To do
-time getter
-update mappings when price getter
-how much gas do we need to send with it

*/
//This is the basic wrapped Ether to a different chain contract. 
//All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
contract Connector is usingOraclize{

  using SafeMath for uint256;

  address public bridgeAddress; //address of bridge contract on same chain
  address public partnerBridge; //address of bridge contract on other chain
  Bridge bridge;
  string public api;
  string public parameters;
  string public api_time;
  string public parameters_time;


  mapping(bytes32 => address) queryId;
  mapping (bytes32 => uint) timeId;

  event LogUpdated(string value);
  event LogNewOraclizeQuery(string description);
  
  /***MODIFIERS***/
  /// @dev Access modifier for Owner functionality
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  function setBridge(address _bridge) public onlyOwner() {
  	bridge = Bridge(_bridge);
  }


	function checkChild(address _sender) internal payable returns(uint){
      if (oraclize_getPrice("URL") * 2  > this.balance) {
          LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      } else {
          LogNewOraclizeQuery("Oraclize query was sent for locked balance");
          var oraclizeId = oraclize_query("URL",api,parameters);
          //oraclize_query("URL","json(https://ropsten.infura.io/).result",'{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}');
          queryId[oraclizeId] = _sender;
          LogNewOraclizeQuery("Oraclize query was sent for timestamp");
          oraclize_query("URL",api_time,parameters_time);
          //oraclize_query("URL","json(https://ropsten.infura.io/).result",'{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}');
      }
  }

   function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        lastValue = uint(result);
        LogUpdated(result);
        if (locked_amount[msg.sender] >= _amount
		    && _amount > 0
		    && locked_amount[msg.sender] + _amount > locked_amount[msg.sender]) {
		      blocked_amount[msg.sender] = locked_amount[msg.sender].add(_amount);
		      return true;
		    } else {
		      return false;
		    }
    }

    function createQuery_value(string _api, string _params) public onlyOwner(){
    	api = _api;
    	parameters = _params;
    }

    function createQuery_time(string _api, string _params) public onlyOwner(){
    	api_time = _api;
    	parameters_time = _params;
    }
}

