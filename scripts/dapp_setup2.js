/*Deploys a new dappBridge and sets the API (and OAR if necessary)*/

var DappBridge = artifacts.require("./DappBridge.sol");
import Addresses from "./file_addresses.js";

let dappBridge;

var addresses = Addresses.getAddresses();

module.exports =async function(callback) {
	  dappBridge = await DappBridge.at(addresses.dapp);
      await dappBridge.setPartnerBridge(addresses.bridge);
}