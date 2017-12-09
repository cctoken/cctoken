pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract CBCToken is StandardToken,Ownable{

	//the base info of the token
	string public constant name="cube coin";
	string public constant symbol="CBC";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	uint256 public constant MAX_SUPPLY=50000000*10**decimals;
	uint256 public constant MAX_FUNDING_SUPPLY=45000000*10**decimals;
	//teamKeeping
	uint256 public constant TEAM_KEEPING=5000000*10**decimals;

	uint256 public constant rate=2000;
	
	uint256 public totalFundingSupply;
	uint256 public totalTeamWithdrawSupply;

	uint256 public startBlock;
	uint256 public endBlock;
	address[] public allFundingUsers;

	mapping(address=>uint256) public fundBalance;
	

	function CBCToken(){
		totalSupply = 0 ;
		totalFundingSupply = 0;
		totalTeamWithdrawSupply=0;

		startBlock = 4000000;
		endBlock = 5000000;
	}

	event CreateCBC(address indexed _to, uint256 _value);

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

	modifier notReachTeamWithdrawSupply(uint256 _value,uint256 _rate){
		assert(TEAM_KEEPING>=totalTeamWithdrawSupply.add(_value.mul(_rate)));
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
			
			//另外记录众筹数据，以避免受转账影响
			allFundingUsers.push(msg.sender);
			fundBalance[msg.sender]=fundBalance[msg.sender].add(amount);


	}

	//众筹完成后，owner可以按比例给用户分发剩余代币
	function airdrop(address receiver,uint256 _value) external
	    onlyOwner
		afterBlock(endBlock)
		notReachFundingSupply(_value,1)
	{
		processFunding(receiver,_value,1);
		//增加已众筹份额
		totalFundingSupply=totalFundingSupply.add(_value);
	}

	//owner有权限提取币
	function patformWithdraw(uint256 _value) external
		onlyOwner
		notReachTeamWithdrawSupply(_value,1)

	{
		processFunding(msg.sender,_value,1);
		//增加团队已提现份额
		totalTeamWithdrawSupply=totalTeamWithdrawSupply.add(_value);

	}
	//不能超过最大分发限额
	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{
		uint256 amount=_value.mul(_rate);
		totalSupply=totalSupply.add(amount);
		balances[receiver] +=amount;
		CreateCBC(receiver,amount);
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