pragma solidity ^0.4.13;

import './StandardToken.sol';

contract CCToken is StandardToken ,SafeMath{
    
    string public constant name = "CCToken";
    
    string public constant symbol ="CCT";
    
    address public endFundDeposit;
    
    address public betFundDeposit;
    
    uint256 public fundStartBlock;
    
    uint256 public fundEndBlock;
    
    unint8 public constant decimals = 1;
    
    uint256 public constant MAX_SUPPLY = 1000000000;
    
    uint256 public constant SUPPLY_DEIVE = div(MAX_SUPPLY,10);
    
    uint256 public 
    

    
    function CCToken(uint256 _fundStartBlock , uint256 _fundEndBlock , uint256 _totalSypply){
        fundStartBlock = _fundStartBlock;
        fundEndBlock = _fundEndBlock;
        totalSupply = _totalSupply;
        
    }
    
    
}


/**
 *
 *

