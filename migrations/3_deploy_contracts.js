var CBCToken = artifacts.require("./CBCToken.sol");

module.exports = function(deployer) {
  deployer.deploy(CBCToken);
};
