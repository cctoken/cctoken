pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract XXToken is StandardToken,Ownable{

	//the base info of the token
	string public name;
	string public symbol;
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	uint256 public constant MAX_SUPPLY=100000000*10**decimals;

	//need to edit
	address public etherProceedsAccount;
	address public xxtWithdrawAccount;

	uint256 public startBlock;
	uint256 public stepOneStartBlock;
	uint256 public stepTwoStartBlock;
	uint256 public stepThreeStartBlock;
	uint256 public stepFourStartBlock;
	uint256 public endBlock;

	uint256 public oneSetpRate;
	uint256 public twoSetpRate;
	uint256 public threeSetpRate;
	uint256 public fourSetpRate;

	function XXToken(){
		name="XXToken";
		symbol="XXT";
		totalSupply = 0 ;

		etherProceedsAccount = 0x5390f9D18A7131aC9C532C1dcD1bEAb3e8A44cbF;
		xxtWithdrawAccount = 0xb353425bA4FE2670DaC1230da934498252E692bD;

		startBlock=4000000;
		stepOneStartBlock=4227161;
		stepTwoStartBlock=4327161;
		stepThreeStartBlock=4427161;
		stepFourStartBlock=4527161;
		endBlock=5000000;

	    oneSetpRate=4000;
	    twoSetpRate=3000;
	    threeSetpRate=2000;
	    fourSetpRate=1000;

	}

	event CreateXXT(address indexed _to, uint256 _value);

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
	modifier xxtWithdrawAccountOnly(){
		assert(msg.sender == getXxtWithdrawAccount());
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
		CreateXXT(receiver,amount);
	}


	function () payable external
		afterBlock(startBlock)
		beforeBlock(endBlock)
	{
		if(getCurrentBlockNum()>=startBlock&&getCurrentBlockNum()<stepOneStartBlock){
			processFunding(msg.sender,msg.value,oneSetpRate);
		}else if(getCurrentBlockNum()>=stepOneStartBlock&&getCurrentBlockNum()<stepTwoStartBlock){
			processFunding(msg.sender,msg.value,twoSetpRate);
		}else if(getCurrentBlockNum()>=stepTwoStartBlock&&getCurrentBlockNum()<stepThreeStartBlock){
			processFunding(msg.sender,msg.value,threeSetpRate);
        }else if(getCurrentBlockNum()>=stepThreeStartBlock&&getCurrentBlockNum()<stepFourStartBlock){
			processFunding(msg.sender,msg.value,fourSetpRate);
        }

	}


	function etherProceeds() external
		etherProceedsAccountOnly
	{
		if(!msg.sender.send(this.balance)) revert();
	}

	function icoPlatformWithdraw(uint256 _value) external
		xxtWithdrawAccountOnly
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
	function getEtherProceedsAccount() internal  returns (address){
		return etherProceedsAccount;
	}


	function getXxtWithdrawAccount() internal returns (address){
		return xxtWithdrawAccount;
	}

	function setEtherProceedsAccount(address _etherProceedsAccount) external
		onlyOwner
	{
		etherProceedsAccount=_etherProceedsAccount;
	}

	function setXxtWithdrawAccount(address _xxtWithdrawAccount) external
		onlyOwner
	{
		xxtWithdrawAccount=_xxtWithdrawAccount;
	}

}