var FCToken = artifacts.require("./FCToken.sol");

module.exports = function(deployer) {
  deployer.deploy(FCToken);
};
