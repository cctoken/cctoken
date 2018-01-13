pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
contract CFC is ERC20,Ownable{
	using SafeMath for uint256;

	//the base info of the token
	string public constant name="Chain Finance";
	string public constant symbol="CFC";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	//初始发行10亿
	uint256 public constant MAX_SUPPLY=1000000000*10**decimals;

	//期数
    struct epoch  {
        uint256 endTime;
        uint256 amount;
    }

	//各个用户的锁仓金额
	mapping(address=>epoch[]) public lockEpochsMap;


	 
	//ERC20的余额
    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	

	function CFC(){
		totalSupply = MAX_SUPPLY;
		balances[msg.sender] = MAX_SUPPLY;
		Transfer(0x0, msg.sender, MAX_SUPPLY);
	}


    function addIssue(uint256 amount) external
	    onlyOwner
    {
		balances[msg.sender] = balances[msg.sender].add(amount);
		Transfer(0x0, msg.sender, amount);
	}

	//允许用户往合约账户打币
	function () payable external
	{
	}

	//owner有权限提取账户中的eth
	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}

	//设置锁仓
	function lockBalance(address user, uint256 amount,uint256 endTime) external
		onlyOwner
	{
		 epoch[] storage epochs = lockEpochsMap[user];
		 epochs.put(epoch(endTime,amount));
	}




  //转账前，先校验减去转出份额后，是否大于等于锁仓份额
  	function transfer(address _to, uint256 _value) public  returns (bool)
 	{
		require(_to != address(0));
		//计算锁仓份额
		epoch[] epochs = lockEpochsMap[msg.sender];
		uint256 lockBalance = 0;
		for(uint256 i;i<epochs.length;i++)
		{
			//如果当前时间小于当期结束时间,则此期有效
			if( now < epochs[i].endTime )
			{
				lockBalance.add(epochs[i].amount);
			}
		}

		require(balances[msg.sender].sub(_value)>=lockBalance);
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
		uint256 lockBalance = 0;
		for(uint256 i;i<epochs.length;i++)
		{
			//如果当前时间小于当期结束时间,则此期有效
			if( now < epochs[i].endTime )
			{
				lockBalance.add(epochs[i].amount);
			}
		}

		require(balances[_from].sub(_value)>=lockBalance);
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

	  
}