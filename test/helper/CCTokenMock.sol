pragma solidity ^0.4.13;

import '../../contracts/CCToken.sol';
contract CCTokenMock is CCToken{
 uint256 currentBlockNum ;
	address public  etherProceedsAccount = 0x026aa9b30d4228f3d1491adbf2a1940e52601779;
    address public  btcEthFundingAccount= 0xa678972fb6d53eb0cd2471c99fef9e09f5e18317;
    address public  privateEthFundingAccount= 0xa07c00d8fc297f4a9607b35cc02ab00008fac963;
    address public  teamWithdrawAccount= 0xcf69118925edeff49e8c208a6abe02c3fd64007b;
    address public  communityContributionAccount= 0x653a67847901eb6548f2b09540fbbc5735433f35;

   function setEtherProceedsAccount(address _etherProceedsAccount) external{
        etherProceedsAccount=_etherProceedsAccount;
    }

   function setBtcEthFundingAccount(address _btcEthFundingAccount) external{
        btcEthFundingAccount=_btcEthFundingAccount;
   }

   function setPrivateEthFundingAccount(address _privateEthFundingAccount) external{
        privateEthFundingAccount=_privateEthFundingAccount;
   }

   function setTeamWithdrawAccount(address _teamWithdrawAccount) external{
        teamWithdrawAccount=_teamWithdrawAccount;
   }

   function setCommunityContributionAccount(address _communityContributionAccount) external{
         communityContributionAccount=_communityContributionAccount;
   }

    function setCurrentBlockNum(uint _currentBlockNum) external{
        currentBlockNum=_currentBlockNum;
    }

    function getCurrentBlockNum() internal returns (uint256){
        return currentBlockNum;
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

    function getTeamWithdrawAccount()  internal returns (address){
            return teamWithdrawAccount;
    }
    function getCommunityContributionAccount() internal  returns (address){
            return communityContributionAccount;
    }
}
