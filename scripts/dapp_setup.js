/*Deploys a new dappBridge and sets the API (and OAR if necessary)*/

var custom_OAR = true;
var OAR = "0x1b55fb1113f59DFe8a6887A0515c27B0B6C037ba";
var _url = "json(http:/54.174.159.43:8540).result"; /*This is the other chains _url*/
var DappBridge = artifacts.require("../contracts/DappBridge.sol");

let dappBridge;
module.exports =async function(callback) {
	web3.eth.getBalance("0xc69c64c226fEA62234aFE4F5832A051EBc860540",(e,r)=>{
		console.log(e,web3.fromWei(r,'ether'));
	});
	//web3.eth.defaultAccount = "0xc69c64c226fEA62234aFE4F5832A051EBc860540";
      try{
      dappBridge =await DappBridge.new();
      if(custom_OAR){
        await dappBridge.setOAR(OAR);
      }
      await dappBridge.setAPI(_url);
      console.log('DappBridge Address', dappBridge.address);
      }
      catch(e){
console.log(e)
      }


}