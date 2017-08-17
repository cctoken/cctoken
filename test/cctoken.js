'use strict';


var CCtoken = artifacts.require("./CCToken.sol");
var CCtokenMock = artifacts.require("./helper/CCTokenMock.sol");
const assertJump=require('zeppelin-solidity/test/helpers/assertJump');

async function setup_cctoken() {
    return await CCtoken.new();
}

contract('CCToken', function (accounts) {
        it("should have correct version data",async function () {
            let cct= await setup_cctoken();
            let name= await cct.name();
            let version=await cct.version();
            assert.equal("CCToken",name);
            assert.equal("1.0",version);
        });

    it("should have correct inited data",async function () {
        let cct= await function(){
            return CCtoken.new(4000000 , 4100000,6000000,accounts[0],accounts[1],accounts[2],accounts[3],accounts[4]);
        }();
        assert.equal("CCToken",await cct.name());
        assert.equal(4000000,await cct.fundingStartBlock());
        assert.equal(4100000,await cct.fundingEndBlock());
        assert.equal(6000000,await cct.teamKeepingLockEndBlock());
        assert.equal(accounts[0],await cct.etherProceedsAccount());
        assert.equal(accounts[1],await cct.btcEthFundingAccount());
        assert.equal(accounts[2],await cct.privateEthFundingAccount());
        assert.equal(accounts[3],await cct.teamWithdrawAccount());
        assert.equal(accounts[4],await cct.communityContributionAccount());

        assert.equal(0,await cct.totalSupply());
        assert.equal(0,await cct.btcEthSupply());
        assert.equal(0,await cct.privateOfferingSupply());
        assert.equal(0,await cct.allOfferingSupply());
        assert.equal(0,await cct.communityContributionSupply());
        assert.equal(0,await cct.teamWithdrawSupply());
    });
    it("should be a exp because of the starting block",async function(){
        let cct = await CCtokenMock.new();
       //
       //  await cct.setCurrentBlockNum(3000000);
       //
       // try {
       //      cct.processEthPulicFunding();
       // }
       // catch (error){
       //
       // }

    });

    }
);