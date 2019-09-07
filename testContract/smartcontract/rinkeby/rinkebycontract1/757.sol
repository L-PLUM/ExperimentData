/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity ^0.4.13;

contract IERC20Token {

    // EVENTS

    /// @dev Emits when ownership of any tokens changes by any mechanism.
    /// This event also emits when tokens are created (`from` == 0) and destroyed (`to` == 0).
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    /// @dev Emits when the approved address for a tokens is changed or reaffirmed.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // EXTERNAL FUNCTIONS

    /// @dev Sends `value` amount of tokens to account `to` from account `msg.sender`.
    /// @param to The address of the tokens recipient.
    /// @param value The amount of tokens to be transferred.
    /// @return True if transfer was successful.
    function transfer(address to, uint256 value) external returns (bool);

    /// @dev Sends `value` amount of tokens to account `to` from account `from` if enough amount of
    /// tokens are approved by account `from` to spend by account `msg.sender`.
    /// @param from The address of the tokens sender.
    /// @param to The address of the tokens recipient.
    /// @param value The amount of tokens to be transferred.
    /// @return True if transfer was successful.
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    
    /// @dev Approves account `spender` by account `msg.sender` to spend `value` amount of tokens.
    /// @param spender The address of the account able to transfer the tokens.
    /// @param value The new amount of tokens to be approved for transfer.
    /// @return True if approve was successful.
    function approve(address spender, uint256 value) external returns (bool);

    // EXTERNAL FUNCTIONS (VIEW)

    /// @dev Returns total amount of supplied tokens.
    /// @return Total amount of supplied tokens.
    function totalSupply() external view returns (uint256);
    
    /// @dev Returns the balance of account with address `owner`.
    /// @param owner The address from which the balance will be retrieved.
    /// @return Amount of tokens hold by account with address `owner`.
    function balanceOf(address owner) external view returns (uint256);

    /// @dev Returns the amount of tokens hold by account `owner` and approved to spend by account `spender`.
    /// @param owner The address of the account owning tokens.
    /// @param spender The address of the account able to transfer the tokens owning by account `owner`.
    /// @return Amount of tokens allowed to spend.
    function allowance(address owner, address spender) external view returns (uint256);
}

