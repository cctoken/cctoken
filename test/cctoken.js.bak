'use strict';


var CCtoken = artifacts.require("./helper/CCTokenMock.sol");
const assertJump=require('zeppelin-solidity/test/helpers/assertJump');
var BigNumber = require("bignumber.js");

var MAX_SUPPLY = 1000000000000000000000000000;
var quota = MAX_SUPPLY/100;
var allOfferingQuota = quota*70;
var teamKeepingQuota = quota*15;
var communityContributionQuota = quota*15;
var fundingStartBlock=4000000;
var fundingEndBlock =fundingStartBlock+100800;
var teamKeepingLockEndBlock = fundingEndBlock + 31536000;
var privateOfferingPercentage = 10;
var privateOfferingCap = quota*10;
var btcChannelCap = allOfferingQuota/10;



async function setup_cctoken(accounts) {

    let cct=await CCtoken.new({from:accounts[0]});
    await cct.setEtherProceedsAccount(accounts[9]);
    await cct.setBtcEthFundingAccount(accounts[1]);
    await cct.setPrivateEthFundingAccount(accounts[2]);
    await cct.setTeamWithdrawAccount(accounts[3]);
    await cct.setCommunityContributionAccount(accounts[4]);

    return cct;
}

function ether_towei_rate(value){
    return web3.toWei(value,'ether');
}

