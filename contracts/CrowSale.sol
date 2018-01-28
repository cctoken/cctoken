pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
contract CrowSale is Ownable{
	using SafeMath for uint256;

	
	uint256 public totalFundingSupply;
	ERC20 public token;

	uint256 public stepOneStartTime;
	uint256 public stepTwoStartTime;
	uint256 public endTime;

	uint256 public setpOneRate;
	uint256 public setpTwoRate;

	function CrowSale(){
		setpOneRate = 0;
		setpTwoRate = 0;
		stepOneStartTime=0;
		stepTwoStartTime=0;
		endTime=0;

		totalFundingSupply = 0;
		token=ERC20(0xe177ccb051621687bee98bfc4bdea6d479bac83e);
	}

	function () payable external
	{
			//只接受大于0.1eth投资
			require(msg.value>=100000000000000000);
			require(now>stepOneStartTime);
			require(now<=endTime);
			uint256 amount=0;
			if(now>stepOneStartTime&&now<=stepTwoStartTime){
				processFunding(msg.sender,msg.value,setpOneRate);
				amount=msg.value.mul(setpOneRate);
			}else if(now>stepTwoStartTime&&now<=endTime){
				processFunding(msg.sender,msg.value,setpTwoRate);
				amount=msg.value.mul(setpTwoRate);
			}else{
				revert();
			}
			totalFundingSupply = totalFundingSupply.add(amount);
	}

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

	
	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}



	function init(uint256 _stepOneStartTime,uint256 _stepTwoStartTime,uint256 _endTime,uint _setpOneRate,uint _setpTwoRate) external
		onlyOwner
	{
		stepOneStartTime=_stepOneStartTime;
		stepTwoStartTime=_stepTwoStartTime;
		endTime=_endTime;
		setpOneRate=_setpOneRate;
		setpTwoRate=_setpTwoRate;
	}

	function changeToken(address _tokenAddress) external
		onlyOwner
	{
		token = ERC20(_tokenAddress);
	}	
	  
}