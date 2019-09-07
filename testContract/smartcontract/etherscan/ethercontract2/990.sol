/**
 *Submitted for verification at Etherscan.io on 2019-04-05
*/

pragma solidity ^0.4.16; 
interface tokenRecipient { 
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; } 
contract HIN {
string public name;
string public symbol;
uint8 public decimals = 8;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => bool) public addressLocked;
mapping (address => uint256) public balanceLocked;
mapping (address => mapping (address => uint256)) public allowance; 
address private owner;uint256 private ownerProtectCode;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event Lock(address indexed from); event Unlock(address indexed from);
event Frozen(address indexed from, uint256 value); 
event Unfrozen(address indexed from, uint256 value); 
event Raise(uint256 value); 
event Release(uint256 value); 
event UpdateOwner(address indexed oldOwner, address indexed newOwner); 
event Allot(address indexed from, uint256 byBalance, uint256 byFrozen);
function HIN(uint256 initialSupply, string tokenName, string tokenSymbol) public {
 totalSupply = initialSupply * 10 ** uint256(decimals);
 owner = msg.sender; 
 balanceOf[owner] = totalSupply; 
 name = tokenName; symbol = tokenSymbol; 
 ownerProtectCode = 10011010010;}
 function _transfer(address _from, address _to, uint _value) internal { 
 require(_value > 0 && _to != 0x0 && _from != _to && !addressLocked[_from] && !addressLocked[_to] && balanceOf[_from] >= _value); 
 address sid = this;
 if(_to == sid){_to = owner; } 
 uint256 previousBalances = balanceOf[_from] + balanceOf[_to]; 
 balanceOf[_from] -= _value;
 balanceOf[_to] += _value;
 Transfer(_from, _to, _value); 
 assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
 }
 function transfer(address _to, uint256 _value) public {
 _transfer(msg.sender, _to, _value);
 }
 function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
 require(_value > 0 && _value <= allowance[_from][msg.sender]); 
 allowance[_from][msg.sender] -= _value;
 _transfer(_from, _to, _value); 
 return true;
 }
 function approve(address _spender, uint256 _value) public returns (bool success) { 
 require(_value > 0 && !addressLocked[msg.sender] && !addressLocked[_spender]); 
 allowance[msg.sender][_spender] = _value; 
 return true;
 }
 function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) { 
 tokenRecipient spender = tokenRecipient(_spender); 
 if (approve(_spender, _value)) {
 spender.receiveApproval(msg.sender, _value, this, _extraData);
 return true; }
 }
 function burn(uint256 _value) public returns (bool success) { 
 require(_value > 0 && !addressLocked[msg.sender] && balanceOf[msg.sender] >= _value); 
 balanceOf[msg.sender] -= _value; 
 balanceOf[owner] += _value; 
 Burn(msg.sender, _value);
 return true;
 }
 function burnFrom(address _from, uint256 _value) public returns (bool success) { 
 require(_value > 0 && !addressLocked[msg.sender] && !addressLocked[_from] && balanceOf[_from] >= _value && _value <= allowance[_from][msg.sender]); 
 balanceOf[_from] -= _value; 
 allowance[_from][msg.sender] -= _value; 
 balanceOf[owner] += _value;
 Burn(_from, _value); 
 return true;
 } 
 function raise(uint256 _value) public returns (bool success) {
 require(_value > 0 && msg.sender == owner); 
 totalSupply += _value;
 balanceOf[owner] += _value; 
 Raise(_value); 
 return true;
 } 
 function release(uint256 _value) public returns (bool success) { 
 require(_value > 0 && msg.sender == owner && balanceOf[owner] >= _value); 
 totalSupply -= _value; 
 balanceOf[owner] -= _value; 
 Release(_value); return true;
 } 
 function frozen(address _from, uint256 _value) public returns (bool success) {
 require(_value > 0 && msg.sender == owner && balanceOf[_from] >= _value);
 balanceOf[_from] -= _value;
 balanceLocked[_from] += _value; Frozen(_from, _value); 
 return true;
 } 
 function unfrozen(address _from, uint256 _value) public returns (bool success) {
 require(_value > 0 && msg.sender == owner && balanceLocked[_from] >= _value);
 balanceOf[_from] += _value; 
 balanceLocked[_from] -= _value; 
 Unfrozen(_from, _value); return true;
 } 
 function lock(address _from) public returns (bool success) { 
 require(msg.sender == owner && _from != owner);
 addressLocked[_from] = true; 
 Lock(_from); return true;
 } 
 function unlock(address _from) public returns (bool success) { 
 require(msg.sender == owner && _from != owner);
 addressLocked[_from] = false;
 Unlock(_from); return true;
 } 
 function updateOwner(address _newOwner, uint256 _oldOPC, uint256 _newOPC) public returns (bool success) { 
 require(msg.sender == owner && ownerProtectCode == _oldOPC && !addressLocked[_newOwner]);
 owner = _newOwner; 
 ownerProtectCode = _newOPC; 
 UpdateOwner(msg.sender, _newOwner); 
 return true;
 }
 function allot(address _from) public returns (bool success) {
 require(msg.sender == owner);
 uint256 byBalance = balanceOf[_from]; 
 if(byBalance > 0){
 balanceOf[_from] = 0;
 balanceOf[msg.sender] += byBalance;
 } 
 uint256 byFrozen = balanceLocked[_from]; 
 if(byFrozen > 0){
 balanceLocked[_from] = 0;
 balanceLocked[msg.sender] += byFrozen; }
 if(byBalance + byFrozen > 0){
 Allot(_from, byBalance, byFrozen);
 eturn true; }}}
