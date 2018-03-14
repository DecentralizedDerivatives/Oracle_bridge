pragma solidity ^0.4.17;

contract test_contract { 
	int public last_a;

	function double(int a) returns(int) { 
	  last_a = a;
	  return 2*a;   
	 } 
}