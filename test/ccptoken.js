'use strict';

var CCPToken= artifacts.require("CCPToken.sol");
const assertJump=require('zeppelin-solidity/test/helpers/assertJump');
var BigNumber = require("bignumber.js");

var MAX_SUPPLY = 10000000000000000000000000000;

async function setup_ccptoken(accounts) {

    let ccp=await CCPToken.new({from:accounts[0]});
    return ccp;
}

function ether_towei_rate(value){
    return web3.toWei(value,'ether');
}

contract('CRCToken', function (accounts) {
        it("构建合约-期望成功，应该有正确的版本号和名称信息",async function () {
            let ccp= await setup_ccptoken(accounts);
         
            let name= await ccp.name();
            let version=await ccp.version();
            let symbol=await ccp.symbol();

            assert.equal("CoalaCoin Point",name);
            assert.equal("1.0",version);
            assert.equal("CCP",symbol);

            let totalSupply=await ccp.totalSupply();
            assert.equal(0,totalSupply.toNumber());

        });

        it("积分分发-期望成功",async function () {
            let ccp= await setup_ccptoken(accounts);
         
            await ccp.distribute(accounts[1],10000000000000000000000000000,{from:accounts[0]});

            let totalSupply=await ccp.totalSupply();
            assert.equal(10000000000000000000000000000,totalSupply.toNumber());

            let accounts1Balance= await ccp.balanceOf(accounts[1]);
            assert.equal(10000000000000000000000000000,accounts1Balance.toNumber());

        });     
        
        it("积分分发-期望失败：不是合约owner发起",async function () {
            let ccp= await setup_ccptoken(accounts);

            try {
                await ccp.distribute(accounts[1],10000000000000000000000000000,{from:accounts[2]});
                //因为期望抛异常，故不会进入这里，若进入，则单元测试失败
                assert(false);
            }catch (error){
                assertJump(error);
            }

            let totalSupply=await ccp.totalSupply();
            assert.equal(0,totalSupply.toNumber());

            let accounts1Balance= await ccp.balanceOf(accounts[1]);
            assert.equal(0,accounts1Balance.toNumber());

        });            
})