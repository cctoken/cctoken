pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract CCPToken is StandardToken,Ownable{
	//the base info of the token
	string public name;
	string public symbol;
	string public constant version = "1.0";
	uint256 public constant decimals = 18;
	uint256 public constant MAX_SUPPLY=10000000000*10**decimals;
	function CCPToken(){
		name="CoalaCoin Point";
		symbol="CCP";
		totalSupply =0;
	}
	event CreateCCP(address indexed _to, uint256 _value);
	modifier notReachTotalSupply(uint256 _value){
		assert(MAX_SUPPLY>=totalSupply.add(_value));
		_;
	}
	function distribute(address receiver,uint256 _value) external
		onlyOwner
	{
		processFunding(receiver,_value);
	}
    function processFunding(address receiver,uint256 _value) internal
        notReachTotalSupply(_value)
    {
        totalSupply=totalSupply.add(_value);
        balances[receiver] +=_value;
        CreateCCP(receiver,_value);
		Transfer(0x0, receiver, _value);
    }
}