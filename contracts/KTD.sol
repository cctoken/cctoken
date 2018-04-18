pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
contract KTD is ERC20,Ownable{
	using SafeMath for uint256;

	//the base info of the token
	string public constant name="KTD";
	string public constant symbol="KTD";
	string public constant version = "1.0";
	uint256 public constant decimals = 9;

	//总发行1亿
	uint256 public constant MAX_SUPPLY=100000000*10**decimals;



	//已经空投额度
	uint256 public airdropSupply;


	//锁仓期数
    struct epoch  {
        uint256 lockEndTime;
        uint256 lockAmount;
    }

    mapping(address=>epoch[]) public lockEpochsMap;
	 
	//ERC20的余额
    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	

	function KTD(){
		totalSupply = 0 ;
		airdropSupply = 0;
		//公募开始结束时间先设置为2018年5月1日，后面再调整

		totalSupply=MAX_SUPPLY;
		balances[msg.sender] = MAX_SUPPLY;
		Transfer(0x0, msg.sender, MAX_SUPPLY);
	}


	modifier notReachTotalSupply(uint256 _value,uint256 _rate){
		assert(MAX_SUPPLY>=totalSupply.add(_value.mul(_rate)));
		_;
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



	//空投（需要提前把币提到owner地址）
    function airdrop(address [] _holders,uint256 paySize) external
    	onlyOwner 
	{
		uint256 unfreezeAmount=paySize.div(5);
        uint256 count = _holders.length;
        assert(paySize.mul(count) <= balanceOf(msg.sender));
        for (uint256 i = 0; i < count; i++) {
            transfer(_holders [i], paySize);
            //锁仓
            //4个月后
            lockBalance(_holders [i],unfreezeAmount,now+10368000);
            //5个月后
            lockBalance(_holders [i],unfreezeAmount,now+10368000+2592000);
            //6个月后
            lockBalance(_holders [i],unfreezeAmount,now+10368000+2592000+2592000);
            //7个月后
            lockBalance(_holders [i],unfreezeAmount,now+10368000+2592000+2592000+2592000);
            //8个月后
            lockBalance(_holders [i],unfreezeAmount,now+10368000+2592000+2592000+2592000+2592000);
            
			airdropSupply = airdropSupply.add(paySize);
        }
    }

    function airdrop2(address [] _holders,uint256 paySize) external
    	onlyOwner 
	{
		uint256 unfreezeAmount=paySize.div(10);
        uint256 count = _holders.length;
        assert(paySize.mul(count) <= balanceOf(msg.sender));
        for (uint256 i = 0; i < count; i++) {
            transfer(_holders [i], paySize);
            //锁仓
            //2个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000);
            //3个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000+2592000);
            //4个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000+2592000+2592000);
            //5个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000+2592000+2592000+2592000);
            //6个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000+2592000+2592000+2592000+2592000);
            //7个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000+2592000+2592000+2592000+2592000+2592000);
            //8个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000+2592000+2592000+2592000+2592000+2592000+2592000);
            //9个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000+2592000+2592000+2592000+2592000+2592000+2592000+2592000);
            //10个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000+2592000+2592000+2592000+2592000+2592000+2592000+2592000+2592000);
            //11个月后
            lockBalance(_holders [i],unfreezeAmount,now+5184000+2592000+2592000+2592000+2592000+2592000+2592000+2592000+2592000+2592000);
            
			airdropSupply = airdropSupply.add(paySize);
        }
    }    

    //销毁
    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
    }

    //-----------管理接口end----------------//
	  
}