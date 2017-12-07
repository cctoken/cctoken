pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract CRCToken is StandardToken,Ownable{
	//the base info of the token 
	string public name;
	string public symbol;
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	uint256 public constant MAX_SUPPLY = 500000000 * 10**decimals;
	uint256 public constant quota = MAX_SUPPLY/100;

	//the percentage of all usages
	uint256 public constant allOfferingPercentage = 50;
	uint256 public constant teamKeepingPercentage = 15;
	uint256 public constant communityContributionPercentage = 35;

	//the quota of all usages
	uint256 public constant allOfferingQuota = quota*allOfferingPercentage;
	uint256 public constant teamKeepingQuota = quota*teamKeepingPercentage;
	uint256 public constant communityContributionQuota = quota*communityContributionPercentage;

	//the cap of diff offering channel
	//this percentage must less the the allOfferingPercentage
	uint256 public constant privateOfferingPercentage = 10;
	uint256 public constant privateOfferingCap = quota*privateOfferingPercentage;

	//diff rate of the diff offering channel
	uint256 public constant publicOfferingExchangeRate = 25000;
	uint256 public constant privateOfferingExchangeRate = 50000;

	//need to edit
	address public etherProceedsAccount;
	address public crcWithdrawAccount;

	//dependency on the start day
	uint256 public fundingStartBlock;
	uint256 public fundingEndBlock;
	uint256 public teamKeepingLockEndBlock ;

	uint256 public privateOfferingSupply;
	uint256 public allOfferingSupply;
	uint256 public teamWithdrawSupply;
	uint256 public communityContributionSupply;



	// bool public isFinalized;// switched to true in operational state

	event CreateCRC(address indexed _to, uint256 _value);

	// uint256 public

	function CRCToken(){
		name = "CRCToken";
		symbol ="CRC";

		etherProceedsAccount = 0x5390f9D18A7131aC9C532C1dcD1bEAb3e8A44cbF;
		crcWithdrawAccount = 0xb353425bA4FE2670DaC1230da934498252E692bD;

		fundingStartBlock=0;
		fundingEndBlock=6000000;
		teamKeepingLockEndBlock=5577161;

		totalSupply = 0 ;
		privateOfferingSupply=0;
		allOfferingSupply=0;
		teamWithdrawSupply=0;
		communityContributionSupply=0;
	}


	modifier beforeFundingStartBlock(){
		assert(getCurrentBlockNum() < fundingStartBlock);
		_;
	}

	modifier notBeforeFundingStartBlock(){
		assert(getCurrentBlockNum() >= fundingStartBlock);
		_;
	}
	modifier notAfterFundingEndBlock(){
		assert(getCurrentBlockNum() < fundingEndBlock);
		_;
	}
	modifier notBeforeTeamKeepingLockEndBlock(){
		assert(getCurrentBlockNum() >= teamKeepingLockEndBlock);
		_;
	}

	modifier totalSupplyNotReached(uint256 _ethContribution,uint rate){
		assert(totalSupply.add(_ethContribution.mul(rate)) <= MAX_SUPPLY);
		_;
	}
	modifier allOfferingNotReached(uint256 _ethContribution,uint rate){
		assert(allOfferingSupply.add(_ethContribution.mul(rate)) <= allOfferingQuota);
		_;
	}	 

	modifier privateOfferingCapNotReached(uint256 _ethContribution){
		assert(privateOfferingSupply.add(_ethContribution.mul(privateOfferingExchangeRate)) <= privateOfferingCap);
		_;
	}	 
	

	modifier etherProceedsAccountOnly(){
		assert(msg.sender == getEtherProceedsAccount());
		_;
	}
	modifier crcWithdrawAccountOnly(){
		assert(msg.sender == getCrcWithdrawAccount());
		_;
	}




	function processFunding(address receiver,uint256 _value,uint256 fundingRate) internal
		totalSupplyNotReached(_value,fundingRate)
		allOfferingNotReached(_value,fundingRate)

	{
		uint256 tokenAmount = _value.mul(fundingRate);
		totalSupply=totalSupply.add(tokenAmount);
		allOfferingSupply=allOfferingSupply.add(tokenAmount);
		balances[receiver] += tokenAmount;  // safeAdd not needed; bad semantics to use here
		Transfer(0x0, receiver, tokenAmount);
		CreateCRC(receiver, tokenAmount);	 // logs token creation
	}


	function () payable external{
		if(getCurrentBlockNum()<=fundingStartBlock){
			processPrivateFunding(msg.sender);
		}else{
			processEthPulicFunding(msg.sender);
		}


	}

	function processEthPulicFunding(address receiver) internal
	 notBeforeFundingStartBlock
	 notAfterFundingEndBlock
	{
		processFunding(receiver,msg.value,publicOfferingExchangeRate);
	}
	

	function processPrivateFunding(address receiver) internal
	 beforeFundingStartBlock
	 privateOfferingCapNotReached(msg.value)
	{
		uint256 tokenAmount = msg.value.mul(privateOfferingExchangeRate);
		privateOfferingSupply=privateOfferingSupply.add(tokenAmount);
		processFunding(receiver,msg.value,privateOfferingExchangeRate);
	}  

	function icoPlatformWithdraw(uint256 _value) external
		crcWithdrawAccountOnly
	{
		processFunding(msg.sender,_value,1);
	}

	function teamKeepingWithdraw(uint256 tokenAmount) external
	   crcWithdrawAccountOnly
	   notBeforeTeamKeepingLockEndBlock
	{
		assert(teamWithdrawSupply.add(tokenAmount)<=teamKeepingQuota);
		assert(totalSupply.add(tokenAmount)<=MAX_SUPPLY);
		teamWithdrawSupply=teamWithdrawSupply.add(tokenAmount);
		totalSupply=totalSupply.add(tokenAmount);
		balances[msg.sender]+=tokenAmount;
		CreateCRC(msg.sender, tokenAmount);
	}

	function communityContributionWithdraw(uint256 tokenAmount) external
	    crcWithdrawAccountOnly
	{
		assert(communityContributionSupply.add(tokenAmount)<=communityContributionQuota);
		assert(totalSupply.add(tokenAmount)<=MAX_SUPPLY);
		communityContributionSupply=communityContributionSupply.add(tokenAmount);
		totalSupply=totalSupply.add(tokenAmount);
		balances[msg.sender] += tokenAmount;
		CreateCRC(msg.sender, tokenAmount);
	}

	function etherProceeds() external
		etherProceedsAccountOnly
	{
		if(!msg.sender.send(this.balance)) revert();
	}
	



	function getCurrentBlockNum()  internal returns (uint256){
		return block.number;
	}

	function getEtherProceedsAccount() internal  returns (address){
		return etherProceedsAccount;
	}


	function getCrcWithdrawAccount() internal returns (address){
		return crcWithdrawAccount;
	}

	function setName(string _name) external
		onlyOwner
	{
		name=_name;
	}

	function setSymbol(string _symbol) external
		onlyOwner
	{
		symbol=_symbol;
	}


	function setEtherProceedsAccount(address _etherProceedsAccount) external
		onlyOwner
	{
		etherProceedsAccount=_etherProceedsAccount;
	}

	function setCrcWithdrawAccount(address _crcWithdrawAccount) external
		onlyOwner
	{
		crcWithdrawAccount=_crcWithdrawAccount;
	}

	function setFundingBlock(uint256 _fundingStartBlock,uint256 _fundingEndBlock,uint256 _teamKeepingLockEndBlock) external
		onlyOwner
	{

		fundingStartBlock=_fundingStartBlock;
		fundingEndBlock = _fundingEndBlock;
		teamKeepingLockEndBlock = _teamKeepingLockEndBlock;
	}


}
