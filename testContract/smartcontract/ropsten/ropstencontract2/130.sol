/**
 *Submitted for verification at Etherscan.io on 2019-08-11
*/

// Generated by Jthereum BETA version!
pragma solidity ^0.5.9;
contract SimpleEventEmitter
{
	function emitAnEvent(int32 anInt) public 
	{
		emit SimpleInt(anInt);
	}
	event SimpleInt(int32 a);


}
