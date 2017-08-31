var CRCToken = artifacts.require("./CRCToken.sol");

module.exports = function(deployer) {
  deployer.deploy(CRCToken);
};
