pragma solidity ^0.4.21;

import "./libraries/SafeMath.sol";
import "./Oraclize/Oraclize_API.sol";
import "./Wrapped_Token.sol";
import "./libraries/Strings.sol";


/**
*Side chain bridge contract
*/

/**
* This is the basic wrapped Ether to a different chain contract. 
* All money deposited is transformed into ERC20 tokens at the rate of 1 wei = 1 token
* You push money when you transfer (delete money here).  If it doesn't go through, 
* you can check to see if transfer ID went through
*/
contract DappBridge is usingOraclize, Wrapped_Token{

    using SafeMath for uint256;

    /***Variables***/
    string public bridgedChain;
    uint transNonce;
    string public partnerBridge; //address of bridge contract on other chain
    string api;
    string parameters;
    address public owner;
    bytes4 method_data;
    uint public public_fund;

    struct Details{
        uint amount;
        address owner;
        uint transferId;
    }
    
    /***Storage**/
    mapping(uint => Details) transferDetails; //maps a transferId to an amount
    mapping(address => uint[]) transferList; //list of all transfers from an address;
    mapping(uint => bool) pulledTransaction;

    /***Events***/
    event Locked(uint _id,address _from, uint _value);
    event LogUpdated(string value);
    event LogNewOraclizeQuery(string description);

    /***Functions***/
    constructor() public  {
        owner = msg.sender;
    }
    
    //enter your custom OAR here:
    function setOAR(address _oar) public onlyOwner() {
        OAR = OraclizeAddrResolverI(_oar);
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
    function lockForTransfer(uint _amount) public returns(uint){
        transNonce += 1;
        require (balances[msg.sender] >= _amount && _amount > 0);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        total_supply = total_supply.sub(_amount);
        transferDetails[transNonce] = Details({
            amount:_amount,
            owner:msg.sender,
            transferId:transNonce
        });
       transferList[msg.sender].push(transNonce);
               emit Locked(transNonce,msg.sender,_amount);
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
            oraclize_query("URL",api,_params, 3000000);
       }
    }

    /**
    * @dev This function is called from the main chain through its 4-byte code 
    * address through the oraclize function within the CheckChild function in the main chain
    */
    function getTransfer(uint _transferId) public view returns(uint,address,uint){
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
        string memory _params2 = strConcat(' {"jsonrpc":"2.0","id":60,"method":"eth_call","params":[{"to":',_code);
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
    function __callback(bytes32 myid, string result) public{
        require (msg.sender == oraclize_cbAddress());
        uint startIdx = 0;
        if(Strings.hasZeroXPrefix(result)) {
            startIdx = 2;
        }
        bytes memory bts = bytes(result);
        //take the first 64 bytes and convert to uint
        uint _amount = Strings.hexToUint(Strings.substr(result, startIdx,64+startIdx));
        //id is at the end and will be 64 bytes. So grab its starting idx first.
        uint idStart = bts.length - 64;
        //the address portion will end where the id starts.
        uint addrEnd = idStart;
        //parse the last 40 bytes of the address hex.
        address _owner = Strings.parseAddr(Strings.substr(result, addrEnd-40, addrEnd));
        //then extract the id
        uint _transId = Strings.hexToUint(Strings.substr(result, idStart, bts.length));
        require(pulledTransaction[_transId] == false);
        balances[_owner] = balances[_owner].add(_amount);
        total_supply = total_supply.add(_amount);
        pulledTransaction[_transId] = true;
        emit LogUpdated(result);
        if (public_fund > 1e17){
            _owner.transfer(1e17);
        }
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

    function fund() public payable(){

    }

}
