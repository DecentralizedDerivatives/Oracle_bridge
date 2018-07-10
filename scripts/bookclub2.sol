ragma solidity ^0.4.21;
//Working
// {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":"0x8276c4012116588547da5ce1e936fee6d2a99350","data":"0xa230c524000000000000000000000000931b582d4573284193cbfbe5e76bd41405961be8"},"latest"]}

import "./Oraclize/Oraclize_API.sol";
import "./libraries/SafeMath.sol";

contract BookClub is usingOraclize{

    using SafeMath for uint256;

  mapping(address => bool) members;
  mapping(address => uint) reputation;
  mapping(address => uint) rating;
  address nextInLine;
  mapping(uint => Details) matches;
  struct Details{
    address maker;
    address taker;
    uint matchId;
  }

    struct UserDetails{
    string email;
    string preferences;
    string booksAvailable;
  }

  mapping(address => UserDetails) userInfo;
  struct VoteDetails{
    address traitor;
    uint start;
    uint yays;
    uint nays;
  }




  mapping(uint => VoteDetails) votes;
  uint vote_nonce;
  uint membersCount;
  uint stake;
  mapping(address => address) matched;
  mapping (bytes32 => address) query;
  
  //Bridge Functionality

  string private partnerBridge; //address of bridge contract on other chain
  string private api;
  string private parameters;
  uint public lastValue;
  bytes4 private method_data;
  mapping(address => uint) departingBalance;

  event Print(string _issue);
  event Matched(address,address);
  event NewMember(address _newbie);
  event MemberLeaving(address);


  function BookClub() public{
    vote_nonce = 0;
    method_data = this.isMember.selector;
    setAPI("json(https://rinkeby.infura.io/).result");
  }
  


  function requestNewBook() public {
    if(nextInLine == address(0)){
      nextInLine = msg.sender;
    }
    else{
      matched[nextInLine] = msg.sender;
      matched[msg.sender] = nextInLine;
      reputation[nextInLine] += 1;
      reputation[msg.sender] += 1;
      emit Matched(nextInLine,msg.sender);
      nextInLine = address(0);
    }
  }

  /*rate the user you were matched with*/
  function rateUser(address _user, uint _rating) public {
    require(matched[msg.sender] == _user && _rating <= 5);
    rating[_user] = (rating[_user]*reputation[_user] + _rating) / (reputation[_user] + 1);
  }
  
  function setUserInfo(string _email,string _pref, string _books) public {
    userInfo[msg.sender] = UserDetails({
      email:_email,
      preferences:_pref,
      booksAvailable:_books
      });
  }

  function getUserInfo(address _member) public constant returns(string,string,string){
    UserDetails memory _user = userInfo[_member];
    return(_user.email,_user.preferences,_user.booksAvailable);
  }

  function isMember(address _user) public constant returns(bool){
    return members[_user];
  }

  function getRating(address _user) public constant returns(uint){
    return rating[_user];
    }
  function getReputation(address _user) public constant returns(uint){
    return reputation[_user];
    }


  /*can vote to kick someone out*/
  function initiateVote(address _traitor) public {
    require(members[msg.sender]);
    votes[vote_nonce].traitor = _traitor;
    votes[vote_nonce].start = now;
    votes[vote_nonce].yays = 0;
    votes[vote_nonce].nays = 0;
    vote_nonce++;
  }
  function settleVote(uint _id) public {
    VoteDetails memory _vote = votes[_id];
    require(votes[_id].start <= now + 86400*14);
    if(_vote.yays > _vote.nays){
      removeMember(_vote.traitor);
    }
  }

  function vote(uint _id,bool _true_for_yay) public {
    VoteDetails memory _vote = votes[_id];
    require(_vote.start >= now - 86400*14);
    if(_true_for_yay){
      _vote.yays += 1;
    }
    else{
      _vote.nays += 1;
    }
  }


  //How do we put in a timelock or not let anyone just leave?
  function leaveBookClub() public {
    removeMember(msg.sender);
  }

  function removeMember(address _traitor) internal{
    members[_traitor] = false;
    emit MemberLeaving(_traitor);
    membersCount -= 1;
    departingBalance[_traitor] = 1;
  }

//Need to change callback to accept bool as result
    function __callback(bytes32 myid, string result){
        //require(msg.sender == oraclize_cbAddress());
        //lastValue = parseInt(result);
        //if(lastValue > 0){
          address _user = query[myid];
          members[_user] = true;
          emit NewMember(_user);
          membersCount += 1;
        //}
    }


    function checkMain(address _user)public payable {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit Print("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit Print("Oraclize query was sent, standing by for the answer..");
            string memory _n_user = toAsciiString(_user);
            string memory _params = createQuery_value(_n_user);
             bytes32 queryId = oraclize_query("URL",api,_params, 1000000);
             query[queryId] = _user;
        }
      }

    function createQuery_value(string _member_address) public constant returns(string){
      string memory _code = strConcat(fromCode(method_data),"000000000000000000000000",_member_address);
      string memory _part = ' {"jsonrpc":"2.0","id":3,"method":"eth_call","params":[{"to":';
      string memory _params2 = strConcat(_part,partnerBridge,',"data":"',_code,'"},"latest"]}');
      emit Print(_params2);
      return _params2;
    }


  function setPartnerBridge(string _connected) public{
    partnerBridge =  strConcat('"',_connected,'"');
  }
  
  function setAPI(string _api) public{
      api = _api; 
  }

  function departingMember(address _former) public returns(uint){
    return departingBalance[_former];
  }

    function fromCode(bytes4 code) internal view returns (string) {                                                                                    
    bytes memory result = new bytes(10);                                                                                                         
    result[0] = byte('0');
    result[1] = byte('x');
    for (uint i=0; i<4; ++i) {
        result[2*i+2] = toHexDigit(uint8(code[i])/16);
        result[2*i+3] = toHexDigit(uint8(code[i])%16);
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

function toAsciiString(address x) internal returns (string) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        byte hi = byte(uint8(b) / 16);
        byte lo = byte(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);            
    }
    return string(s);
}
function char(byte b) internal returns (byte c) {
    if (b < 10) return byte(uint8(b) + 0x30);
    else return byte(uint8(b) + 0x57);
}
}