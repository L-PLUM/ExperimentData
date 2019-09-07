/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

/**

Deployed by Ren Project, https://renproject.io

Commit hash: 77351c4
Repository: https://github.com/renproject/darknode-sol
Issues: https://github.com/renproject/darknode-sol/issues

Licenses
openzeppelin-solidity: (MIT) https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/LICENSE
darknode-sol: (GNU GPL V3) https://github.com/renproject/darknode-sol/blob/master/LICENSE

*/

pragma solidity ^0.5.8;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library ECDSA {
    
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        
        if (signature.length != 65) {
            return (address(0));
        }

        
        bytes32 r;
        bytes32 s;
        uint8 v;

        
        
        
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        
        
        
        
        
        
        
        
        
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        
        return ecrecover(hash, v, r, s);
    }

    
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        
        
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

library String {

    
    function fromBytes32(bytes32 _value) internal pure returns(string memory) {
        bytes32 value = bytes32(uint256(_value));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(32 * 2 + 2);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 32; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i] & 0x0f))];
        }
        return string(str);
    }

    
    function fromAddress(address _addr) internal pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(20 * 2 + 2);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }

    
    function add4(string memory a, string memory b, string memory c, string memory d) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c, d));
    }
}

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract Claimable {
    address private _pendingOwner;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "caller is not the owner");
        _;
    }

    
    modifier onlyPendingOwner() {
      require(msg.sender == _pendingOwner, "caller is not the pending owner");
      _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
      _pendingOwner = newOwner;
    }

    
    function claimOwnership() public onlyPendingOwner {
      emit OwnershipTransferred(_owner, _pendingOwner);
      _owner = _pendingOwner;
      _pendingOwner = address(0);
    }
}

contract ERC20Shifted is ERC20, ERC20Detailed, Claimable {

    
    constructor(string memory _name, string memory _symbol, uint8 _decimals) public ERC20Detailed(_name, _symbol, _decimals) {}

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}

contract zBTC is ERC20Shifted("Shifted BTC", "zBTC", 8) {}

contract zZEC is ERC20Shifted("Shifted ZEC", "zZEC", 8) {}

contract Shifter is Ownable {
    using SafeMath for uint256;

    uint8 public version = 2;

    uint256 constant BIPS_DENOMINATOR = 10000;
    uint256 public minShiftAmount;

    
    ERC20Shifted public token;

    
    address public mintAuthority;

    
    
    
    
    address public feeRecipient;

    
    uint16 public fee;

    
    mapping (bytes32=>bool) public status;

    
    
    uint256 public nextShiftID = 0;

    event LogShiftIn(address indexed _to, uint256 _amount, uint256 indexed _shiftID);
    event LogShiftOut(bytes _to, uint256 _amount, uint256 indexed _shiftID, bytes indexed _indexedTo);

    
    
    
    
    
    
    constructor(ERC20Shifted _token, address _feeRecipient, address _mintAuthority, uint16 _fee, uint256 _minShiftOutAmount) public {
        minShiftAmount = _minShiftOutAmount;
        token = _token;
        mintAuthority = _mintAuthority;
        fee = _fee;
        updateFeeRecipient(_feeRecipient);
    }

    

    
    
    
    function claimTokenOwnership() public {
        token.claimOwnership();
    }

    
    function transferTokenOwnership(Shifter _nextTokenOwner) public onlyOwner {
        token.transferOwnership(address(_nextTokenOwner));
        _nextTokenOwner.claimTokenOwnership();
    }

    
    
    
    function updateMintAuthority(address _nextMintAuthority) public onlyOwner {
        mintAuthority = _nextMintAuthority;
    }

    
    
    
    function updateMinimumShiftOutAmount(uint256 _minShiftOutAmount) public onlyOwner {
        minShiftAmount = _minShiftOutAmount;
    }

    
    
    
    function updateFeeRecipient(address _nextFeeRecipient) public onlyOwner {
        
        require(_nextFeeRecipient != address(0x0), "fee recipient cannot be 0x0");

        feeRecipient = _nextFeeRecipient;
    }

    
    
    
    function updateFee(uint16 _nextFee) public onlyOwner {
        fee = _nextFee;
    }

    
    
    
    
    
    
    
    
    
    function shiftIn(bytes32 _pHash, uint256 _amount, bytes32 _nHash, bytes memory _sig) public returns (uint256) {
        
        bytes32 signedMessageHash = hashForSignature(_pHash, _amount, msg.sender, _nHash);
        require(status[signedMessageHash] == false, "nonce hash already spent");
        if (!verifySignature(signedMessageHash, _sig)) {
            
            
            
            revert(
                String.add4(
                    "invalid signature - hash: ",
                    String.fromBytes32(signedMessageHash),
                    ", signer: ",
                    String.fromAddress(ECDSA.recover(signedMessageHash, _sig))
                )
            );
        }
        status[signedMessageHash] = true;

        
        uint256 absoluteFee = (_amount.mul(fee)).div(BIPS_DENOMINATOR);
        uint256 receivedAmount = _amount.sub(absoluteFee);
        token.mint(msg.sender, receivedAmount);
        token.mint(feeRecipient, absoluteFee);

        
        emit LogShiftIn(msg.sender, receivedAmount, nextShiftID);
        nextShiftID += 1;

        return receivedAmount;
    }

    
    
    
    
    
    
    
    
    function shiftOut(bytes memory _to, uint256 _amount) public returns (uint256) {
        
        
        require(_to.length != 0, "to address is empty");
        require(_amount >= minShiftAmount, "amount is less than the minimum shiftOut amount");

        
        uint256 absoluteFee = (_amount.mul(fee)).div(BIPS_DENOMINATOR);
        token.burn(msg.sender, _amount);
        token.mint(feeRecipient, absoluteFee);

        
        uint256 receivedValue = _amount.sub(absoluteFee);
        emit LogShiftOut(_to, receivedValue, nextShiftID, _to);
        nextShiftID += 1;

        return receivedValue;
    }

    
    
    function verifySignature(bytes32 _signedMessageHash, bytes memory _sig) public view returns (bool) {
        return mintAuthority == ECDSA.recover(_signedMessageHash, _sig);
    }

    
    function hashForSignature(bytes32 _pHash, uint256 _amount, address _to, bytes32 _nHash) public view returns (bytes32) {
        return keccak256(abi.encode(_pHash, _amount, address(token), _to, _nHash));
    }
}