library LibBytes {

    using LibBytes for bytes;

    /// @dev Gets the memory address for a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of byte array. This
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }
    
    /// @dev Gets the memory address for the contents of a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    /// @dev Copies `length` bytes from memory location `source` to `dest`.
    /// @param dest memory address to copy bytes to.
    /// @param source memory address to copy bytes from.
    /// @param length number of bytes to copy.
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }
                    
                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }
                    
                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    /// @dev Returns a slices from a byte array.
    /// @param b The byte array to take a slice from.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to < b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }
    
    /// @dev Returns a slice from a byte array without preserving the input.
    /// @param b The byte array to take a slice from. Will be destroyed in the process.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    /// @dev When `from == 0`, the original array will match the slice. In other cases its state will be corrupted.
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to < b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    /// @dev Pops the last byte off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The byte that was popped off.
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        require(
            b.length > 0,
            "GREATER_THAN_ZERO_LENGTH_REQUIRED"
        );

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Pops the last 20 bytes off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The 20 byte address that was popped off.
    function popLast20Bytes(bytes memory b)
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= 20,
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Store last 20 bytes.
        result = readAddress(b, b.length - 20);

        assembly {
            // Subtract 20 from byte array length.
            let newLen := sub(mload(b), 20)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Tests equality of two byte arrays.
    /// @param lhs First byte array to compare.
    /// @param rhs Second byte array to compare.
    /// @return True if arrays are the same. False otherwise.
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    /// @dev Reads an address from a position in a byte array.
    /// @param b Byte array containing an address.
    /// @param index Index in byte array of address.
    /// @return address from byte array.
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    /// @dev Writes an address into a specific position in a byte array.
    /// @param b Byte array to insert address into.
    /// @param index Index in byte array of address.
    /// @param input Address to put into byte array.
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )
            
            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    /// @dev Reads a bytes32 value from a position in a byte array.
    /// @param b Byte array containing a bytes32 value.
    /// @param index Index in byte array of bytes32 value.
    /// @return bytes32 value from byte array.
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    /// @dev Writes a bytes32 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes32 to put into byte array.
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    /// @dev Reads a uint256 value from a position in a byte array.
    /// @param b Byte array containing a uint256 value.
    /// @param index Index in byte array of uint256 value.
    /// @return uint256 value from byte array.
    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    /// @dev Writes a uint256 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input uint256 to put into byte array.
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    /// @dev Reads an unpadded bytes4 value from a position in a byte array.
    /// @param b Byte array containing a bytes4 value.
    /// @param index Index in byte array of bytes4 value.
    /// @return bytes4 value from byte array.
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    /// @dev Reads nested bytes from a specific position.
    /// @dev NOTE: the returned value overlaps with the input value.
    ///            Both should be treated as immutable.
    /// @param b Byte array containing nested bytes.
    /// @param index Index of nested bytes.
    /// @return result Nested bytes.
    function readBytesWithLength(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Read length of nested bytes
        uint256 nestedBytesLength = readUint256(b, index);
        index += 32;

        // Assert length of <b> is valid, given
        // length of nested bytes
        require(
            b.length >= index + nestedBytesLength,
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );
        
        // Return a pointer to the byte array as it exists inside `b`
        assembly {
            result := add(b, index)
        }
        return result;
    }

    /// @dev Inserts bytes at a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes to insert.
    function writeBytesWithLength(
        bytes memory b,
        uint256 index,
        bytes memory input
    )
        internal
        pure
    {
        // Assert length of <b> is valid, given
        // length of input
        require(
            b.length >= index + 32 + input.length,  // 32 bytes to store length
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );

        // Copy <input> into <b>
        memCopy(
            b.contentAddress() + index,
            input.rawAddress(), // includes length of <input>
            input.length + 32   // +32 bytes to store <input> length
        );
    }

    /// @dev Performs a deep copy of a byte array onto another byte array of greater than or equal length.
    /// @param dest Byte array that will be overwritten with source bytes.
    /// @param source Byte array to copy onto dest bytes.
    function deepCopyBytes(
        bytes memory dest,
        bytes memory source
    )
        internal
        pure
    {
        uint256 sourceLen = source.length;
        // Dest length must be >= source length, or some bytes would not be copied.
        require(
            dest.length >= sourceLen,
            "GREATER_OR_EQUAL_TO_SOURCE_BYTES_LENGTH_REQUIRED"
        );
        memCopy(
            dest.contentAddress(),
            source.contentAddress(),
            sourceLen
        );
    }
}

contract SafeMath {

    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(
            c / a == b,
            "UINT256_OVERFLOW"
        );
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(
            b <= a,
            "UINT256_UNDERFLOW"
        );
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        require(
            c >= a,
            "UINT256_OVERFLOW"
        );
        return c;
    }

    function max64(uint64 a, uint64 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }
}

