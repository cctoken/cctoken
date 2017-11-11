var CCPToken = artifacts.require("./CCPToken.sol");

module.exports = function(deployer) {
  deployer.deploy(CCPToken);
};
