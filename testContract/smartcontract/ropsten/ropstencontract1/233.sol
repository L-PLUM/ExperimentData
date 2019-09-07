/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.0;

// File: contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/ProductWarrantyDocumentManager.sol

contract ProductWarrantyDocumentManager is Ownable {
    using SafeMath for uint256;
    //PROCT_WTY
    //ProctWtyDocuState
    //ProductWarrantyDocumentState
    enum ProductWarrantyDocumentState {
        NotInitialized,
        NotUsing,
        IsUsing,
        Discarded
    }

    struct ProductWarrantyDocumentInfo {
        address ownerAddr;
        string productName;
        string hashedByIpfs;
        ProductWarrantyDocumentState state;
    }

    struct OwnershipInfo { 
        bytes32[] hashedData;
        /*address nextOwnerByContract;
        uint depositEth;
        uint period;*/
    }

    mapping (address => OwnershipInfo) ownershipInfo;
    mapping(bytes32 => ProductWarrantyDocumentInfo) internal warrantyDocInfo;
    //string[] internal hashedByIpfs;
    bytes32[] internal savedHashValue;

    /// @dev 제품 보증서 owner인 경우 function을 실행할 수 있습니다.
    modifier isOwnerOfWarrantyDoc(string memory _hashValue) {
        require(warrantyDocInfo[keccak256(bytes(_hashValue))].ownerAddr == msg.sender, "제품 보증서 owner가 아닙니다.");
        _;
    }

    constructor () public {
        clearWarrantyDocs();
    }

    ///@dev 해당 제품 보증서 등록
    ///@param _productName 제품명
    ///@param _hashValue 제품 보증서 해시 값
    function setWarrantyDoc(string calldata _productName, string calldata _hashValue) external {
        
        bytes32 hashedKeccak256 = keccak256(bytes(_hashValue));
        
        require(warrantyDocInfo[hashedKeccak256].state == ProductWarrantyDocumentState.NotInitialized, "이미 등록 되었던 제품 보증서 입니다.");

        warrantyDocInfo[hashedKeccak256].ownerAddr = msg.sender;
        warrantyDocInfo[hashedKeccak256].productName = _productName;
        warrantyDocInfo[hashedKeccak256].hashedByIpfs = _hashValue;
        warrantyDocInfo[hashedKeccak256].state = ProductWarrantyDocumentState.IsUsing;
        savedHashValue.push(hashedKeccak256);

        ownershipInfo[msg.sender].hashedData.push(hashedKeccak256);
    }

    ///@dev 해당 제품 보증서 소유자 변경
    ///@param _nextAccount 변경 되는 사용자 계정
    ///@param _hashValue 제품 보증서 해시 값
    function changeOwnership(address _nextAccount, string calldata _hashValue) external 
        isOwnerOfWarrantyDoc(_hashValue) {
        
        bytes32 hashedKeccak256 = keccak256(bytes(_hashValue));
        
        require(warrantyDocInfo[hashedKeccak256].state == ProductWarrantyDocumentState.IsUsing, "미사용중인 제품 보증서 입니다.");

        warrantyDocInfo[hashedKeccak256].ownerAddr = _nextAccount;
    }

    /*
    ///@dev 제품 보증서 소유자 변경 계약
    ///@param _nextAccount 변경 되는 사용자 계정
    ///@param _hashValue 제품 보증서 해시 값
    ///@param _amountEth 입금 받을 이더
    ///@param _period 입금 기한
    function changeOwnershipByContract(
        address _nextAccount, 
        string calldata _hashValue, 
        uint256 _depositEth,
        uint _period) external 
        isOwnerOfWarrantyDoc(_hashValue) {
        
        bytes32 hashedKeccak256 = keccak256(bytes(_hashValue));
        
        require(warrantyPDocInfo[hashedKeccak256].state == ProductWarrantyDocumentState.IsUsing, "미사용중인 제품 보증서 입니다.");

        ownershipInfo[msg.sender].nextOwnerByContract = _nextAccount;
        ownershipInfo[msg.sender].depositEth = _depositEth;
        ownershipInfo[msg.sender].period = _period;
    }
    */

    ///@dev 해당 제품 보증서 폐기
    ///@param _hashValue 제품 보증서 해시 값
    function discardWarrantyDoc(string calldata _hashValue) external isOwnerOfWarrantyDoc(_hashValue) {
        
        bytes32 hashedKeccak256 = keccak256(bytes(_hashValue));
        
        require(warrantyDocInfo[hashedKeccak256].state != ProductWarrantyDocumentState.NotInitialized, "미등록된 제품 보증서 입니다.");

        warrantyDocInfo[hashedKeccak256].ownerAddr = address(0);
        warrantyDocInfo[hashedKeccak256].productName = "";
        warrantyDocInfo[hashedKeccak256].hashedByIpfs = "";
        warrantyDocInfo[hashedKeccak256].state = ProductWarrantyDocumentState.Discarded;
    }

    ///@dev 해당 소유자의 제품 보증서 정보 가져오기
    ///@param _account 사용자 계정 주소
    ///@param _index 보증서 인덱스
    ///@return 제품명, 해시값
    function getInfoOwnerWarrantyDoc(address _account, uint _index) external view 
        returns (string memory productName, string memory hashValue) {
        require(ownershipInfo[_account].hashedData.length != 0, "해당 사용자는 등록된 보증서가 없습니다.");
        
        productName = warrantyDocInfo[ownershipInfo[_account].hashedData[_index]].productName;
        hashValue = warrantyDocInfo[ownershipInfo[_account].hashedData[_index]].hashedByIpfs;
    }

    ///@dev 제품 보증서 정보 가져오기
    ///@return 소유자, 제품명, 보증서 상태
    function getInfoWarrantyDoc(string calldata _hashValue) external view 
        returns (address ownerAddr, string memory productName, ProductWarrantyDocumentState state) {
        
        bytes32 hashedKeccak256 = keccak256(bytes(_hashValue));
        
        require(warrantyDocInfo[hashedKeccak256].state != ProductWarrantyDocumentState.NotInitialized, "미등록된 제품 보증서 입니다.");

        ownerAddr = warrantyDocInfo[hashedKeccak256].ownerAddr;
        productName = warrantyDocInfo[hashedKeccak256].productName;
        state = warrantyDocInfo[hashedKeccak256].state;
    }

    ///@dev 해당 소유자의 제품 보증서 수량 가져오기
    ///@param _account 사용자 계정 주소
    ///@return 등록된 보증서 수량
    function getNumOwnerWarrantyDocs(address _account) external view returns (uint) {

        return ownershipInfo[_account].hashedData.length;
    }

    ///@dev 전체 제품 보증서 수량 가져오기
    ///@return 등록된 보증서 수량
    function getNumWarrantyDocs() external view returns (uint) {

        return savedHashValue.length;
    }

    ///@dev 해당 제품 보증서 상태 가져오기
    ///@param _hashValue 보증서 해시값
    ///@return 상태 정보
    function getStateWarrantyDoc(string calldata _hashValue) external view returns (ProductWarrantyDocumentState) {
        return warrantyDocInfo[keccak256(bytes(_hashValue))].state;
    }

    /// @dev 제품 보증서 정보 초기화
    function clearWarrantyDocs() internal {
        for (uint i = 0; i < savedHashValue.length; i++) {
           // hashState[savedHashValue[i]] = ProductWarrantyDocumentState.NotInitialized;
        }

        delete savedHashValue;
    }
}