contract ERC20Token is IERC20Token, SafeMath {
    using LibBytes for bytes;

    // EXTERNAL FUNCTIONS

    constructor() public {
        _totalSupply = INITIAL_SUPPLY;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /// @dev Sends `value` amount of tokens to account `to` from account `msg.sender`.
    /// @param to The address of the tokens recipient.
    /// @param value The amount of tokens to be transferred.
    /// @return True if transfer was successful.
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /// @dev Sends `value` amount of tokens to account `to` from account `from` if enough amount of
    /// tokens are approved by account `from` to spend by account `msg.sender`.
    /// @param from The address of the tokens sender.
    /// @param to The address of the tokens recipient.
    /// @param value The amount of tokens to be transferred.
    /// @return True if transfer was successful.
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        _decreaseAllowance(from, msg.sender, value);
        _transfer(from, to, value);
        return true;
    }

    /// @dev Approves account with address `spender` to spend `value` amount of tokens on behalf of account `msg.sender`.
    /// Beware that changing an allowance with this method brings the risk that someone may use both the old
    /// and the new allowance by an unfortunate transaction ordering. One possible solution to mitigate this
    /// rare condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    /// @param spender Address which will be allowed to spend the tokens.
    /// @param value Amount of tokens to allow to be spent.
    /// @return True if approve was successful.
    function approve(address spender, uint256 value) external returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /// @dev Increases the amount of tokens that account `msg.sender` allowed to spend by account `spender`.
    /// Method approve() should be called when _allowances[spender] == 0. To decrement allowance
    /// it is better to use this function to avoid 2 calls (and waiting until the first transaction is mined).
    /// @param spender The address from which the tokens can be spent.
    /// @param value The amount of tokens to increase the allowance by.
    /// @return True if approve was successful.
    function increaseAllowance(address spender, uint256 value) external returns (bool) {
        require(spender != address(0));
        _increaseAllowance(msg.sender, spender, value);
        return true;
    }

    /// @dev Decreases the amount of tokens that account `msg.sender` allowed to spend by account `spender`.
    /// Method approve() should be called when _allowances[spender] == 0. To decrement allowance
    /// it is better to use this function to avoid 2 calls (and waiting until the first transaction is mined).
    /// @param spender The address from which the tokens can be spent.
    /// @param value The amount of tokens to decrease the allowance by.
    /// @return True if approve was successful.
    function decreaseAllowance(address spender, uint256 value) external returns (bool) {
        require(spender != address(0));
        _decreaseAllowance(msg.sender, spender, value);
        return true;
    }

    // EXTERNAL FUNCTIONS (VIEW)

    /// @dev Returns total amount of supplied tokens.
    /// @return Total amount of supplied tokens.
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /// @dev Returns the balance of account with address `owner`.
    /// @param owner The address from which the balance will be retrieved.
    /// @return Amount of tokens hold by account with address `owner`.
    function balanceOf(address owner) external view returns (uint256) {
        return _balances[owner];
    }

    /// @dev Returns the amount of tokens hold by account `owner` and approved to spend by account `spender`.
    /// @param owner The address of the account owning tokens.
    /// @param spender The address of the account able to transfer the tokens owning by account `owner`.
    /// @return Amount of tokens allowed to spend.
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    // INTERNAL FUNCTIONS

    /// @dev Transfers tokens from account with address `from` to account with address `to`.
    /// @param from The address of the tokens sender.
    /// @param to The address of the tokens recipient.
    /// @param value The amount of tokens to be transferred.
    function _transfer(address from, address to, uint256 value) internal {
        require(value > 0 && value <= _balances[from]);
        _balances[from] = safeSub(_balances[from], value);
        _balances[to] = safeAdd(_balances[to], value);
        emit Transfer(from, to, value);
    }

    /// @dev Increases the amount of tokens that account `owner` allowed to spend by account `spender`.
    /// Method approve() should be called when _allowances[spender] == 0. To decrement allowance
    /// it is better to use this function to avoid 2 calls (and waiting until the first transaction is mined).
    /// @param owner The address which owns the tokens.
    /// @param spender The address from which the tokens can be spent.
    /// @param value The amount of tokens to increase the allowance by.
    function _increaseAllowance(address owner, address spender, uint256 value) internal {
        require(value > 0);
        _allowances[owner][spender] = safeAdd(_allowances[owner][spender], value);
        emit Approval(owner, spender, _allowances[owner][spender]);
    }

    /// @dev Decreases the amount of tokens that account `owner` allowed to spend by account `spender`.
    /// Method approve() should be called when _allowances[spender] == 0. To decrement allowance
    /// it is better to use this function to avoid 2 calls (and waiting until the first transaction is mined).
    /// @param owner The address which owns the tokens.
    /// @param spender The address from which the tokens can be spent.
    /// @param value The amount of tokens to decrease the allowance by.
    function _decreaseAllowance(address owner, address spender, uint256 value) internal {
        require(value > 0 && value <= _allowances[owner][spender]);
        _allowances[owner][spender] = safeSub(_allowances[owner][spender], value);
        emit Approval(owner, spender, _allowances[owner][spender]);
    }

    /// @dev Internal function that mints specified amount of tokens and assigns it to account `receiver`.
    /// This encapsulates the modification of balances such that the proper events are emitted.
    /// @param receiver The address that will receive the minted tokens.
    /// @param value The amount of tokens that will be minted.
    function _mint(address receiver, uint256 value) internal {
        require(receiver != address(0));
        require(value > 0);
        _balances[receiver] = safeAdd(_balances[receiver], value);
        _totalSupply = safeAdd(_totalSupply, value);
        emit Transfer(address(0), receiver, value);
    }

    /// @dev Internal function that burns specified amount of tokens of a given address.
    /// @param burner The address from which tokens will be burnt.
    /// @param value The amount of tokens that will be burnt.
    function _burn(address burner, uint256 value) internal {
        require(burner != address(0));
        require(value > 0 && value <= _balances[burner]);
        _balances[burner] = safeSub(_balances[burner], value);
        _totalSupply = safeSub(_totalSupply, value);
        emit Transfer(burner, address(0), value);
    }

    // FIELDS

    uint256 internal _totalSupply;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;

    // Amount of initially supplied tokens is constant and equals to 1,000,000,000
    uint256 private constant INITIAL_SUPPLY = 10**27;
}