contract('CCToken', function (accounts) {
        it("构建合约-期望成功，应该有正确的版本号和名称信息",async function () {
            let cct= await setup_cctoken(accounts);
            let name= await cct.name();
            let version=await cct.version();
            assert.equal("CCToken",name);
            assert.equal("1.0",version);
        });


    it("公开募集-期望失败，因为还没到最早开始区块",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);

       try {
           await cct.processEthPulicFunding({from:accounts[5],value:1000000000000000000});
           //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
           assert(false);
       }catch (error){
            assertJump(error);
       }
        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
    });

    it("公开募集-期望失败，因为已经过了最后众筹区块",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingEndBlock+1);

        try {
            await cct.processEthPulicFunding({from:accounts[5],value:1000000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());

    });

    it("公开募集-期望失败，因为传入eth小于1eth",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);

        try {
            await cct.processEthPulicFunding({from:accounts[5],value:990000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
    });


    it("公开募集-期望成功，因为在期望区块范围内",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        await cct.processEthPulicFunding({from:accounts[5],value:1000000000000000000});
        await cct.processEthPulicFunding({from:accounts[5],value:2000000000000000000});
        await cct.processEthPulicFunding({from:accounts[6],value:2000000000000000000});
        await cct.processEthPulicFunding({from:accounts[7],value:4500000000000000000});
        let balance5 = await cct.balanceOf(accounts[5]);
        let balance6 = await cct.balanceOf(accounts[6]);
        let balance7 = await cct.balanceOf(accounts[7]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(45000000000000000000000,balance5.toNumber());
        assert.equal(30000000000000000000000,balance6.toNumber());
        assert.equal(67500000000000000000000,balance7.toNumber());
        assert.equal(142500000000000000000000,totalSupply.toNumber());
        assert.equal(142500000000000000000000,allOfferingSupply.toNumber());
    });

    it("公开募集-期望成功，未超过allOffering数额",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        await cct.processEthPulicFunding({from:accounts[5],value:46666000000000000000000});
        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert(allOfferingQuota>=balance.toNumber());
        assert(allOfferingQuota>=totalSupply.toNumber());
        assert(allOfferingQuota>=allOfferingSupply.toNumber());
    });

    it("公开募集-期望失败，超过allOffering数额",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        await cct.processEthPulicFunding({from:accounts[5],value:46666000000000000000000});
        try{
            await cct.processEthPulicFunding({from:accounts[5],value:1000000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }

        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert(allOfferingQuota>=balance.toNumber());
        assert(allOfferingQuota>=totalSupply.toNumber());
        assert(allOfferingQuota>=allOfferingSupply.toNumber());
    });


    it("公开募集-期望失败，超过allOffering数额",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        try{
            await cct.processEthPulicFunding({from:accounts[5],value:46667000000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }

        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
    });



    it("btc募集-期望失败，已经超过开始公募区块",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        try {
            await cct.processBtcPulicFunding({from:accounts[1],value:1000000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let btcEthSupply =await  cct.btcEthSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,btcEthSupply.toNumber());
    });

    it("btc募集-期望失败，未使用btc募集账户",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);
        try {
        await cct.processBtcPulicFunding({from:accounts[5],value:1000000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let btcEthSupply =await  cct.btcEthSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,btcEthSupply.toNumber());

    });

    it("btc募集-期望失败,传入eth小于1eth",async function(){
        let cct = await setup_cctoken(accounts);
        try{
            await cct.setCurrentBlockNum(fundingStartBlock-1);
            await cct.processBtcPulicFunding({from:accounts[1],value:990000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let btcEthSupply =await  cct.btcEthSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,btcEthSupply.toNumber());

    });

    it("btc募集-期望成功",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);
        await cct.processBtcPulicFunding({from:accounts[1],value:1000000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let btcEthSupply =await  cct.btcEthSupply();
        assert.equal(15000000000000000000000,balance.toNumber());
        assert.equal(15000000000000000000000,totalSupply.toNumber());
        assert.equal(15000000000000000000000,allOfferingSupply.toNumber());
        assert.equal(15000000000000000000000,btcEthSupply.toNumber());

    });

    it("btc募集-期望成功，未超过btc募集上限",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);
            await cct.processBtcPulicFunding({from:accounts[1],value:4666600000000000000000});
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let btcEthSupply =await  cct.btcEthSupply();
        assert(btcChannelCap>=balance.toNumber());
        assert(btcChannelCap>=totalSupply.toNumber());
        assert(btcChannelCap>=allOfferingSupply.toNumber());
        assert(btcChannelCap>=btcEthSupply.toNumber());
        assert(balance.toNumber()>0);

    });

    it("btc募集-期望失败，超过btc募集上限",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);
        try{
            await cct.processBtcPulicFunding({from:accounts[1],value:4666700000000000000000});
            assert(false);
        }catch (error){
            assertJump(error);
        }
        //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let btcEthSupply =await  cct.btcEthSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,btcEthSupply.toNumber());

    });








    it("私募-期望失败，已经超过开始公募区块",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        try {
            await cct.processPrivateFunding({from:accounts[2],value:1000000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[2]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let privateOfferingSupply =await  cct.privateOfferingSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,privateOfferingSupply.toNumber());
    });

    it("私募-期望失败，未使用私募集账户",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);
        try {
            await cct.processPrivateFunding({from:accounts[5],value:1000000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let privateOfferingSupply =await  cct.privateOfferingSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,privateOfferingSupply.toNumber());

    });

    it("私募-期望失败,传入eth小于1eth",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);
        try{
        await cct.processPrivateFunding({from:accounts[2],value:990000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
        let balance = await cct.balanceOf(accounts[2]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let privateOfferingSupply =await  cct.privateOfferingSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,privateOfferingSupply.toNumber());

    });
    it("私募-期望成功",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);
        await cct.processPrivateFunding({from:accounts[2],value:1000000000000000000});
        //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
        let balance = await cct.balanceOf(accounts[2]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let privateOfferingSupply =await  cct.privateOfferingSupply();
        assert.equal(45000000000000000000000,balance.toNumber());
        assert.equal(45000000000000000000000,totalSupply.toNumber());
        assert.equal(45000000000000000000000,allOfferingSupply.toNumber());
        assert.equal(45000000000000000000000,privateOfferingSupply.toNumber());

    });

    it("私募-期望成功，未超过私募集上限",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);
        await cct.processPrivateFunding({from:accounts[2],value:2222200000000000000000});
        let balance = await cct.balanceOf(accounts[2]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let privateOfferingSupply =await  cct.privateOfferingSupply();
        assert(privateOfferingCap>=balance.toNumber());
        assert(privateOfferingCap>=totalSupply.toNumber());
        assert(privateOfferingCap>=allOfferingSupply.toNumber());
        assert(privateOfferingCap>=privateOfferingSupply.toNumber());
        assert(balance.toNumber()>0);

    });

    it("私募-期望失败，超过私募集上限",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);
        try{
            await cct.processPrivateFunding({from:accounts[2],value:2366700000000000000000});
            assert(false);
        }catch (error){
            assertJump(error);
        }
        //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
        let balance = await cct.balanceOf(accounts[2]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let privateOfferingSupply =await  cct.privateOfferingSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,privateOfferingSupply.toNumber());

    });



    it("团队提现-期望失败，因为还没到过锁定期",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock-1);

        try {
            await cct.teamKeepingWithdraw(100,{from:accounts[0],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[3]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();

        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,teamWithdrawSupply.toNumber());

    });

    it("团队提现-期望失败，因为非owner操作",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock+1);

        try {
            await cct.teamKeepingWithdraw(100,{from:accounts[1],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[3]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();

        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,teamWithdrawSupply.toNumber());

    });



    it("团队提现-期望失败，超过提现额度",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock+1);
        await cct.teamKeepingWithdraw(ether_towei_rate(150000000),{from:accounts[0],value:0});
        try {
            await cct.teamKeepingWithdraw(ether_towei_rate(1),{from:accounts[0],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[3]);
        let totalSupply=await cct.totalSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();
        assert.equal(150000000000000000000000000,totalSupply.toNumber());
        assert.equal(150000000000000000000000000,balance.toNumber());
        assert.equal(150000000000000000000000000,teamWithdrawSupply.toNumber());
    });


    it("团队提现-期望成功",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock+1);
        await cct.teamKeepingWithdraw(ether_towei_rate(140000000),{from:accounts[0],value:0});
        await cct.teamKeepingWithdraw(ether_towei_rate(  9999999),{from:accounts[0],value:0});
        let balance = await cct.balanceOf(accounts[3]);
        let totalSupply=await cct.totalSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();
        assert.equal(149999999000000000000000000,balance.toNumber());
        assert.equal(149999999000000000000000000,totalSupply.toNumber());
        assert.equal(149999999000000000000000000,teamWithdrawSupply.toNumber());
    });

    it("团队提现-期望成功但额度不变，因为提取值为0",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock+1);
        await cct.teamKeepingWithdraw(ether_towei_rate(0),{from:accounts[0],value:0});
        let balance = await cct.balanceOf(accounts[3]);
        let totalSupply=await cct.totalSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,teamWithdrawSupply.toNumber());
    });

    it("社区提现-期望失败，因为非owner操作",async function(){
        let cct = await setup_cctoken(accounts);
        try {
            await cct.communityContributionWithdraw(100,{from:accounts[1],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[4]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let communityContributionSupply =await  cct.communityContributionSupply();

        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,communityContributionSupply.toNumber());

    });



    it("社区提现-期望失败，超过提现额度",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.communityContributionWithdraw(ether_towei_rate(150000000),{from:accounts[0],value:0});
        try {
            await cct.communityContributionWithdraw(ether_towei_rate(1),{from:accounts[0],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[4]);
        let totalSupply=await cct.totalSupply();
        let communityContributionSupply =await  cct.communityContributionSupply();
        assert.equal(150000000000000000000000000,totalSupply.toNumber());
        assert.equal(150000000000000000000000000,balance.toNumber());
        assert.equal(150000000000000000000000000,communityContributionSupply.toNumber());
    });


    it("社区提现-期望成功",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.communityContributionWithdraw(ether_towei_rate(140000000),{from:accounts[0],value:0});
        await cct.communityContributionWithdraw(ether_towei_rate(9999999),{from:accounts[0],value:0});
        let balance = await cct.balanceOf(accounts[4]);
        let totalSupply=await cct.totalSupply();
        let communityContributionSupply =await  cct.communityContributionSupply();
        assert.equal(149999999000000000000000000,balance.toNumber());
        assert.equal(149999999000000000000000000,totalSupply.toNumber());
        assert.equal(149999999000000000000000000,communityContributionSupply.toNumber());
    });

    it("社区提现-期望成功,但额度不变,因为提取值为0",async function(){
        let cct = await setup_cctoken(accounts);
        await cct.communityContributionWithdraw(ether_towei_rate(0),{from:accounts[0],value:0});
        let balance = await cct.balanceOf(accounts[4]);
        let totalSupply=await cct.totalSupply();
        let communityContributionSupply =await  cct.communityContributionSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,communityContributionSupply.toNumber());
    });

    it("提取eth-期望失败，非eth管理账户操作", async function () {
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock + 1);
        await  cct.processEthPulicFunding({from: accounts[8], value: 3000000000000000000});
        try {
            await cct.etherProceeds({from: accounts[0], value: 0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        } catch (error) {
            assertJump(error);
        }
        let balance = await web3.eth.getBalance(accounts[9]);
        assert.equal(1000000000000000000, balance.toNumber());
    });


    it("提取eth-期望成功", async function () {
        let cct = await setup_cctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock + 1);
        await  cct.processEthPulicFunding({from: accounts[8], value: 3000000000000000000});
        await  cct.processEthPulicFunding({from: accounts[8], value: 3000000000000000000});
        await  cct.processEthPulicFunding({from: accounts[8], value: 3000000000000000000});
        let contractBalance1 = await web3.eth.getBalance(cct.address);
        assert.equal(9000000000000000000,contractBalance1.toNumber());

        await cct.etherProceeds({from: accounts[9], value: 0});
        let balance = await web3.eth.getBalance(accounts[9]);
        let contractBalance = await web3.eth.getBalance(cct.address);
        assert(10000000000000000000>balance.toNumber());
        assert(9000000000000000000<balance.toNumber());
        assert.equal(0,contractBalance.toNumber());
    });

})