contract BTCShifter is Shifter {
    constructor(ERC20Shifted _token, address _feeRecipient, address _mintAuthority, uint16 _fee, uint256 _minShiftOutAmount)
        Shifter(_token, _feeRecipient, _mintAuthority, _fee, _minShiftOutAmount) public {
        }
}

contract ZECShifter is Shifter {
    constructor(ERC20Shifted _token, address _feeRecipient, address _mintAuthority, uint16 _fee, uint256 _minShiftOutAmount)
        Shifter(_token, _feeRecipient, _mintAuthority, _fee, _minShiftOutAmount) public {
        }
}

contract DEXReserve is Ownable {
    ERC20 public ethereum = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    mapping (address => Shifter) public getShifter;
    mapping (address => bool) public isShifted;
    mapping (address=>uint256) public approvals;

    
    function() external payable {
    }

    function approve(ERC20 _token, address spender, uint256 value) external onlyOwner {
        if (_token == ethereum) {
            approvals[spender] += value;
        } else {
            _token.approve(spender, value);
        }
    }

    function setShifter(ERC20 _token, Shifter _shifter) external onlyOwner {
        isShifted[address(_token)] = true;
        getShifter[address(_token)] = _shifter;
    }

    function transfer(address payable _to, uint256 _value) external {
        require(approvals[msg.sender] >= _value, "insufficient approval amount");
        approvals[msg.sender] -= _value;
        _to.transfer(_value);
    }

    function withdraw(ERC20 _token, bytes calldata _to, uint256 _amount) external onlyOwner {
        if (_token == ethereum) {
            bytesToAddress(_to).transfer(_amount);
        } else {
            if (isShifted[address(_token)]) {
                getShifter[address(_token)].shiftOut(_to, _amount);
            } else {
                _token.transfer(bytesToAddress(_to), _amount);
            }
        }
    }

    function bytesToAddress(bytes memory _addr) internal pure returns (address payable) {
        address payable addr;
         
        assembly {
            addr := mload(add(_addr, 20))
        }
    }
}

contract BTC_DAI_Reserve is DEXReserve {}

contract ZEC_DAI_Reserve is DEXReserve {}

contract DEX {
    mapping (bytes32=>address payable) public reserves;
    ERC20 public ethereum = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    event LogTrade(ERC20 _src, ERC20 _dst, uint256 _sendAmount, uint256 _recvAmount); 
    uint256 public feeinBIPs;

    constructor(uint256 _feeinBIPs) public {
        feeinBIPs = _feeinBIPs;
    }

    function trade(address payable _to, ERC20 _src, ERC20 _dst, uint256 _sendAmount) public payable returns (uint256) {
        address payable reserve = reserve(_src, _dst);
        require(reserve != address(0x0), "unsupported token pair");
        uint256 recvAmount = calculateReceiveAmount(_src, _dst, _sendAmount);

        if (_src != ethereum) {
            require(_src.transferFrom(msg.sender, reserve, _sendAmount), "source token transfer failed");
        } else {
            require(msg.value >= _sendAmount, "invalid msg.value");
            reserve.transfer(msg.value);
        }

        if (_dst != ethereum) {
            require(_dst.transferFrom(reserve, _to, recvAmount), "destination token transfer failed");
        } else {
            DEXReserve(reserve).transfer(_to, recvAmount);
        }

        emit LogTrade(_src, _dst, _sendAmount, recvAmount);
        return recvAmount;
    }

    function registerReserve(ERC20 _a, ERC20 _b, address payable _reserve) public {
        reserves[tokenPairID(_a, _b)] = _reserve;
    }

    function calculateReceiveAmount(ERC20 _src, ERC20 _dst, uint256 _sendAmount) public view returns (uint256) {
        address reserve = reserve(_src, _dst);
        uint256 srcAmount = _src == ethereum ? reserve.balance : _src.balanceOf(reserve);
        uint256 dstAmount = _dst == ethereum ? reserve.balance : _dst.balanceOf(reserve);
        uint256 rcvAmount = dstAmount - ((srcAmount*dstAmount)/(srcAmount+_sendAmount));
        return (rcvAmount * (10000 - feeinBIPs))/10000;
    }

    function reserve(ERC20 _a, ERC20 _b) public view returns (address payable) {
        return reserves[tokenPairID(_a, _b)];
    }
    
    function tokenPairID(ERC20 _a, ERC20 _b) public pure returns (bytes32) {
        return uint160(address(_a)) < uint160(address(_b)) ? 
            keccak256(abi.encodePacked(_a, _b)) : keccak256(abi.encodePacked(_b, _a));
    }
}

