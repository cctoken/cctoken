'use strict';

var CRCToken= artifacts.require("./helper/CRCTokenMock.sol");
const assertJump=require('zeppelin-solidity/test/helpers/assertJump');
var BigNumber = require("bignumber.js");

var MAX_SUPPLY = 100000000000000000000000000;
var quota = MAX_SUPPLY/100;
var allOfferingQuota = quota*50;
var teamKeepingQuota = quota*15;
var communityContributionQuota = quota*35;
var fundingStartBlock=5000000;
var fundingEndBlock =fundingStartBlock+100800;
var teamKeepingLockEndBlock = fundingEndBlock + 31536000;
var privateOfferingPercentage = 10;
var privateOfferingCap = quota*10;

var publicOfferingExchangeRate = 5000;
var privateOfferingExchangeRate = 10000;

async function setup_crctoken(accounts) {

    let cct=await CRCToken.new({from:accounts[0]});
    await cct.setEtherProceedsAccount(accounts[9],{from:accounts[0]});
    await cct.setCrcWithdrawAccount(accounts[1],{from:accounts[0]});

    await cct.setName("hehehehe",{from:accounts[0]});
    await cct.setSymbol("CRCMock",{from:accounts[0]});
    await cct.setFundingStartBlock(fundingStartBlock,{from:accounts[0]});
    return cct;
}

function ether_towei_rate(value){
    return web3.toWei(value,'ether');
}

