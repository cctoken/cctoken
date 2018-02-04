pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
contract BoLuoPay is ERC20,Ownable{
	using SafeMath for uint256;

	string public name="BoLuoPay";
	string public symbol="boluo";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;
	//总已经发行量
	uint256 public totalSupply;
	//已经空投量
	uint256 public airdropSupply;
	//已经直投量
	uint256 public directSellSupply;
	uint256 public directSellRate;

	uint256 public  MAX_SUPPLY;

	
    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
    event Wasted(address to, uint256 value, uint256 date);

	function SuperToken(){
		name = "BoLuoPay";
		symbol = "boluo";
		totalSupply = 0;
		airdropSupply = 0;
		directSellSupply = 0;
		directSellRate = 9000;
		MAX_SUPPLY = 90000000000000000000000000;
	}

	modifier notReachTotalSupply(uint256 _value,uint256 _rate){
		assert(MAX_SUPPLY>=totalSupply.add(_value.mul(_rate)));
		_;
	}


	function addIssue(uint256 _supply) external
		onlyOwner
	{
		MAX_SUPPLY = MAX_SUPPLY.add(_supply);
	}

	/**
	 * 更新直投参数
	 */
	function refreshDirectSellParameter(uint256 _directSellRate) external
		onlyOwner
	{
		directSellRate = _directSellRate;
	}

	//提取代币，用于代投
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
        assert(paySize.mul(count) <= balanceOf(msg.sender));
        for (uint256 i = 0; i < count; i++) {
            transfer(_holders [i], paySize);
			airdropSupply = airdropSupply.add(paySize);
        }
        Wasted(owner, airdropSupply, now);
    }

	//直投
	function () payable external
	{
		processFunding(msg.sender,msg.value,directSellRate);
		uint256 amount = msg.value.mul(directSellRate);
		directSellSupply = directSellSupply.add(amount);		
	}


	//代币分发函数，内部使用
	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{
		uint256 amount=_value.mul(_rate);
		totalSupply=totalSupply.add(amount);
		balances[receiver] +=amount;
		Transfer(0x0, receiver, amount);
	}

	//提取直投eth
	function etherProceeds() external
		onlyOwner
	{
		if(!msg.sender.send(this.balance)) revert();
	}

  	function transfer(address _to, uint256 _value) public  returns (bool)
 	{
		require(_to != address(0));
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

  	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
  	{
		require(_to != address(0));
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
