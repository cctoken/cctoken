// var SafeMath = artifacts.require("zeppelin-solidity/contracts/math/SafeMath.sol");
// var StandardToken = artifacts.require("zeppelin-solidity/contracts/token/StandardToken.sol");
// var BasicToken = artifacts.require("zeppelin-solidity/contracts/token/BasicToken.sol");
// var ERC20 = artifacts.require("zeppelin-solidity/contracts/token/ERC20.sol");
// var ERC20Basic = artifacts.require("zeppelin-solidity/contracts/token/ERC20Basic.sol");
// var Ownable = artifacts.require("zeppelin-solidity/contracts/ownership/Ownable.sol");
var CCToken = artifacts.require("./CCToken.sol");


module.exports = function(deployer) {
  // deployer.deploy(SafeMath);
  // deployer.deploy(StandardToken);
  // deployer.deploy(BasicToken);
  // deployer.deploy(ERC20);
  // deployer.deploy(ERC20Basic);
  // deployer.deploy(Ownable);
  // deployer.link(SafeMath,CCToken);
  deployer.deploy(CCToken);
};
