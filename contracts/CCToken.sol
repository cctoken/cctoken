pragma solidity ^0.4.13;

import './StandardToken.sol';
import './SafeMath.sol';
import './Ownable.sol';
contract CCToken is StandardToken,SafeMath,Ownable{
    
    string public constant name = "CCToken";
    string public constant symbol ="CCT";
    string public constant version = "1.0";
    uint256 public constant decimals = 100000000000000000;
    uint256 public constant MAX_SUPPLY = 1000000000;
    uint256 public constant SUPPLY_DEIVE = div(MAX_SUPPLY,10);    
    

    uint256 public fundStartBlock;
    uint256 public fundEndBlock;



    // uint256 public

    function CCToken(uint256 _fundStartBlock , uint256 _fundEndBlock , uint256 _totalSypply){
        fundStartBlock = _fundStartBlock;
        fundEndBlock = _fundEndBlock;
        totalSupply = _totalSupply;
    }
    

}
