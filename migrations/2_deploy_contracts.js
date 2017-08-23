var CDToken = artifacts.require("./CDToken.sol");

module.exports = function(deployer) {
  deployer.deploy(CDToken);
};