contract('CRCToken', function (accounts) {
        it("构建合约-期望成功，应该有正确的版本号和名称信息",async function () {
            let cct= await setup_crctoken(accounts);
            await cct.setEtherProceedsAccount(accounts[8],{from:accounts[0]});
            await cct.setCrcWithdrawAccount(accounts[7],{from:accounts[0]});

            await cct.setName("hehehehe2",{from:accounts[0]});
            await cct.setSymbol("CRCMock2",{from:accounts[0]});
            await cct.setFundingStartBlock(999,{from:accounts[0]});


            let name= await cct.name();
            let version=await cct.version();
            let symbol=await cct.symbol();
            let startBlock=await cct.fundingStartBlock();
            let fundingEndBlock=await  cct.fundingEndBlock();
            let teamKeepingLockEndBlock=await cct.teamKeepingLockEndBlock();
            let etherProceedsAccount=await cct.etherProceedsAccount();
            let crcWithdrawAccount=await cct.crcWithdrawAccount();

            assert.equal("hehehehe2",name);
            assert.equal("1.0",version);
            assert.equal("CRCMock2",symbol);
            assert.equal(999,startBlock);
            assert.equal(999+100800,fundingEndBlock);
            assert.equal(999+100800+31536000,teamKeepingLockEndBlock);
            assert.equal(accounts[8],etherProceedsAccount);
            assert.equal(accounts[7],crcWithdrawAccount);
        });


    it("构建合约-期望失败，非owner无法修改基本信息",async function () {
        let cct= await setup_crctoken(accounts);
        try {
            await cct.setEtherProceedsAccount(accounts[8],{from:accounts[2]});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        try {
            await cct.setCrcWithdrawAccount(accounts[7],{from:accounts[2]});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        try {
            await cct.setName("hehehehe2",{from:accounts[2]});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        try {
            await cct.setSymbol("CRCMock2",{from:accounts[2]});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        try {
            await cct.setFundingStartBlock(999,{from:accounts[2]});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let name= await cct.name();
        let version=await cct.version();
        let symbol=await cct.symbol();
        let startBlock=await cct.fundingStartBlock();
        let fundingEndBlock=await  cct.fundingEndBlock();
        let teamKeepingLockEndBlock=await cct.teamKeepingLockEndBlock();
        let etherProceedsAccount=await cct.etherProceedsAccount();
        let crcWithdrawAccount=await cct.crcWithdrawAccount();

        assert.equal("hehehehe",name);
        assert.equal("1.0",version);
        assert.equal("CRCMock",symbol);
        assert.equal(fundingStartBlock,startBlock);
        assert.equal(fundingStartBlock+100800,fundingEndBlock);
        assert.equal(fundingStartBlock+100800+31536000,teamKeepingLockEndBlock);
        assert.equal(accounts[9],etherProceedsAccount);
        assert.equal(accounts[1],crcWithdrawAccount);
    });

    it("私募-期望成功，因为还没到最早开始区块",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock-1);

        await cct.sendTransaction({from:accounts[5],value:100000000000000000000});

        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let privateOfferingSupply =await cct.privateOfferingSupply();
        assert.equal(10000000000000000000000,balance.toNumber());
        assert.equal(10000000000000000000000,totalSupply.toNumber());
        assert.equal(10000000000000000000000,allOfferingSupply.toNumber());
        assert.equal(10000000000000000000000,privateOfferingSupply.toNumber());
    });

    it("公开募集-期望失败，因为已经过了最后众筹区块",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(fundingEndBlock+1);

        try {
            await web3.eth.sendTransaction({from:accounts[5],to:cct.address(),value:1000000000000000000});
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
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        await web3.eth.sendTransaction({from:accounts[5],to:cct.address(),value:1000000000000000000});
        await web3.eth.sendTransaction({from:accounts[5],to:cct.address(),value:2000000000000000000});
        await web3.eth.sendTransaction({from:accounts[6],to:cct.address(),value:2000000000000000000});
        await web3.eth.sendTransaction({from:accounts[7],to:cct.address(),value:4500000000000000000});
        let balance5 = await cct.balanceOf(accounts[5]);
        let balance6 = await cct.balanceOf(accounts[6]);
        let balance7 = await cct.balanceOf(accounts[7]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(15000000000000000000000,balance5.toNumber());
        assert.equal(10000000000000000000000,balance6.toNumber());
        assert.equal(22500000000000000000000,balance7.toNumber());
        assert.equal(47500000000000000000000,totalSupply.toNumber());
        assert.equal(47500000000000000000000,allOfferingSupply.toNumber());
    });

    it("公开募集-期望成功，未超过allOffering数额",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        await web3.eth.sendTransaction({from:accounts[5],to:cct.address(),value:10000000000000000000000});
        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(allOfferingQuota,balance.toNumber());
        assert.equal(allOfferingQuota,totalSupply.toNumber());
        assert.equal(allOfferingQuota,allOfferingSupply.toNumber());
    });

    it("公开募集-期望失败，超过allOffering数额",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        await web3.eth.sendTransaction({from:accounts[5],to:cct.address(),value:10000000000000000000000});
        try{
            await web3.eth.sendTransaction({from:accounts[5],to:cct.address(),value:1000000000000000000});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[5]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(allOfferingQuota,balance.toNumber());
        assert.equal(allOfferingQuota,totalSupply.toNumber());
        assert.equal(allOfferingQuota,allOfferingSupply.toNumber());
    });


    it("公开募集-期望失败，超过allOffering数额",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock+1);
        try{
            await web3.eth.sendTransaction({from:accounts[5],to:cct.address(),value:11000000000000000000000});
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



    it("团队提现-期望失败，因为还没到过锁定期",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock-1);

        try {
            await cct.teamKeepingWithdraw(100,{from:accounts[1],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();

        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,teamWithdrawSupply.toNumber());

    });

    it("团队提现-期望失败，因为非专用账户操作",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock+1);

        try {
            await cct.teamKeepingWithdraw(100,{from:accounts[6],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[6]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();

        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,teamWithdrawSupply.toNumber());

    });

    it("团队提现-期望失败，超过提现额度",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock+1);
        await cct.teamKeepingWithdraw(ether_towei_rate(15000000),{from:accounts[1],value:0});
        try {
            await cct.teamKeepingWithdraw(ether_towei_rate(1),{from:accounts[1],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();
        assert.equal(15000000000000000000000000,totalSupply.toNumber());
        assert.equal(15000000000000000000000000,balance.toNumber());
        assert.equal(15000000000000000000000000,teamWithdrawSupply.toNumber());
    });


    it("团队提现-期望成功",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock+1);
        await cct.teamKeepingWithdraw(ether_towei_rate(15000000),{from:accounts[1],value:0});
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();
        assert.equal(15000000000000000000000000,balance.toNumber());
        assert.equal(15000000000000000000000000,totalSupply.toNumber());
        assert.equal(15000000000000000000000000,teamWithdrawSupply.toNumber());
    });

    it("团队提现-期望成功但额度不变，因为提取值为0",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(teamKeepingLockEndBlock+1);
        await cct.teamKeepingWithdraw(ether_towei_rate(0),{from:accounts[1],value:0});
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let teamWithdrawSupply =await  cct.teamWithdrawSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,teamWithdrawSupply.toNumber());
    });


    it("社区提现-期望失败，因为非专用账户操作",async function(){
        let cct = await setup_crctoken(accounts);
        try {
            await cct.communityContributionWithdraw(100,{from:accounts[8],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[8]);
        let totalSupply=await cct.totalSupply();
        let communityContributionSupply =await  cct.communityContributionSupply();

        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,communityContributionSupply.toNumber());

    });


    it("社区提现-期望失败，超过提现额度",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.communityContributionWithdraw(ether_towei_rate(35000000),{from:accounts[1],value:0});
        try {
            await cct.communityContributionWithdraw(ether_towei_rate(1),{from:accounts[1],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let communityContributionSupply =await  cct.communityContributionSupply();
        assert.equal(35000000000000000000000000,totalSupply.toNumber());
        assert.equal(35000000000000000000000000,balance.toNumber());
        assert.equal(35000000000000000000000000,communityContributionSupply.toNumber());
    });


    it("社区提现-期望成功",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.communityContributionWithdraw(ether_towei_rate(35000000),{from:accounts[1],value:0});
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let communityContributionSupply =await  cct.communityContributionSupply();
        assert.equal(35000000000000000000000000,balance.toNumber());
        assert.equal(35000000000000000000000000,totalSupply.toNumber());
        assert.equal(35000000000000000000000000,communityContributionSupply.toNumber());
    });

    it("社区提现-期望成功,但额度不变,因为提取值为0",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.communityContributionWithdraw(ether_towei_rate(0),{from:accounts[1],value:0});
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let communityContributionSupply =await  cct.communityContributionSupply();
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,communityContributionSupply.toNumber());
    });

    it("平台提现-期望失败，因为非专用账户操作",async function(){
        let cct = await setup_crctoken(accounts);
        try {
            await cct.icoPlatformWithdraw(100,{from:accounts[8],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[8]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();

        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());
        assert.equal(0,allOfferingSupply.toNumber());
    });


    it("平台提现-期望失败，超过提现额度",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.icoPlatformWithdraw(ether_towei_rate(50000000),{from:accounts[1],value:0});
        try {
            await cct.icoPlatformWithdraw(ether_towei_rate(1),{from:accounts[1],value:0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        }catch (error){
            assertJump(error);
        }
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(50000000000000000000000000,allOfferingSupply.toNumber());
        assert.equal(50000000000000000000000000,totalSupply.toNumber());
        assert.equal(50000000000000000000000000,balance.toNumber());


    });

    it("平台提现-期望成功",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.icoPlatformWithdraw(ether_towei_rate(50000000),{from:accounts[1],value:0});
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(50000000000000000000000000,allOfferingSupply.toNumber());
        assert.equal(50000000000000000000000000,balance.toNumber());
        assert.equal(50000000000000000000000000,totalSupply.toNumber());

    });

    it("平台提现-期望成功,但额度不变,因为提取值为0",async function(){
        let cct = await setup_crctoken(accounts);
        await cct.icoPlatformWithdraw(ether_towei_rate(0),{from:accounts[1],value:0});
        let balance = await cct.balanceOf(accounts[1]);
        let totalSupply=await cct.totalSupply();
        let allOfferingSupply =await  cct.allOfferingSupply();
        assert.equal(0,allOfferingSupply.toNumber());
        assert.equal(0,balance.toNumber());
        assert.equal(0,totalSupply.toNumber());

    });

    it("提取eth-期望失败，非eth管理账户操作", async function () {
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock + 1);
        await web3.eth.sendTransaction({from:accounts[8],to:cct.address(),value:10000000000000000000000});
        try {
            await cct.etherProceeds({from: accounts[5], value: 0});
            //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
            assert(false);
        } catch (error) {
            assertJump(error);
        }
        let balance = await web3.eth.getBalance(accounts[9]);
        assert.equal(1000000000000000000, balance.toNumber());
    });


    it("提取eth-期望成功", async function () {
        let cct = await setup_crctoken(accounts);
        await cct.setCurrentBlockNum(fundingStartBlock + 1);
        await web3.eth.sendTransaction({from:accounts[8],to:cct.address(),value:10000000000000000000000});
        let contractBalance1 = await web3.eth.getBalance(cct.address);
        assert.equal(10000000000000000000000,contractBalance1.toNumber());

        await cct.etherProceeds({from: accounts[9], value: 0});
        let balance = await web3.eth.getBalance(accounts[9]);
        let contractBalance = await web3.eth.getBalance(cct.address);
        assert(10000000000000000000000>balance.toNumber());
        assert(9000000000000000000000<balance.toNumber());
        assert.equal(0,contractBalance.toNumber());
    });


})