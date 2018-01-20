pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract BatchPayFeeContract is Ownable,ReentrancyGuard{
	using SafeMath for uint256;


    function BatchPayFeeContract(){

    }

    event BatchTransfer(address oper,uint256 transferAmount,uint256 time); 
    event GetETH(address indexed _from, uint256 _value);
    //批量分发，这里不采取拉模式
	function batchTransfer(address[] beneficiaries,uint256 perAmount) public 
        onlyOwner
        nonReentrant
    {
        
        //平均分配
        uint256 count = beneficiaries.length;

        require(perAmount.mul(count)<=this.balance);

        for(uint256 i;i<beneficiaries.length;i++){
            address beneficiary=beneficiaries[i];
            require(beneficiary != 0x0);
            beneficiary.transfer(perAmount);
        }
        BatchTransfer(owner,perAmount.mul(count),now);
    }


	//允许用户往合约账户打币
	function () payable external
	{
		GetETH(msg.sender,msg.value);
	}

    //允许owner提取剩余的eth
	function etherProceeds() external
		onlyOwner
	{
		if(!msg.sender.send(this.balance)) revert();
	}


}