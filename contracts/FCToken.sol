pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract FCToken is StandardToken,Ownable{

	//the base info of the token
	string public name;
	string public symbol;
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	uint256 public constant MAX_SUPPLY=100000000*10**decimals;

	//need to edit
	address public etherProceedsAccount;
	address public fctWithdrawAccount;

	uint256 public startBlock;
	uint256 public stepOneStartBlock;
	uint256 public stepTwoStartBlock;
	uint256 public stepThreeStartBlock;
	uint256 public stepFourStartBlock;
	uint256 public endBlock;

	uint256 public oneStepRate;
	uint256 public twoStepRate;
	uint256 public threeStepRate;
	uint256 public fourStepRate;

	function FCToken(){
		name="FCToken";
		symbol="FCT";
		totalSupply = 0 ;

		etherProceedsAccount = 0x332eca5baa67d9e4f4ee3ad0b73d7a19a8cda821;
		fctWithdrawAccount = 0x332eca5baa67d9e4f4ee3ad0b73d7a19a8cda821;

		startBlock=4000000;
		stepOneStartBlock=4227161;
		stepTwoStartBlock=4327161;
		stepThreeStartBlock=4427161;
		stepFourStartBlock=4527161;
		endBlock=5000000;

	    oneStepRate=4000;
	    twoStepRate=3000;
	    threeStepRate=2000;
	    fourStepRate=1000;

	}

	event CreateFCT(address indexed _to, uint256 _value);

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

	modifier etherProceedsAccountOnly(){
		assert(msg.sender == getEtherProceedsAccount());
		_;
	}
	modifier fctWithdrawAccountOnly(){
		assert(msg.sender == getFctWithdrawAccount());
		_;
	}


	function processFunding(uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{

	}

	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{
		uint256 amount=_value.mul(_rate);
		totalSupply=totalSupply.add(amount);
		balances[receiver] +=amount;
		CreateFCT(receiver,amount);
	}


	function () payable external
		afterBlock(startBlock)
		beforeBlock(endBlock)
	{
		if(getCurrentBlockNum()>=startBlock&&getCurrentBlockNum()<stepOneStartBlock){
			processFunding(msg.sender,msg.value,oneStepRate);
		}else if(getCurrentBlockNum()>=stepOneStartBlock&&getCurrentBlockNum()<stepTwoStartBlock){
			processFunding(msg.sender,msg.value,twoStepRate);
		}else if(getCurrentBlockNum()>=stepTwoStartBlock&&getCurrentBlockNum()<stepThreeStartBlock){
			processFunding(msg.sender,msg.value,threeStepRate);
        }else if(getCurrentBlockNum()>=stepThreeStartBlock&&getCurrentBlockNum()<stepFourStartBlock){
			processFunding(msg.sender,msg.value,fourStepRate);
        }

	}


	function etherProceeds() external
		etherProceedsAccountOnly
	{
		if(!msg.sender.send(this.balance)) revert();
	}

	function icoPlatformWithdraw(uint256 _value) external
		fctWithdrawAccountOnly
	{
		processFunding(msg.sender,_value,1);
	}


	function getCurrentBlockNum() internal returns (uint256){
		return block.number;
	}

	function getEtherProceedsAccount() internal  returns (address){
		return etherProceedsAccount;
	}


	function getFctWithdrawAccount() internal returns (address){
		return fctWithdrawAccount;
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

	function setEtherProceedsAccount(address _etherProceedsAccount) external
		onlyOwner
	{
		etherProceedsAccount=_etherProceedsAccount;
	}

	function setFctWithdrawAccount(address _fctWithdrawAccount) external
		onlyOwner
	{
		fctWithdrawAccount=_fctWithdrawAccount;
	}


    function setupFundingInfo(uint256 _startBlock,uint256 _stepOneStartBlock,uint256 _stepTwoStartBlock,uint256 _stepThreeStartBlock,uint256 _stepFourStartBlock,uint256 _endBlock,uint256 _oneStepRate,uint256 _twoStepRate,uint256 _threeStepRate,uint256 _fourStepRate) external
    {
		startBlock=4000000;
		stepOneStartBlock=4227161;
		stepTwoStartBlock=4327161;
		stepThreeStartBlock=4427161;
		stepFourStartBlock=4527161;
		endBlock=5000000;

	    oneStepRate=_oneStepRate;
	    twoStepRate=_twoStepRate;
	    threeStepRate=_threeStepRate;
	    fourStepRate=_fourStepRate;

    }
}