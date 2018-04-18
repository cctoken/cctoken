pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
contract AgentWallet is Ownable{
	using SafeMath for uint256;

	
	uint256 public totalFundingSupply;
	ERC20 public token;
	string public walletName;
	uint256 public startTime;
	uint256 public endTime;
	uint256 public rate;
	function AgentWallet(){
		rate = 0;
		startTime=0;
		endTime=0;
		totalFundingSupply = 0;
		walletName="init";
		token=ERC20(0xb53ac311087965d9e085515efbe1380b2ca4de9a);
	}

	//funding, eth in
	function () payable external
	{
			require(now>startTime);
			require(now<=endTime);
			processFunding(msg.sender,msg.value,rate);
			uint256 amount=msg.value.mul(rate);
			totalFundingSupply = totalFundingSupply.add(amount);
	}

	//coin out
    function withdrawCoinToOwner(uint256 _value) external
		onlyOwner
	{
		processFunding(msg.sender,_value,1);
	}


	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
	{
		uint256 amount=_value.mul(_rate);
		require(amount<=token.balanceOf(this));
		if(!token.transfer(receiver,amount)){
			revert();
		}
	}

	//eth out
	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}



	function init(string _walletName,uint256 _startTime,uint256 _endTime,uint _rate) external
		onlyOwner
	{
		walletName=_walletName;
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