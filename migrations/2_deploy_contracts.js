var Bridge = artifacts.require("./Bridge.sol");
var TestContract = artifacts.require("./test_contract.sol")
 
module.exports = function(deployer) {
  deployer.deploy(Bridge);
  deployer.deploy(TestContract);

};
