pragma solidity 0.6.6;

import "./SafeMath.sol";
import "./FreezeFunction.sol";
// import "./XYZToken.sol";

contract Vault is FreezeFunction{
    // Using SafeMath to prevent underflow and overflow 
    using SafeMath for uint;
    
    mapping(address => uint256) public vaultBalance;
}