contract DEXAdapter is Ownable {
    DEX public dex;

    event LogTransferIn(ERC20 src, uint256 amount);
    event LogTransferOut(ERC20 dst, uint256 amount);

    constructor(DEX _dex) public {
        dex = _dex;
    }

    
    function() external payable {
    }

    
    uint256 transferredAmt;
    bytes32 pHash;

    function trade(
        
         ERC20 _src, ERC20 _dst, uint256 _minDstAmt, bytes calldata _to,
        uint256 _refundBN, bytes calldata _refundAddress,
        
        uint256 _amount, bytes32 _nHash, bytes calldata _sig
    ) external payable {
        pHash = hashPayload(_src, _dst, _minDstAmt, _to, _refundBN, _refundAddress);
        transferredAmt = _transferIn(_src, _dst, _amount, _nHash, pHash, _sig);
        emit LogTransferIn(_src, _amount);

        
        if (block.number > _refundBN) {
            if (DEXReserve(dex.reserve(_src, _dst)).isShifted(address(_src))) {
                DEXReserve(dex.reserve(_src, _dst)).getShifter(address(_src)).shiftOut(_refundAddress, transferredAmt);
            }
            
            return;
        }

        _doTrade(_src, _dst, _minDstAmt, _to, transferredAmt);
    }

    function hashPayload(
         ERC20 _src, ERC20 _dst, uint256 _minDstAmt, bytes memory _to,
        uint256 _refundBN, bytes memory _refundAddress
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_src, _dst, _minDstAmt, _to, _refundBN, _refundAddress));
    }

    function encodePayload(
         ERC20 _src, ERC20 _dst, uint256 _minDstAmt, bytes memory _to,
        uint256 _refundBN, bytes memory _refundAddress
    ) public pure returns (bytes memory) {
        return abi.encode(_src, _dst, _minDstAmt, _to, _refundBN, _refundAddress);
    }

    function _doTrade(
        ERC20 _src, ERC20 _dst, uint256 _minDstAmt, bytes memory _to, uint256 _amount
    ) internal {
        uint256 recvAmt;
        address payable to;
        DEXReserve reserve = DEXReserve(dex.reserve(_src, _dst));

        if (reserve.isShifted(address(_dst))) {
            to = address(this);
        } else {
            to = _bytesToAddress(_to);
        }

        if (_src == dex.ethereum()) {
            recvAmt = dex.trade.value(msg.value)(to, _src, _dst, _amount);
        } else {
            _src.approve(address(dex), _amount);
            recvAmt = dex.trade(to, _src, _dst, _amount);
        }

        require(recvAmt > _minDstAmt, "invalid receive amount");
        if (reserve.isShifted(address(_dst))) {
            reserve.getShifter(address(_dst)).shiftOut(_to, recvAmt);
        }
        emit LogTransferOut(_dst, recvAmt);
    }

    function _transferIn(
         ERC20 _src, ERC20 _dst, uint256 _amount,
        bytes32 _nHash, bytes32 _pHash, bytes memory _sig
    ) internal returns (uint256) {
        DEXReserve reserve = DEXReserve(dex.reserve(_src, _dst));

        if (reserve.isShifted(address(_src))) {
            return reserve.getShifter(address(_src)).shiftIn(_pHash, _amount, _nHash, _sig);
        } else if (_src == dex.ethereum()) {
            require(msg.value >= _amount, "insufficient eth amount");
            return msg.value;
        } else {
            require(_src.transferFrom(msg.sender, address(this), _amount), "source token transfer failed");
            return _amount;
        }
    }

    function _bytesToAddress(bytes memory _addr) internal pure returns (address payable) {
        address payable addr;
         
        assembly {
            addr := mload(add(_addr, 20))
        }
        return addr;
    }
}
