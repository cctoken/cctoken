pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
contract TokenBooksAirdrop is Ownable{
	using SafeMath for uint256;

	mapping (address => uint) public airdropSupplyMap;
	function TokenBooksAirdrop(){
	}


    function withdrawCoinToOwner(address tokenAddress,uint256 _value) external
		onlyOwner
	{
		processFunding(tokenAddress,msg.sender,_value,1);
	}
	//空投
    function airdrop(address tokenAddress,address [] _holders,uint256 paySize) external
    	onlyOwner 
	{
		ERC20 token = ERC20(tokenAddress);
        uint256 count = _holders.length;
        assert(paySize.mul(count) <= token.balanceOf(this));
        for (uint256 i = 0; i < count; i++) {
			processFunding(tokenAddress,_holders [i],paySize,1);
			airdropSupplyMap[tokenAddress] = airdropSupplyMap[tokenAddress].add(paySize); 
        }
    }
	function processFunding(address tokenAddress,address receiver,uint256 _value,uint256 _rate) internal
	{
		ERC20 token = ERC20(tokenAddress);
		uint256 amount=_value.mul(_rate);
		require(amount<=token.balanceOf(this));
		if(!token.transfer(receiver,amount)){
			revert();
		}
	}

	
	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}

}