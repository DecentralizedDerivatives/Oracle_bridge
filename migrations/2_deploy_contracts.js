var Wrapped_Token = artifacts.require("./Wrapped_Token.sol");
 
module.exports = function(deployer) {
  deployer.deploy(Wrapped_Token);
};
