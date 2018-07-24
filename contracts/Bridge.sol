pragma solidity ^0.4.21;

import "./libraries/SafeMath.sol";
import "./Oraclize/Oraclize_API.sol";
import "./libraries/Strings.sol";
/**
*Main chain bridge contract
*/

contract Bridge is usingOraclize{

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
    
    /***Storage***/
    mapping(address => uint) deposited_balances;
    mapping(uint => Details) transferDetails; //maps a transferId to an amount
    mapping(address => uint[]) transferList; //list of all transfers from an address;
    mapping(uint => bool) pulledTransaction;

    /***Events***/
    event Locked(uint _id,address _from, uint _value);
    event LogUpdated(string value);
    event LogNewOraclizeQuery(string description);

    /***Functions***/
    constructor() public {
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

    //enter your custom OAR here:
    function setOAR(address _oar) public onlyOwner() {
        OAR = OraclizeAddrResolverI(_oar);
    }

    /**
    * @dev Allows for a transfer of tokens to sender once locked
    * The addressDetails memory _locked = transferDetails[_transferId];ss to send tokens to
    * The amount of tokens to send
    */
    function lockForTransfer() payable public returns(uint){
        require(msg.value > 0);
        total_locked = total_locked.add(msg.value);
        transNonce += 1;
        transferDetails[transNonce] = Details({
            amount:msg.value,
            owner:msg.sender,
            transferId:transNonce
        });
        transferList[msg.sender].push(transNonce);
        emit Locked(transNonce,msg.sender,msg.value);
        return(transNonce);
    }

    /**
    * @dev Checks side chain for tokens locked for tranfer through their transferId
    * @param _transferId from locked tokens on the sidechain. It includes the string
    * of parameters including the bytes4 code address of the DappBridge.getTransfer fuction 
    * to get the tranfer details (amount, owner, transferId)
    * TO DO: We need to append address to end of data_string
    */
    function checkChild(uint _transferId) public payable{
        if (oraclize_getPrice("URL") * 2  > msg.value) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogNewOraclizeQuery("Oraclize query was sent for locked balance");
            string memory _parameters  = createQuery_value(_transferId);
            oraclize_query("URL",api, _parameters, 3000000);
            //oraclize_query("URL","json(https://ropsten.infura.io/).result",'{"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x76a83b371ab7232706eac16edf2b726f3a2dbe82","data":"0xad3b80a8"}, "latest"]}');
        }
    }

    /**
    * @dev This function is called from the side chain through its 4-byte code 
    * address through the oraclize function within the CheckChild function in the side chain
    */
    function getTransfer(uint _transferId) public view returns(uint,address,uint){
        Details memory _locked = transferDetails[_transferId];
        return(_locked.amount,_locked.owner,_locked.transferId);
    }

    /**
    * @dev creates a string needed for the oraclize query
    * @param u_id is the transactionId obtained from the DappBridge.CheckSidechain._id
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
    * get the amount, owner, transferID, updates the owner's/sender balance
    * @param myid is the oraclize query ID 
    * @param result is a string of the amount, owner, and transferId from the 
    * DappBridge.getTransfer function
    */
    function __callback(bytes32 myid, string result) public {
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
        deposited_balances[_owner] = deposited_balances[_owner].add(_amount);
        total_deposited_supply = total_deposited_supply.add(_amount);
        pulledTransaction[_transId] = true;
        emit LogUpdated(result);
    }

    /**
    * @dev This function 'unwraps' an _amount of Ether in the sender's balance by 
    * transferring Ether to them
    */
    function withdraw() public {
        require(deposited_balances[msg.sender] >= 0);
        total_deposited_supply = total_deposited_supply.sub(deposited_balances[msg.sender]);
        msg.sender.transfer(deposited_balances[msg.sender]);
    }

    /**
    * @dev Gets the balance associated with the owner
    * @param _owner address
    * @return balance of owner specified
    */
    function depositedBalanceOf(address _owner) public constant returns (uint) { 
        return deposited_balances[_owner]; 
    }

    /**
    * @dev Set partner bridge contract address from the sidechain
    * @param _connected address to sidechain and should be entered as string
    */
    function setPartnerBridge(string _connected) public onlyOwner(){
        partnerBridge = strConcat('"',_connected,'"');
        method_data = this.getTransfer.selector;
    }

    /**
    * @dev Sets API for sidechain
    * @param _api for side chain as string
    * try: "json(https://localhost:8545).result"
    */
    function setAPI(string _api) public onlyOwner(){
        api = _api; //"json(https://ropsten.infura.io/).result"
    }

}
