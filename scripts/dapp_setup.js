/*Deploys a new dappBridge and sets the API (and OAR if necessary)*/

var custom_OAR = true;
var OAR = "0x37dd0a1ceAdC20e81F4A9fd60757240124b3D5B9";
var _url = "json(https://tricky-baboon-7.localtunnel.me).result"; /*This is the other chains _url*/
var DappBridge = artifacts.require("./DappBridge.sol");

let dappBridge;
module.exports =async function(callback) {
      dappBridge =await DappBridge.new();
      if(custom_OAR){
        await dappBridge.setOAR(OAR);
      }
      await dappBridge.setAPI(local_url);
      console.log('DappBridge Address': dappBridge.address):
}