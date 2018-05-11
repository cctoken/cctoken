pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
contract UNIT is ERC20,Ownable{
	using SafeMath for uint256;

	//the base info of the token
	string public constant name="Unit Pay";
	string public constant symbol="UNIT";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;



	//UINT私募6亿
	uint256 public constant MAX_PRIVATE_FUNDING_SUPPLY=600000000*10**decimals;

	//UINT社区奖励3亿
	uint256 public constant COOPERATE_REWARD=300000000*10**decimals;

	//可普通提现额度6+3=9亿
	uint256 public constant COMMON_WITHDRAW_SUPPLY=MAX_PRIVATE_FUNDING_SUPPLY+COOPERATE_REWARD;


	//UINT天使投资人持有6亿
	uint256 public constant PARTNER_SUPPLY=600000000*10**decimals;


	//UINT公募1.5亿
	uint256 public constant MAX_PUBLIC_FUNDING_SUPPLY=150000000*10**decimals;

	//UINT团队保留13.5亿
	uint256 public constant TEAM_KEEPING=1350000000*10**decimals;

	//总发行6+1.5+13.5=21亿
	uint256 public constant MAX_SUPPLY=COMMON_WITHDRAW_SUPPLY+PARTNER_SUPPLY+MAX_PUBLIC_FUNDING_SUPPLY+TEAM_KEEPING;


	//公募比例默认80000
	uint256 public rate;

	//公募白名单
	mapping(address=>uint256) public publicFundingWhiteList;
	
	//已经普通提现量
	uint256 public totalCommonWithdrawSupply;
	//天使投资人已经提现额度
	uint256 public totalPartnerWithdrawSupply;

	//已经公募量
	uint256 public totalPublicFundingSupply;
	//公募开始结束时间
	uint256 public startTime;
	uint256 public endTime;


	//团队每次解禁2.7亿
	uint256 public constant TEAM_UNFREEZE=270000000*10**decimals;
	bool public hasOneStepWithdraw;
	bool public hasTwoStepWithdraw;
	bool public hasThreeStepWithdraw;
	bool public hasFourStepWithdraw;
	bool public hasFiveStepWithdraw;	
	
	//锁仓期数
    struct epoch  {
        uint256 lockEndTime;
        uint256 lockAmount;
    }

    mapping(address=>epoch[]) public lockEpochsMap;
	 
	//ERC20的余额
    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	

	function UNIT(){
		totalSupply = 0 ;
		totalCommonWithdrawSupply=0;
		totalPartnerWithdrawSupply=0;
		totalPublicFundingSupply = 0;

		//公募开始结束时间先设置为2018年5月1日，后面再调整
		startTime = 1525104000;
		endTime = 1525104000;
		rate=80000;


		hasOneStepWithdraw=false;
		hasTwoStepWithdraw=false;
		hasThreeStepWithdraw=false;
		hasFourStepWithdraw=false;
		hasFiveStepWithdraw=false;
	}

	event CreateUNIT(address indexed _to, uint256 _value);


	modifier notReachTotalSupply(uint256 _value,uint256 _rate){
		assert(MAX_SUPPLY>=totalSupply.add(_value.mul(_rate)));
		_;
	}

	modifier notReachPublicFundingSupply(uint256 _value,uint256 _rate){
		assert(MAX_PUBLIC_FUNDING_SUPPLY>=totalPublicFundingSupply.add(_value.mul(_rate)));
		_;
	}

	modifier notReachCommonWithdrawSupply(uint256 _value,uint256 _rate){
		assert(COMMON_WITHDRAW_SUPPLY>=totalCommonWithdrawSupply.add(_value.mul(_rate)));
		_;
	}


	modifier notReachPartnerWithdrawSupply(uint256 _value,uint256 _rate){
		assert(PARTNER_SUPPLY>=totalPartnerWithdrawSupply.add(_value.mul(_rate)));
		_;
	}


	modifier assertFalse(bool withdrawStatus){
		assert(!withdrawStatus);
		_;
	}

	modifier notBeforeTime(uint256 targetTime){
		assert(now>targetTime);
		_;
	}

	modifier notAfterTime(uint256 targetTime){
		assert(now<=targetTime);
		_;
	}
	//owner有权限提取账户中的eth
	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}


	//统一代币分发函数，内部使用
	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{
		uint256 amount=_value.mul(_rate);
		totalSupply=totalSupply.add(amount);
		balances[receiver] +=amount;
		CreateUNIT(receiver,amount);
		Transfer(0x0, receiver, amount);
	}



	//普通提币
	function commonWithdraw(uint256 _value) external
		onlyOwner
		notReachCommonWithdrawSupply(_value,1)

	{
		processFunding(msg.sender,_value,1);
		//增加已经普通提现份额
		totalCommonWithdrawSupply=totalCommonWithdrawSupply.add(_value);
	}


	//提币给投资人，需要限制转账
	function withdrawToPartner(address _to,uint256 _value) external
		onlyOwner
		notReachPartnerWithdrawSupply(_value,1)
	{
		processFunding(_to,_value,1);
		totalPartnerWithdrawSupply=totalPartnerWithdrawSupply.add(_value);
		//锁仓到20181111
		lockBalance(_to,_value,1541865600);
	}

	//公募，不超过最大公募份额,要在公募时间内
	function () payable external
		notBeforeTime(startTime)
		notAfterTime(endTime)
		notReachPublicFundingSupply(msg.value,rate)
	{
		//控制只有白名单中用户才可以参加公募
		require(publicFundingWhiteList[msg.sender]==1);

		processFunding(msg.sender,msg.value,rate);
		//增加已公募份额
		uint256 amount=msg.value.mul(rate);
		totalPublicFundingSupply = totalPublicFundingSupply.add(amount);

	}


	//20180511可提
	function withdrawForOneStep() external
		onlyOwner
		assertFalse(hasOneStepWithdraw)
		notBeforeTime(1525968000)
	{
		processFunding(msg.sender,TEAM_UNFREEZE,1);
		//标记团队已提现
		hasOneStepWithdraw = true;
	}

	//20181111
	function withdrawForTwoStep() external
		onlyOwner
		assertFalse(hasTwoStepWithdraw)
		notBeforeTime(1541865600)
	{
		processFunding(msg.sender,TEAM_UNFREEZE,1);
		//标记团队已提现
		hasTwoStepWithdraw = true;
	}

	//20190511
	function withdrawForThreeStep() external
		onlyOwner
		assertFalse(hasThreeStepWithdraw)
		notBeforeTime(1557504000)
	{
		processFunding(msg.sender,TEAM_UNFREEZE,1);
		//标记团队已提现
		hasThreeStepWithdraw = true;
	}

	//20191111
	function withdrawForFourStep() external
		onlyOwner
		assertFalse(hasFourStepWithdraw)
		notBeforeTime(1573401600)
	{
		processFunding(msg.sender,TEAM_UNFREEZE,1);
		//标记团队已提现
		hasFourStepWithdraw = true;
	}

	//20200511
	function withdrawForFiveStep() external
		onlyOwner
		assertFalse(hasFiveStepWithdraw)
		notBeforeTime(1589126400)
	{
		processFunding(msg.sender,TEAM_UNFREEZE,1);
		//标记团队已提现
		hasFiveStepWithdraw = true;
	}			


  //转账前，先校验减去转出份额后，是否大于等于锁仓份额
  	function transfer(address _to, uint256 _value) public  returns (bool)
 	{
		require(_to != address(0));

		//计算锁仓份额
		epoch[] epochs = lockEpochsMap[msg.sender];
		uint256 needLockBalance = 0;
		for(uint256 i = 0;i<epochs.length;i++)
		{
			//如果当前时间小于当期结束时间,则此期有效
			if( now < epochs[i].lockEndTime )
			{
				needLockBalance=needLockBalance.add(epochs[i].lockAmount);
			}
		}

		require(balances[msg.sender].sub(_value)>=needLockBalance);

		// SafeMath.sub will throw if there is not enough balance.
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
  	}

  	function balanceOf(address _owner) public constant returns (uint256 balance) 
  	{
		return balances[_owner];
  	}


  //从委托人账上转出份额时，还要判断委托人的余额-转出份额是否大于等于锁仓份额
  	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
  	{
		require(_to != address(0));

		//计算锁仓份额
		epoch[] epochs = lockEpochsMap[_from];
		uint256 needLockBalance = 0;
		for(uint256 i = 0;i<epochs.length;i++)
		{
			//如果当前时间小于当期结束时间,则此期有效
			if( now < epochs[i].lockEndTime )
			{
				needLockBalance = needLockBalance.add(epochs[i].lockAmount);
			}
		}

		require(balances[_from].sub(_value)>=needLockBalance);

		uint256 _allowance = allowed[_from][msg.sender];

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
  	}

  	function approve(address _spender, uint256 _value) public returns (bool) 
  	{
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
  	}

  	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) 
  	{
		return allowed[_owner][_spender];
  	}



  	//-----------管理接口start----------------//

  	//锁仓接口，可分多期锁仓，多期锁仓金额可累加，这里的锁仓是指限制转账
	function lockBalance(address user, uint256 lockAmount,uint256 lockEndTime) internal
	{
		 epoch[] storage epochs = lockEpochsMap[user];
		 epochs.push(epoch(lockEndTime,lockAmount));
	}

    function addPublicFundingWhiteList(address[] _list) external
    	onlyOwner
    {
        uint256 count = _list.length;
        for (uint256 i = 0; i < count; i++) {
        	publicFundingWhiteList[_list [i]] = 1;
        }    	
    }

	function refreshRate(uint256 _rate) external
		onlyOwner
	{
		rate=_rate;
	}
	
    function refreshPublicFundingTime(uint256 _startTime,uint256 _endTime) external
        onlyOwner
    {
		startTime=_startTime;
		endTime=_endTime;
    }

    //-----------管理接口end----------------//
	  
}