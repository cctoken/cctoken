pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract CCToken is StandardToken,Ownable{
	//the base info of the token 
	string public constant name = "CCToken";
	string public constant symbol ="CCT";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	uint256 public constant MAX_SUPPLY = 1000000000 * 10**decimals;
	uint256 public constant quota = MAX_SUPPLY/100;
	uint256 public constant limitFundingEth = 1*10**decimals;

	//the percentage of all usages
	uint256 public constant allOfferingPercentage = 70;
	uint256 public constant teamKeepingPercentage = 15;
	uint256 public constant communityContributionPercentage = 15;

	//the quota of all usages
	uint256 public constant allOfferingQuota = quota*allOfferingPercentage;
	uint256 public constant teamKeepingQuota = quota*teamKeepingPercentage;
	uint256 public constant communityContributionQuota = quota*communityContributionPercentage;

	//the cap of diff offering channel
	//this percentage must less the the allOfferingPercentage
	uint256 public constant privateOfferingPercentage = 10;
	uint256 public constant privateOfferingCap = quota*privateOfferingPercentage;
	//we want to give some quota to the btc users,but this should occur before the ico
	uint256 public constant btcChannelCap = allOfferingQuota/10;

	//diff rate of the diff offering channel
	uint256 public constant publicOfferingExchangeRate = 15000;
	uint256 public constant privateOfferingExchangeRate = 45000;
	
	//need to edit
	address public constant etherProceedsAccount = 0x026aa9b30d4228f3d1491adbf2a1940e52601779;
	address public constant btcEthFundingAccount= 0xa678972fb6d53eb0cd2471c99fef9e09f5e18317;
	address public constant privateEthFundingAccount= 0xa07c00d8fc297f4a9607b35cc02ab00008fac963;
	address public constant teamWithdrawAccount= 0xcf69118925edeff49e8c208a6abe02c3fd64007b;
	address public constant communityContributionAccount= 0x653a67847901eb6548f2b09540fbbc5735433f35;

	//dependency on the start day
	uint256 public constant fundingStartBlock=4000000;
	uint256 public constant fundingEndBlock =fundingStartBlock+100800;
	uint256 public constant teamKeepingLockEndBlock = fundingEndBlock + 31536000;


	uint256 public btcEthSupply;
	uint256 public privateOfferingSupply;
	uint256 public allOfferingSupply;
	uint256 public teamWithdrawSupply;
	uint256 public communityContributionSupply;



	// bool public isFinalized;// switched to true in operational state

	event CreateCCT(address indexed _to, uint256 _value);

	// uint256 public

	function CCToken(){
		totalSupply = 0 ;
		btcEthSupply = 0 ;
		privateOfferingSupply=0;
		allOfferingSupply=0;
		communityContributionSupply=0;
		teamWithdrawSupply=0;

		// isFinalized=false;
	}


	modifier beforeFundingStartBlock(){
		assert(getCurrentBlockNum() <= fundingStartBlock);
		_;
	}
	modifier afterFundingEndBlock(){
		assert(getCurrentBlockNum() >= fundingEndBlock);
		_;
	}
	modifier notBeforeFundingStartBlock(){
		assert(getCurrentBlockNum() > fundingStartBlock);
		_;
	}
	modifier notAfterFundingEndBlock(){
		assert(getCurrentBlockNum() < fundingEndBlock);
		_;
	}
	modifier notBeforeTeamKeepingLockEndBlock(){
		assert(getCurrentBlockNum() > teamKeepingLockEndBlock);
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
	modifier btcEthCapNotReached(uint256 _ethContribution){
		assert(btcEthSupply.add(_ethContribution.mul(publicOfferingExchangeRate)) <= btcChannelCap);
		_;
	}
	modifier privateOfferingCapNotReached(uint256 _ethContribution){
		assert(privateOfferingSupply.add(_ethContribution.mul(privateOfferingExchangeRate)) <= privateOfferingCap);
		_;
	}	 
	
	// ensures that the sender is bitcoin suisse
	modifier btcEthFundingAccountOnly() {
		assert(msg.sender == getBtcEthFundingAccount());
		_;
	}
	modifier etherProceedsAccountOnly(){
		assert(msg.sender == getEtherProceedsAccount());
		_;
	}
	modifier privateEthFundingAccountOnly(){
		assert(msg.sender == getPrivateEthFundingAccount());
		_;
	}
	modifier limitFundingEthCheck(){
		assert(msg.value>=limitFundingEth);
		_;
	}

	function processEthPulicFunding() payable external
	 notBeforeFundingStartBlock
	 notAfterFundingEndBlock
	{
		processFunding(publicOfferingExchangeRate);
	}
	
	//we want to give some quota to the btc users,but this should occur before the ico	  
	function processBtcPulicFunding() payable external
	 beforeFundingStartBlock
	 btcEthFundingAccountOnly
	 btcEthCapNotReached(msg.value)
	{
		uint256 tokenAmount = msg.value.mul(publicOfferingExchangeRate);
		btcEthSupply=btcEthSupply.add(tokenAmount);
		processFunding(publicOfferingExchangeRate);
	}  
	
	function processPrivateFunding() payable external
	 beforeFundingStartBlock
	 privateEthFundingAccountOnly
	 privateOfferingCapNotReached(msg.value)
	{
		uint256 tokenAmount = msg.value.mul(privateOfferingExchangeRate);
		privateOfferingSupply=privateOfferingSupply.add(tokenAmount);
		processFunding(privateOfferingExchangeRate);
	}  
	
	
	function teamKeepingWithdraw(uint256 tokenAmount) external
	 onlyOwner
	 notBeforeTeamKeepingLockEndBlock
	{
		assert(teamWithdrawSupply.add(tokenAmount)<=teamKeepingQuota);
		assert(totalSupply.add(tokenAmount)<=MAX_SUPPLY);
		teamWithdrawSupply=teamWithdrawSupply.add(tokenAmount);
		totalSupply=totalSupply.add(tokenAmount);
		balances[getTeamWithdrawAccount()]+=tokenAmount;
		CreateCCT(getTeamWithdrawAccount(), tokenAmount);
	}

	function communityContributionWithdraw(uint256 tokenAmount) external
	 onlyOwner
	{
		assert(communityContributionSupply.add(tokenAmount)<=communityContributionQuota);
		assert(totalSupply.add(tokenAmount)<=MAX_SUPPLY);
		communityContributionSupply=communityContributionSupply.add(tokenAmount);
		totalSupply=totalSupply.add(tokenAmount);
		balances[getCommunityContributionAccount()] += tokenAmount;
		CreateCCT(getCommunityContributionAccount(), tokenAmount);
	}

	function etherProceeds() external
	 etherProceedsAccountOnly
	{
		if(!msg.sender.send(this.balance)) revert();
	}
	
   /**
		@dev handles Funding logic
		note that the Funding event is triggered using the sender as the funding, regardless of the actual funding
	*/
	function processFunding(uint256 fundingRate) internal
		totalSupplyNotReached(msg.value,fundingRate)
		allOfferingNotReached(msg.value,fundingRate)

	{
		uint256 tokenAmount = msg.value.mul(fundingRate);
		totalSupply=totalSupply.add(tokenAmount);
		allOfferingSupply=allOfferingSupply.add(tokenAmount);
		balances[msg.sender] += tokenAmount;  // safeAdd not needed; bad semantics to use here
		CreateCCT(msg.sender, tokenAmount);	 // logs token creation
	}
	// modifier notFinalized(){
	//	   assert(!isFinalized);
	//	   _;
	// }
	function getCurrentBlockNum()  internal returns (uint256){
		return block.number;
	}
	function getEtherProceedsAccount() internal  returns (address){
		return etherProceedsAccount;
	}
	function getBtcEthFundingAccount() internal  returns (address){
		return btcEthFundingAccount;
	}
	function getPrivateEthFundingAccount() internal  returns (address){
		return privateEthFundingAccount;
	}

	function getTeamWithdrawAccount() internal returns (address){
		return teamWithdrawAccount;
	}
	function getCommunityContributionAccount() internal  returns (address){
		return communityContributionAccount;
	}

}
