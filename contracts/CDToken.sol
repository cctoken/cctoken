pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/PausableToken.sol';

contract CDToken is PausableToken {
	//the base info of the token 
	string public constant name = "CDToken";
	string public constant symbol ="CDT";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	uint256 public constant MAX_CCT_SUPPLY = 100000000 * 10**decimals;
	uint256 public constant MAX_CDT_SUPPLY = (MAX_CCT_SUPPLY/100)*15;

	uint256 public constant MAX_ORG_SUPPLY = (MAX_CCT_SUPPLY/100)*10;
	//uint256 public constant MAX_PER_SUPPLY = (MAX_CCT_SUPPLY/100)*5;

	uint256 public limitFundingEth;

	//diff rate of the diff offering channel
	uint256 public constant orgPrivateOfferingExchangeRate = 5300;
	uint256 public constant perPrivateOfferingExchangeRate = 2650;



	//need to edit
	address public constant etherProceedsAccount = 0x8d42ed2cdd50cdfeb32d5db3317967c7241d2f0d;
	address public constant orgPrivateOfferingAccount= 0x7f5c8d447dfc8dd6d75cda857bc2c6f50367d2a6;


	uint256 public orgPrivateOfferingSupply;
	uint256 public perPrivateOfferingSupply;

	bool public isOrgFinish;// switched to true in operational state

	event CreateCDT(address indexed _to, uint256 _value);

	// uint256 public

	function CDToken(){
		totalSupply = 0 ;
		orgPrivateOfferingSupply = 0 ;
		perPrivateOfferingSupply=0;
        limitFundingEth = 1*10**decimals;
		isOrgFinish=false;
	}

	modifier checkOrgFinish(){
		assert(isOrgFinish);
		_;
	}

	modifier checkOrgNotFinish(){
		assert(!isOrgFinish);
		_;
	}
	modifier totalSupplyNotReached(uint256 _ethContribution,uint rate){
		assert(totalSupply.add(_ethContribution.mul(rate)) <= MAX_CDT_SUPPLY);
		_;
	}

	modifier orgPrivateOfferingNotReached(uint256 _ethContribution){
		assert(orgPrivateOfferingSupply.add(_ethContribution.mul(orgPrivateOfferingExchangeRate)) <= MAX_ORG_SUPPLY);
		_;
	}

	modifier etherProceedsAccountOnly(){
		assert(msg.sender == getEtherProceedsAccount());
		_;
	}
	modifier orgPrivateOfferingAccountOnly(){
		assert(msg.sender == getOrgPrivateOfferingAccount());
		_;
	}
	modifier limitFundingEthCheck(){
		assert(msg.value>=limitFundingEth);
		_;
	}

	function () payable external
		whenNotPaused
		checkOrgFinish
	{
		processFunding(perPrivateOfferingExchangeRate);
	}

   /**
		@dev get the funded ether
	*/
	function etherProceeds() external
	    etherProceedsAccountOnly
	{
		if(!msg.sender.send(this.balance)) revert();
	}

	function processOrgPrivateOfferingFunding() payable external
		whenNotPaused
		checkOrgNotFinish
		orgPrivateOfferingAccountOnly
		orgPrivateOfferingNotReached(msg.value)
	{
		orgPrivateOfferingSupply = orgPrivateOfferingSupply.add(msg.value.mul(orgPrivateOfferingExchangeRate));
		processFunding(orgPrivateOfferingExchangeRate);
	}

   /**
		@dev handles Funding logic
		note that the Funding event is triggered using the sender as the funding, regardless of the actual funding
	*/
	function processFunding(uint256 fundingRate) internal
		totalSupplyNotReached(msg.value,fundingRate)
		limitFundingEthCheck

	{
		uint256 tokenAmount = msg.value.mul(fundingRate);
		totalSupply=totalSupply.add(tokenAmount);
		balances[msg.sender] += tokenAmount;  // safeAdd not needed; bad semantics to use here
		CreateCDT(msg.sender, tokenAmount);	 // logs token creation
	}

	function getEtherProceedsAccount() internal  returns (address){
		return etherProceedsAccount;
	}

	function getOrgPrivateOfferingAccount() internal  returns (address){
		return orgPrivateOfferingAccount;
	}

	function setOrgFinish(bool _isOrgFinish) external
		onlyOwner
	{
		isOrgFinish=_isOrgFinish;
	}
	function setLimitFundingEth(uint256 _limitFundingEth) external
	    onlyOwner
	{
	    limitFundingEth=_limitFundingEth;
	}

}
