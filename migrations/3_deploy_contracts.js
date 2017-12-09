var CCMToken = artifacts.require("./CCMToken.sol");
module.exports = function(deployer) {
  deployer.deploy(CCMToken);
};
