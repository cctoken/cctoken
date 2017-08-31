pragma solidity ^0.4.13;
import '../../contracts/CRCToken.sol';

contract CRCTokenMock is CRCToken{
    uint256 public currentBlockNum;

    function setCurrentBlockNum(uint256 _currentBlockNum) public {
        currentBlockNum=_currentBlockNum;
    }

	function getCurrentBlockNum()  internal returns (uint256){
		return currentBlockNum;
	}
}