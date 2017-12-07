var WCToken = artifacts.require("./WCToken.sol");

module.exports = function(deployer) {
  deployer.deploy(WCToken);
};
