pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract UNCS is StandardToken,Ownable{

	//the base info of the token
	string public constant name="unicoins";
	string public constant symbol="UNCS";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	uint256 public constant MAX_SUPPLY=1000000000*10**decimals;

	uint256 public constant INIT_SUPPLY=200000000*10**decimals;
	uint256 public constant MAX_FUNDING_SUPPLY=800000000*10**decimals;

	uint256 public constant rate=260000;
	
	uint256 public totalFundingSupply;

	uint256 public startBlock;
	uint256 public endBlock;

	function UNCS(){
		totalSupply = INIT_SUPPLY ;
		totalFundingSupply = 0;
		startBlock = 4000000;
		endBlock = 6000000;
		balances[0x3A25e7B527A752D098a8383bf3dD0DaE01f741D0] = INIT_SUPPLY;
		Transfer(0x0, 0x3A25e7B527A752D098a8383bf3dD0DaE01f741D0, INIT_SUPPLY);
	}

	event CreateUNCS(address indexed _to, uint256 _value);

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

	modifier notReachFundingSupply(uint256 _value,uint256 _rate){
		assert(MAX_FUNDING_SUPPLY>=totalFundingSupply.add(_value.mul(_rate)));
		_;
	}

	//owner有权限提取账户中的eth
	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}


	//众筹，不超过最大众筹份额,要在众筹时间内
	function () payable external
		afterBlock(startBlock)
		beforeBlock(endBlock)
		notReachFundingSupply(msg.value,rate)
	{
			processFunding(msg.sender,msg.value,rate);
			//增加已众筹份额
			uint256 amount=msg.value.mul(rate);
			totalFundingSupply = totalFundingSupply.add(amount);
	}

	//不能超过最大分发限额
	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{
		uint256 amount=_value.mul(_rate);
		totalSupply=totalSupply.add(amount);
		balances[receiver] +=amount;
		CreateUNCS(receiver,amount);
		Transfer(0x0, receiver, amount);
	}


	function getCurrentBlockNum() internal returns (uint256){
		return block.number;
	}



    function setupFundingInfo(uint256 _startBlock,uint256 _endBlock) external
        onlyOwner
    {
		startBlock=_startBlock;
		endBlock=_endBlock;
    }
}