contract RoboDexToken is ERC20Token {
    using LibBytes for bytes;

    // STRUCTURES

    enum TradeType {
        SHORT, // SELL
        LONG   // BUY
    }

    enum PositionState {
        NEW,
        OPENED,
        FILLING,
        FILLED,
        CLOSED
    }

    struct Position {
        address token;
        address maker;
        address taker;
        TradeType tradeType;
        uint256 amount;
        uint256 margin;
        uint256 openPrice;
        uint256 closePrice;
        uint256 filled;
        uint256 timestamp;
        PositionState state;
    }

    // EVENTS

    /// @dev Emits when position is opened.
    event PositionOpened(
        bytes32 id,
        address token,
        address indexed maker,
        address indexed taker,
        TradeType indexed tradeType,
        uint256 amount,
        uint256 margin,
        uint256 openPrice,
        uint256 closePrice
    );

    /// @dev Emits when position is opened.
    event PositionFilled(
        bytes32 id,
        address token,
        address indexed maker,
        address indexed taker,
        TradeType indexed tradeType,
        uint256 amount,
        uint256 margin,
        uint256 filled
    );

    /// @dev Emits when position is closed.
    event PositionClosed(
        bytes32 id,
        address token,
        address indexed maker,
        address indexed taker,
        TradeType indexed tradeType,
        uint256 amount,
        uint256 margin,
        uint256 filled,
        int256 pnl
    );
    
    // EXTERNAL FUNCTIONS

    constructor() public {
        _timeToLive = block.timestamp + INITIAL_LIFETIME;
    }

    function peddle(
        address from,
        address to,
        uint256 amount,
        bytes positionData,
        bytes dexData
    ) external returns (bool) {
        Position memory p = parsePositionData(positionData);
        if (from == p.maker) {
            p.taker = to;
        } else if (to == p.maker) {
            p.maker = from;
            p.taker = to;
        } else {
            revert("INVALID_CALL_FROM_ASSET_PROXY");
        }
        bytes32 pId = calculatePositionHash(p);
        if (_positions[pId].state != PositionState.NEW) {
            p = _positions[pId];
        }
        uint256 filled = safeAdd(p.filled, amount);
        require(
            filled <= p.amount,
            "INVALID_ASSET_AMOUNT"
        );
        bool isCreated = (filled == amount);
        bool isFullFilled = (filled == p.amount);
        // TODO: More checks
        if (isCreated) {
            transferToken(p.token, p.maker, address(this), p.margin);
            openPosition(pId, p);
        } else if (isFullFilled) {
            closePosition(pId, p, dexData);
        } else {
            fillPosition(pId, p, filled);
        }
    }

    function getPositionCount(address maker) external view returns (uint64) {
        return _positionHashCounts[maker];
    }

    function getPositionHash(address maker, uint64 index) external view returns (bytes32) {
        return _positionHashes[maker][index];
    }

    function getPosition(bytes32 positionHash) external view returns (
        address token,
        address maker,
        address taker,
        TradeType tradeType,
        uint256 amount,
        uint256 margin,
        uint256 openPrice,
        uint256 closePrice,
        uint256 filled,
        uint256 timestamp,
        PositionState state
    ) {
        Position memory p = _positions[positionHash];
        token = p.token;
        maker = p.maker;
        taker = p.taker;
        tradeType = p.tradeType;
        amount = p.amount;
        margin = p.margin;
        openPrice = p.openPrice;
        closePrice = p.closePrice;
        filled = p.filled;
        timestamp = p.timestamp;
        state = p.state;
    }
    
    function openPosition(bytes32 pId, Position memory p) internal {
        require(
            isPositionNew(p) && _positions[pId].timestamp == 0,
            "POSITION_ALREADY_OPENED"
        );
        require(
            p.token != address(0),
            "INVALID_ERC20_TOKEN_ADDRESS"
        );
        require(
            p.maker != address(0) && p.taker != address(0) && p.maker != p.taker,
            "INVALID_TRADER_ADDRESSES"
        );
        require(
            p.tradeType == TradeType.SHORT || p.tradeType == TradeType.LONG,
            "INVALID_TRADE_TYPE"
        );
        // TODO: Add more checks (amount, margin, openPrice, closePrice, timestamp)
        _positions[pId] = p;
        _positions[pId].timestamp = now;
        _positionHashes[p.maker][_positionHashCounts[p.maker]++] = pId;
        emit PositionOpened(pId, p.token, p.maker, p.taker, p.tradeType, p.amount, p.margin, p.openPrice, p.closePrice);
    }
    
    function fillPosition(bytes32 pId, Position memory p, uint256 filled) internal {
        require(
            isPositionFilling(p),
            "POSITION_ALREADY_OPENED"
        );
        require(
            p.token != address(0),
            "INVALID_ERC20_TOKEN_ADDRESS"
        );
        require(
            p.maker != address(0) && p.taker != address(0) && p.maker != p.taker,
            "INVALID_TRADER_ADDRESSES"
        );
        require(
            p.tradeType == TradeType.SHORT || p.tradeType == TradeType.LONG,
            "INVALID_TRADE_TYPE"
        );
        // TODO: Add more checks (amount, margin)
        _positions[pId] = p;
        _positions[pId].filled = filled;
        _positions[pId].state = PositionState.FILLING;
        emit PositionFilled(pId, p.token, p.maker, p.taker, p.tradeType, p.amount, p.margin, p.filled);
    }

    function closePosition(bytes32 pId, Position memory p, bytes data) internal {
        require(
            !isPositionClosed(p),
            "POSITION_ALREADY_CLOSED"
        );
        // TODO: Add more checks (margin, data)
        int256 pnl = calculatePNL(data);
        // TODO: Liquidate trades in the position
        //transferTokenSigned(p.token, p.maker, p.taker, pnl);
        _positions[pId].state = PositionState.CLOSED;
        emit PositionClosed(pId, p.token, p.maker, p.taker, p.tradeType, p.amount, p.margin, p.filled, pnl);
    }

    function transferToken(address token, address from, address to, uint256 amount) internal {
        assembly {
            let ptr := mload(0x40)
            // Setup `ERC20Token.transferFrom` input data
            // bytes4(keccak256("transferFrom(address,address,uint256)")) = 0x23b872dd
            mstore(ptr, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), from)
            mstore(add(ptr, 0x24), to)
            mstore(add(ptr, 0x44), amount)
            // Call `ERC20Token.transferFrom` using the calldata
            let success := call(
                gas,    // forward all gas
                token,  // call address of token contract
                0,      // don't send any ETH
                ptr,    // pointer to start of input
                0x64,   // length of input
                ptr,    // write output over input
                0x20    // output size should be 32 bytes
            )
            // Check return data
            // If there is no return data, we assume the token incorrectly
            // does not return a bool. In this case we expect it to revert
            // on failure, which was handled above.
            // If the token does return data, we require that it is a single
            // nonzero 32 bytes value.
            // So the transfer succeeded if the call succeeded and either
            // returned nothing, or returned a non-zero 32 byte value. 
            success := and(success, or(
                iszero(returndatasize),
                and(
                    eq(returndatasize, 0x20),
                    gt(mload(ptr), 0)
                )
            ))
            // Set storage pointer to new space
            mstore(0x40, add(ptr, 0x64))
            // Revert with `Error("TRANSFER_FAILED")` in case of error
            if not(success) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x20, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(0x40, 0x0000000f5452414e534645525f4641494c454400000000000000000000000000)
                mstore(0x60, 0x00)
                revert(0x00, 0x64)
            }
        }
    }

    function transferTokenSigned(address token, address from, address to, int256 amount) internal {
        if (amount > 0) {
            transferToken(token, from, to, uint256(amount));
        } else if (amount < 0) {
            transferToken(token, to, from, uint256(-amount));
        }
    }

    function parsePositionData(bytes data) internal pure returns (Position) {
        require(
            data.length == 224,
            "INVALID_POSITION_DATA_LENGTH"
        );
        address token = data.readAddress(12);
        address maker = data.readAddress(44);
        TradeType tradeType = (data[95] > 0 ? TradeType.LONG : TradeType.SHORT);
        uint256 amount = data.readUint256(96);
        uint256 margin = data.readUint256(128);
        uint256 openPrice = data.readUint256(160);
        uint256 closePrice = data.readUint256(192);
        require(
            token != address(0) && maker != address(0),
            "INVALID_POSITION_DATA_ADDRESSES"
        );
        require(
            amount > 0 && margin > 0 && openPrice > 0 && closePrice > 0,
            "INVALID_POSITION_DATA_VALUES"
        );
        return Position(
            token, maker, address(0), tradeType, amount, margin,
            openPrice, closePrice, 0, 0, PositionState.NEW
        );
    }

    function calculatePositionHash(Position memory p) internal pure returns (bytes32) {
        bytes memory data = abi.encodePacked(
            p.token,
            p.maker,
            p.taker,
            p.tradeType,
            p.amount,
            p.margin,
            p.openPrice,
            p.closePrice
        );
        return keccak256(data);
    }

    function calculatePNL(bytes data) internal pure returns (int256) {
        // TODO: Calculate PNL carefully
        return data.length < 32 ? int256(0) : int256(data.readBytes32(0));
    }

    function isPositionNew(Position memory p) internal pure returns (bool) {
        return p.state == PositionState.NEW;
    }

    function isPositionOpened(Position memory p) internal pure returns (bool) {
        return p.state == PositionState.OPENED;
    }

    function isPositionFilling(Position memory p) internal pure returns (bool) {
        return p.state == PositionState.FILLING;
    }

    function isPositionFilled(Position memory p) internal pure returns (bool) {
        return p.state == PositionState.FILLED;
    }

    function isPositionClosed(Position memory p) internal pure returns (bool) {
        return p.state == PositionState.CLOSED;
    }

    // FIELDS

    // Storage of open positions
    mapping (bytes32 => Position) internal _positions;

    // Storage of all known position IDs by account
    mapping (address => mapping (uint64 => bytes32)) internal _positionHashes;
    mapping (address => uint64) internal _positionHashCounts;

    // TTL which is not used yet
    uint256 internal _timeToLive;

    uint256 private constant INITIAL_LIFETIME = 21 days;
}

contract RDXToken is RoboDexToken {
    // solhint-disable const-name-snakecase
    uint8 constant public decimals = 18;
    string constant public name = "0x Protocol Token";
    string constant public symbol = "RDX";
    // solhint-enable const-name-snakecase
}
