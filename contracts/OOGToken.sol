pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
contract OOGToken is ERC20,Ownable{
	using SafeMath for uint256;

	//the base info of the token
	string public constant name="bitoog token";
	string public symbol;
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	uint256 public constant MAX_SUPPLY=100000000*10**decimals;

	uint256 public constant MAX_FUNDING_SUPPLY=20000000*10**decimals;
	uint256 public rate;
	uint256 public totalFundingSupply;


	uint256 public constant ONE_YEAR_KEEPING=24000000*10**decimals;
	bool public hasOneYearWithdraw;

	uint256 public constant TWO_YEAR_KEEPING=24000000*10**decimals;
	bool public hasTwoYearWithdraw;

	
	uint256 public constant THREE_YEAR_KEEPING=32000000*10**decimals;	
	bool public hasThreeYearWithdraw;


	uint256 public startBlock;
	uint256 public endBlock;
	
    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	

	function OOGToken(){
		totalSupply = 0 ;
		totalFundingSupply = 0;

		hasOneYearWithdraw=false;
		hasTwoYearWithdraw=false;
		hasThreeYearWithdraw=false;

		startBlock = 4000000;
		endBlock = 5000000;
		rate=10000;
		symbol="OOG";
	}

	event CreateOOG(address indexed _to, uint256 _value);

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



	modifier assertFalse(bool withdrawStatus){
		assert(!withdrawStatus);
		_;
	}

	modifier notBeforeTime(uint256 targetTime){
		assert(now>targetTime);
		_;
	}


	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}


	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{
		uint256 amount=_value.mul(_rate);
		totalSupply=totalSupply.add(amount);
		balances[receiver] +=amount;
		CreateOOG(receiver,amount);
		Transfer(0x0, receiver, amount);
	}




	function () payable external
		afterBlock(startBlock)
		beforeBlock(endBlock)
		notReachFundingSupply(msg.value,rate)
	{
		processFunding(msg.sender,msg.value,rate);
		uint256 amount=msg.value.mul(rate);
		totalFundingSupply = totalFundingSupply.add(amount);
	}



	function withdrawForOneYear() external
		onlyOwner
		assertFalse(hasOneYearWithdraw)
		notBeforeTime(1514736000)
	{
		processFunding(msg.sender,ONE_YEAR_KEEPING,1);
		hasOneYearWithdraw = true;
	}

	function withdrawForTwoYear() external
		onlyOwner
		assertFalse(hasTwoYearWithdraw)
		notBeforeTime(1546272000)
	{
		processFunding(msg.sender,TWO_YEAR_KEEPING,1);
		hasTwoYearWithdraw = true;
	}

	function withdrawForThreeYear() external
		onlyOwner
		assertFalse(hasThreeYearWithdraw)
		notBeforeTime(1577808000)
	{
		processFunding(msg.sender,THREE_YEAR_KEEPING,1);
		hasThreeYearWithdraw = true;
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

	function getCurrentBlockNum() internal returns (uint256)
	{
		return block.number;
	}


	function setSymbol(string _symbol) external
		onlyOwner
	{
		symbol=_symbol;
	}


	function setRate(uint256 _rate) external
		onlyOwner
	{
		rate=_rate;
	}

	
    function setupFundingInfo(uint256 _startBlock,uint256 _endBlock) external
        onlyOwner
    {
		startBlock=_startBlock;
		endBlock=_endBlock;
    }
	  
}