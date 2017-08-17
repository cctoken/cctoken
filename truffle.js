require('babel-register');
require('babel-polyfill');

var provider;
var HDWalletProvider=require('truffle-hdwallet-provider');
var mnemonic='[REDACTED]';

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  }
};
