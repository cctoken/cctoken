pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract CCToken is StandardToken,Ownable{
	//the base info of the token 
    string public constant name = "CCToken";
    string public constant symbol ="CCT";
    string public constant version = "1.0";
    uint256 public constant decimals = 18;

    uint256 public constant MAX_SUPPLY = 1000000000 * 10**decimals;
    uint256 public constant quota = MAX_SUPPLY/100;

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
    
	
    uint256 public btcEthSupply;
    uint256 public privateOfferingSupply;
    uint256 public allOfferingSupply;
    uint256 public teamWithdrawSupply;
    uint256 public communityContributionSupply;

    address public etherProceedsAccount;
    address public btcEthFundingAccount;
    address public privateEthFundingAccount;
    address public teamWithdrawAccount;
    address public communityContributionAccount;
    
    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;
    uint256 public teamKeepingLockEndBlock;

    // bool public isFinalized;// switched to true in operational state

    event CreateCCT(address indexed _to, uint256 _value);

    // uint256 public

    function CCToken(uint256 _fundingStartBlock , uint256 _fundingEndBlock ,uint256 _teamKeepingLockEndBlock,address _etherProceedsAccount,address _btcEthFundingAccount,address _privateEthFundingAccount,address _teamWithdrawAccount,address _communityContributionAccount){
        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;
        teamKeepingLockEndBlock=_teamKeepingLockEndBlock;
        etherProceedsAccount=_etherProceedsAccount;
        btcEthFundingAccount=_btcEthFundingAccount;
        privateEthFundingAccount=_privateEthFundingAccount;
        teamWithdrawAccount=_teamWithdrawAccount;
        communityContributionAccount=_communityContributionAccount;
        totalSupply = 0 ;
        btcEthSupply = 0 ;
        privateOfferingSupply=0;
        allOfferingSupply=0;
        communityContributionSupply=0;
        teamWithdrawSupply=0;
        
        // isFinalized=false;
    }

    modifier beforeFundingStartBlock(){
        assert(block.number <= fundingStartBlock);
        _;
    }
    modifier afterFundingEndBlock(){
        assert(block.number >= fundingEndBlock);
        _;
    }
    modifier notBeforeFundingStartBlock(){
        assert(block.number > fundingStartBlock);
        _;
    }
    modifier notAfterFundingEndBlock(){
        assert(block.number < fundingEndBlock);
        _;
    }
    modifier notBeforeTeamKeepingLockEndBlock(){
        assert(block.number>teamKeepingLockEndBlock);
        _;
    }

    modifier totalSupplyNotReached(uint256 _ethContribution,uint rate){
        assert(SafeMath.add(totalSupply,SafeMath.mul(_ethContribution,rate)) <= MAX_SUPPLY);
        _;
    }
    modifier allOfferingNotReached(uint256 _ethContribution,uint rate){
        assert(SafeMath.add(allOfferingSupply,SafeMath.mul(_ethContribution,rate)) <= allOfferingQuota);
        _;
    }    
    modifier btcEthCapNotReached(uint256 _ethContribution){
        assert(SafeMath.add(btcEthSupply,SafeMath.mul(_ethContribution,publicOfferingExchangeRate)) <= btcChannelCap);
        _;
    }
    modifier privateOfferingCapNotReached(uint256 _ethContribution){
        assert(SafeMath.add(privateOfferingSupply,SafeMath.mul(_ethContribution,privateOfferingExchangeRate)) <= privateOfferingCap);
        _;
    }    
    
    // ensures that the sender is bitcoin suisse
    modifier btcEthFundingAccountOnly() {
        assert(msg.sender == btcEthFundingAccount);
        _;
    }
    modifier etherProceedsAccountOnly(){
        assert(msg.sender == etherProceedsAccount);
        _;
    }
    modifier privateEthFundingAccountOnly(){
        assert(msg.sender == privateEthFundingAccount);
        _;
    }

    // modifier notFinalized(){
    //     assert(!isFinalized);
    //     _;
    // }

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
		uint256 tokenAmount = SafeMath.mul(msg.value,publicOfferingExchangeRate);
		btcEthSupply=SafeMath.add(btcEthSupply,tokenAmount);
		processFunding(publicOfferingExchangeRate);
    }  
    
    function processPrivateFunding() payable external
     beforeFundingStartBlock
     privateEthFundingAccountOnly
     privateOfferingCapNotReached(msg.value)
    {
		uint256 tokenAmount = SafeMath.mul(msg.value,privateOfferingExchangeRate);
		privateOfferingSupply=SafeMath.add(privateOfferingSupply,tokenAmount);
		processFunding(privateOfferingExchangeRate);
    }  
    
    
    function teamKeepingWithdraw(uint256 tokenAmount) external
     onlyOwner
     notBeforeTeamKeepingLockEndBlock
    {
		assert(SafeMath.add(teamWithdrawSupply,tokenAmount)<=teamKeepingQuota);
		assert(SafeMath.add(totalSupply,tokenAmount)<=MAX_SUPPLY);
		teamWithdrawSupply=SafeMath.add(teamWithdrawSupply,tokenAmount);
		totalSupply=SafeMath.add(totalSupply,tokenAmount);
		balances[teamWithdrawAccount] += tokenAmount; 
    }

    function communityContributionWithdraw(uint256 tokenAmount) external
     onlyOwner
    {
        assert(SafeMath.add(communityContributionSupply,tokenAmount)<=communityContributionQuota);
        assert(SafeMath.add(totalSupply,tokenAmount)<=MAX_SUPPLY);
        communityContributionSupply=SafeMath.add(communityContributionSupply,tokenAmount);
        totalSupply=SafeMath.add(totalSupply,tokenAmount);
        balances[communityContributionAccount] += tokenAmount; 
    }

    function etherProceeds() external
     onlyOwner
    {
        if(!etherProceedsAccount.send(this.balance)) revert();
    }
    
   /**
        @dev handles Funding logic
        note that the Funding event is triggered using the sender as the funding, regardless of the actual funding
    */
    function processFunding(uint256 fundingRate) internal
        totalSupplyNotReached(msg.value,fundingRate)
        allOfferingNotReached(msg.value,fundingRate)
    {
        uint256 tokenAmount = SafeMath.mul(msg.value,fundingRate);
        totalSupply=SafeMath.add(totalSupply,tokenAmount);
        allOfferingSupply=SafeMath.add(allOfferingSupply,tokenAmount);
        balances[msg.sender] += tokenAmount;  // safeAdd not needed; bad semantics to use here
        CreateCCT(msg.sender, tokenAmount);  // logs token creation
    }

}
