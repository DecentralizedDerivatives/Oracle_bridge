/*Deploys a new bridge and sets the API (and OAR if necessary)*/


var Bridge = artifacts.require("./Bridge.sol");
import Addresses from "./file_addresses.js";

let bridge;

var addresses = Addresses.getAddresses();

module.exports =async function(callback) {
	bridge = await Bridge.at(addresses.bridge)
      await bridge.setPartnerBridge(addresses.dapp);
}