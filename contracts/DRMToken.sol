pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract DRMToken is StandardToken,Ownable{

	//the base info of the token
	string public name;
	string public symbol;
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	uint256 public constant MAX_SUPPLY=333000000*10**decimals;

	uint256 public stepOneStartBlock;
	uint256 public stepTwoStartBlock;
	uint256 public stepThreeStartBlock;
	uint256 public stepFourStartBlock;
	uint256 public endBlock;

	uint256 public oneStepRate;
	uint256 public twoStepRate;
	uint256 public threeStepRate;
	uint256 public fourStepRate;

	function DRMToken(){
		name="Digital Rights Management";
		symbol="DRMToken";
		totalSupply = 0 ;

		stepOneStartBlock=0;
		stepTwoStartBlock=4327161;
		stepThreeStartBlock=4427161;
		stepFourStartBlock=4527161;
		endBlock=5000000;

	    oneStepRate=4000;
	    twoStepRate=3000;
	    threeStepRate=2000;
	    fourStepRate=1000;

	}

	event CreateDRMToken(address indexed _to, uint256 _value);

	modifier beforeBlock(uint256 _blockNum){
		assert(getCurrentBlockNum()<_blockNum);
		_;
	}

	modifier afterBlock(uint256 _blockNum){
		assert(getCurrentBlockNum()>=_blockNum);
		_;
	}

	modifier notReachTotalSupply(uint256 _value,uint256 _rate){
		assert(MAX_SUPPLY>=totalSupply.add(_value.mul(_rate)));
		_;
	}

	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{
		uint256 amount=_value.mul(_rate);
		totalSupply=totalSupply.add(amount);
		balances[receiver] +=amount;
		Transfer(0x0, receiver, amount);
		CreateDRMToken(receiver,amount);
	}


	function () payable external
		afterBlock(stepOneStartBlock)
		beforeBlock(endBlock)
	{
		if(getCurrentBlockNum()>=stepOneStartBlock&&getCurrentBlockNum()<stepTwoStartBlock){
			processFunding(msg.sender,msg.value,oneStepRate);
		}else if(getCurrentBlockNum()>=stepTwoStartBlock&&getCurrentBlockNum()<stepThreeStartBlock){
			processFunding(msg.sender,msg.value,twoStepRate);
		}else if(getCurrentBlockNum()>=stepThreeStartBlock&&getCurrentBlockNum()<stepFourStartBlock){
			processFunding(msg.sender,msg.value,threeStepRate);
        }else if(getCurrentBlockNum()>=stepFourStartBlock&&getCurrentBlockNum()<endBlock){
			processFunding(msg.sender,msg.value,fourStepRate);
        }

	}


	function etherProceeds() external
		onlyOwner
	{
		if(!msg.sender.send(this.balance)) revert();
	}

	function icoPlatformWithdraw(uint256 _value) external
		onlyOwner
	{
		processFunding(msg.sender,_value,1);
	}


	function getCurrentBlockNum() internal returns (uint256){
		return block.number;
	}

	function setName(string _name) external
		onlyOwner
	{
		name=_name;
	}

	function setSymbol(string _symbol) external
		onlyOwner
	{
		symbol=_symbol;
	}

    function setupFundingInfo(uint256 _stepOneStartBlock,uint256 _stepTwoStartBlock,uint256 _stepThreeStartBlock,uint256 _stepFourStartBlock,uint256 _endBlock,uint256 _oneStepRate,uint256 _twoStepRate,uint256 _threeStepRate,uint256 _fourStepRate) external
        onlyOwner
    {
		stepOneStartBlock=_stepOneStartBlock;
		stepTwoStartBlock=_stepTwoStartBlock;
		stepThreeStartBlock=_stepThreeStartBlock;
		stepFourStartBlock=_stepFourStartBlock;
		endBlock=_endBlock;

	    oneStepRate=_oneStepRate;
	    twoStepRate=_twoStepRate;
	    threeStepRate=_threeStepRate;
	    fourStepRate=_fourStepRate;
    }
}