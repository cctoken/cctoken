pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
contract ICSTCrowSale is Ownable{
	using SafeMath for uint256;

	
	uint256 public totalFundingSupply;
	ERC20 public token;
	uint256 public startTime;
	uint256 public endTime;
	uint256 public airdropSupply;
	uint256 public rate;
	event Wasted(address to, uint256 value, uint256 date);
	function ICSTCrowSale(){
		rate = 0;
		startTime=0;
		endTime=0;
		airdropSupply = 0;
		totalFundingSupply = 0;
		token=ERC20(0xe6bc60a00b81c7f3cbc8f4ef3b0a6805b6851753);
	}

	function () payable external
	{
			require(now>startTime);
			require(now<=endTime);
			uint256 amount=0;
			processFunding(msg.sender,msg.value,rate);
			amount=msg.value.mul(rate);
			totalFundingSupply = totalFundingSupply.add(amount);
	}

    function withdrawCoinToOwner(uint256 _value) external
		onlyOwner
	{
		processFunding(msg.sender,_value,1);
	}
	//空投
    function airdrop(address [] _holders,uint256 paySize) external
    	onlyOwner 
	{
        uint256 count = _holders.length;
        assert(paySize.mul(count) <= token.balanceOf(this));
        for (uint256 i = 0; i < count; i++) {
			processFunding(_holders [i],paySize,1);
			airdropSupply = airdropSupply.add(paySize); 
        }
        Wasted(owner, airdropSupply, now);
    }
	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
	{
		uint256 amount=_value.mul(_rate);
		require(amount<=token.balanceOf(this));
		if(!token.transfer(receiver,amount)){
			revert();
		}
	}

	
	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}



	function init(uint256 _startTime,uint256 _endTime,uint _rate) external
		onlyOwner
	{
		startTime=_startTime;
		endTime=_endTime;
		rate=_rate;
	}

	function changeToken(address _tokenAddress) external
		onlyOwner
	{
		token = ERC20(_tokenAddress);
	}	
	  
}