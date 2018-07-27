/*Deploys a new bridge and sets the API (and OAR if necessary)*/

var custom_OAR = true;
var OAR = "0x37dd0a1ceAdC20e81F4A9fd60757240124b3D5B9";
var _url = "json(https://tricky-baboon-7.localtunnel.me).result"; /*This is the other chains _url*/
var Bridge = artifacts.require("./Bridge.sol");

let bridge;
module.exports =async function(callback) {
      bridge =await Bridge.new();
      if(custom_OAR){
        await bridge.setOAR(OAR);
      }
      await bridge.setAPI(local_url);
      console.log('Bridge Address': bridge.address):
}