var CCToken = artifacts.require("./CCToken.sol");

module.exports = function(deployer) {
  deployer.deploy(CCToken);
};
