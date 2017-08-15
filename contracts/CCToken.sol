pragma solidity ^0.4.13;

import './StandardToken.sol';
import './SafeMath.sol';
import './Ownable.sol';
contract CCToken is StandardToken,SafeMath,Ownable{

    string public constant name = "CCToken";
    string public constant symbol ="CCT";
    string public constant version = "1.0";
    uint256 public constant decimals = 18;

    
    
    
    uint256 public constant MAX_SUPPLY = 1000000000 * 10**decimals;
    uint256 public constant quota = MAX_SUPPLY/100;
    
    //the percentage of all usages
    uint256 public constant privateOfferingPercentage = 10;
    uint256 public constant pubilcOfferingPercentage = 60;
    uint256 public constant teamKeepingPercentage = 15;
    uint256 public constant communityContributionPercentage = 15;
    
    //the quota of all usages
    uint256 public constant privateOfferingQuota = quota*privateOfferingPercentage;
    uint256 public constant pubilcOfferingQuota = quota*pubilcOfferingPercentage;
    uint256 public constant teamKeepingQuota = quota*teamKeepingPercentage;
    uint256 public constant communityContributionQuota = quota*communityContributionPercentage; 



    uint256 public constant cctEthExchangeRate = 15000;
    //the max btcEthCap in the pubilcOfferingQuota
    uint256 public constant btcEthCap = pubilcOfferingQuota/10;
    uint256 public btcEthSupply;    
    
    address public etherProceedsAccount;
    address public btcEthFundingAccount;
    
    uint256 public fundStartBlock;
    uint256 public fundEndBlock;
    uint256 public teamKeepingLockEndBlock;

    bool public isFinalized;// switched to true in operational state

    event CreateCCT(address indexed _to, uint256 _value);
    
    // uint256 public

    function CCToken(uint256 _fundStartBlock , uint256 _fundEndBlock ,uint256 _teamKeepingLockEndBlock,address _etherProceedsAccount,address _btcEthFundingAccount){
        fundStartBlock = _fundStartBlock;
        fundEndBlock = _fundEndBlock;
        teamKeepingLockEndBlock=_teamKeepingLockEndBlock;
        etherProceedsAccount=_etherProceedsAccount;
        btcEthFundingAccount=_btcEthFundingAccount;
        totalSupply = 0 ;
        btcEthSupply = 0 ;
    }


    modifier beforeFundingStartBlock(){
        assert(block.number <= fundingStartBlock);
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
        assert(bolci.number>teamKeepingLockEndBlock);
        _;
    }
    
    modifier totalSupplyNotReached(uint256 _ethContribution){
        assert(safeAdd(totalSupply,safeMult(_ethContribution,cctEthExchangeRate)) <= MAX_SUPPLY);
        _;
    }
    
    modifier btcEthCapNotReached(uint256 _ethContribution){
        assert(safeAdd(btcEthSupply,safeMult(_ethContribution,cctEthExchangeRate)) <= btcEthCap);
        _;
    }
    modifier publicQuotaNotReached(uint256 _ethContribution){
        assert(safeAdd(btcEthSupply,safeMult(_ethContribution,cctEthExchangeRate)) <= btcEthCap);
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
    
    
    
   /**
        @dev handles contribution logic
        note that the Contribution event is triggered using the sender as the contributor, regardless of the actual contributor

        @return tokens issued in return
    */
    function processPublicFunding() internal
        totalSupplyNotReached(msg.value)
        
        validGasPrice
        returns (uint256 amount)
    {
        uint256 tokenAmount = computeReturn(msg.value);
        assert(beneficiary.send(msg.value)); // transfer the ether to the beneficiary account
        totalEtherContributed = safeAdd(totalEtherContributed, msg.value); // update the total contribution amount
        token.issue(msg.sender, tokenAmount); // issue new funds to the contributor in the smart token
        token.issue(beneficiary, tokenAmount); // issue tokens to the beneficiary

        Contribution(msg.sender, msg.value, tokenAmount);
        return tokenAmount;
    }

    // fallback
    function() payable {
        contributeETH();
    }

}

