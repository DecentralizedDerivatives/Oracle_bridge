pragma solidity ^0.4.21;

import "./libraries/SafeMath.sol";
import "./Oraclize/Oraclize_API.sol";
import "./Wrapped_Token.sol";
import "./libaries/Strings.sol";


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

    /***Variables***/
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
    
    /***Storage**/
    mapping(address => uint) deposited_balances;
    mapping(uint => Details) transferDetails; //maps a transferId to an amount
    mapping(address => uint[]) transferList; //list of all transfers from an address;
    mapping(uint => bool) pulledTransaction;

    /***Events***/
    event Locked(address _from, uint _value);
    event LogUpdated(string value);
    event LogNewOraclizeQuery(string description);

    /***Functions***/
    constructor() public  {
        //enter your custom OAR here:
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        owner = msg.sender;
    }
 
    /***Modifiers***/
    /** 
    * @dev Access modifier for Owner functionality
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the owner to set a new owner address
    * @param _owner the new owner address
    */
    function setOwner (address _owner) public onlyOwner(){
        owner = _owner;
    }

    /**
    * @dev Locks side chain tokens and returns the transactionID/transNonce used in the 
    * Bridge.CheckChild function. It also destroys the sidechain tokens that represented 
    * the originally transferred Ether. 
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
    * of parameters including the bytes4 code address of the getTransfer fuction on the 
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
