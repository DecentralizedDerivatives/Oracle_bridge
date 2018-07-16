pragma solidity ^0.4.21;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function min(uint a, uint b) internal pure returns (uint256) {
    return a < b ? a : b;
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


/**
* This is the basic wrapped Ether contract. 
* All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
*/
contract Wrapped_Token{

  using SafeMath for uint256;

  /*Variables*/

  //ERC20 fields
  string public name = "Wrapped Ether";
  uint public total_supply;

  //ERC20 fields
  mapping(address => uint) balances;
  mapping(address => mapping (address => uint)) allowed;

  /*Events*/
  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);


  /*Functions*/
    /**
    *@param _owner is the owner address used to look up the balance
    *@return Returns the balance associated with the passed in _owner
    */
    function balanceOf(address _owner) public constant returns (uint bal) { 
        return balances[_owner]; 
    }

    /*
    * @dev Allows for a transfer of tokens to _to
    * @param _to The address to send tokens to
    * @param _amount The amount of tokens to send
    */
    function transfer(address _to, uint _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] = balances[msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    /*
    * @dev Allows an address with sufficient spending allowance to send tokens on the behalf of _from
    * @param _from The address to send tokens from
    * @param _to The address to send tokens to
    * @param _amount The amount of tokens to send
    */
    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        if (balances[_from] >= _amount
        && allowed[_from][msg.sender] >= _amount
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
            balances[_from] = balances[_from].sub(_amount);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
      }
    }

    /**
    *@dev This function approves a _spender an _amount of tokens to use
    *@param _spender address
    *@param _amount amount the spender is being approved for
    *@return true if spender appproved successfully
    */
    function approve(address _spender, uint _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**
    *@param _owner address
    *@param _spender address
    *@return Returns the remaining allowance of tokens granted to the _spender from the _owner
    */
    function allowance(address _owner, address _spender) public view returns (uint remaining) { 
        return allowed[_owner][_spender]; 
    }

    /**
    *@dev Getter for the total_supply of wrapped ether
    *@return total supply
    */
    function totalSupply() public constant returns (uint) {
       return total_supply;
    }
}


/**
*Side chain bridge contract
*/


/**
* This is the basic wrapped Ether to a different chain contract. 
* All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
* You push money when you transfer (delete money here).  If it doesn't go through, 
* you can check to see if transfer ID went through
* TO DO:  --How do we deal with liveliness assumption? (do we?)
* TO DO: We need to add ERC20 functionality to represent the Ether 
* transferred from the other contract
*/
contract DappBridge is usingOraclize, Wrapped_Token{

    using SafeMath for uint256;

    /***VARIABLES***/
    string public bridgedChain;
    uint public total_deposited_supply;
    uint public total_locked;
    uint transNonce;
    string public partnerBridge; //address of bridge contract on other chain
    string api;
    string parameters;
    address public owner;
    bytes4 method_data;

    struct Details{
        uint amount;
        address owner;
        uint transferId;
    }
    /***STORAGE***/
    mapping(address => uint) deposited_balances;
    mapping(uint => Details) transferDetails; //maps a transferId to an amount
    mapping(address => uint[]) transferList; //list of all transfers from an address;
    mapping(uint => bool) pulledTransaction;

    /***EVENTS***/
    event Locked(address _from, uint _value);
    event LogUpdated(string value);
    event LogNewOraclizeQuery(string description);

    /***FUNCTIONS***/
    constructor() public  {
        //enter your custom OAR here:
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        owner = msg.sender;
    }
 
    /***MODIFIERS***/
    /** 
    * @dev Access modifier for Owner functionality
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    *@dev Allows the owner to set a new owner address
    *@param _owner the new owner address
    */
    function setOwner (address _owner) public onlyOwner(){
        owner = _owner;
    }

    /**
    * @dev Locks side chain tokens and returns the transactionID/transNonce used in the 
    * Bridge.CheckChild function
    * @param _amount The amount of tokens to lock
    */
    function lockforTransfer(uint _amount) payable public returns(uint){
        transNonce += 1;
        require (balances[msg.sender] >= _amount && _amount > 0);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        total_supply = total_supply.sub(_amount);
        emit Locked(msg.sender,_amount);
        transferDetails[transNonce] = Details({
            amount:_amount,
            owner:msg.sender,
            transferId:transNonce
        });
       transferList[msg.sender].push(transNonce);
       return(transNonce);
    }

    /**
    * @dev Checks main chain for Ether is locked for tranfer through their transferId. 
    * @param _id from locked Ether on the main chain. It includes the string
    * of parameters including the 4-byte code address of the getTransfer fuction on the 
    * mainchain to get the tranfer details (amount, owner, transferId)
    * TO DO: We need to append address to end of data_string
    */
    function checkMain(uint _id) public payable{
        if (oraclize_getPrice("URL") * 2  > msg.value) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogNewOraclizeQuery("Oraclize query was sent for locked balance");
            string memory _params  = createQuery_value(_id);
            bytes32 queryId = oraclize_query("URL",api,_params);
       }
    }



    /**
    * @dev This function is called from the main chain through its 4-byte code 
    * address through the oraclize function within the CheckChild function in the main chain
    */
    function getTransfer(uint _transferId) public returns(uint,address,uint){
        Details memory _locked = transferDetails[_transferId];
        return(_locked.amount,_locked.owner,_locked.transferId);
    }

    /**
    * @dev creates a string needed for the oraclize query
    * @param u_id is the transactionId obtained from the DappBridge.CheckMain._id
    * which is the same as the same as the Bridge.lockforTransfer return(transNonce)
    * TO DO: can make internal once it works
    * TO DO:check id (60 is an open, so we can try it)
    */
    function createQuery_value(uint u_id) public constant returns(string){
        bytes32 _s_id = bytes32(u_id);
        string memory _id = Strings.fromB32(_s_id);
        string memory _code = strConcat(partnerBridge,',"data":"',Strings.fromCode(method_data),_id,'"},"latest"]}');
        string memory _params2 = strConcat(' {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":',_code);
        return _params2;
    }


    /**
    * @dev Gets the oraclize query results as as string, parses the string to
    * get the amount, owner, transferID, updates the owner's/sender side chain 
    * token balance
    * @param myid is the oraclize query ID 
    * @param result is a string of the amount, owner, and transferId from the 
    * Bridge.getTransfer function
    */
    function __callback(bytes32 myid, string result) public {
        require (msg.sender == oraclize_cbAddress());
        uint _amount= parseInt(Strings.substring(result,1,32));
        address _owner =  parseAddr(Strings.substring(result,1,32));
        uint _transId = parseInt(Strings.substring(result,1,32));
        require(pulledTransaction[_transId] == false);
        balances[_owner] = balances[_owner].add(_amount);
        pulledTransaction[_transId] = true;
        emit LogUpdated(result);
    }    


    /**
    * @dev Returns the balance associated with the passed in _owner
    * @param _owner address
    * @return balance of owner specified
    */
    function depositedBalanceOf(address _owner) public constant returns (uint) { 
        return deposited_balances[_owner]; 
    }

    /**
    * @dev Set partner bridge contract address from the main chain
    * @param _connected is the Bridge cotnract address on main chain 
    * and should be entered as string
    */
    function setPartnerBridge(string _connected) public onlyOwner(){
        partnerBridge = strConcat('"',_connected,'"');
        method_data = this.getTransfer.selector;
    }


    /**
    * @dev Sets API for sidechain
    * @param _api for mide chain as string such as an Infura hosted node
    * try: //"json(https://ropsten.infura.io/).result"
    */
    function setAPI(string _api) public onlyOwner(){
        api = _api; //"json(https://ropsten.infura.io/).result"
    }



}