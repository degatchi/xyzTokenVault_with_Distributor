pragma solidity 0.6.6;

import "./SafeMath.sol";
import "./FreezeFunction.sol";
// import "./XYZToken.sol";

contract Vault is FreezeFunction{
    // Using SafeMath to prevent underflow and overflow 
    using SafeMath for uint;
    
    mapping(address => uint256) public vaultBalance;
    mapping(address => bool) public hasDepositedEther;
    mapping(address => bool) public isStaking;  
 
    event Withdrawal(address indexed src, uint _ethAmount);
    // event Staking(address src, bool locked);

    // User deposits eth -> vaultBalance -> vaultBalance bal updates
    function depositEther(uint _ethAmount) public payable freezeFunction returns(bool success) {
        require(_ethAmount > 0 ether, "Cannot be 0");
 
        vaultBalance[msg.sender] = vaultBalance[msg.sender].add(_ethAmount);

        hasDepositedEther[msg.sender] = true;
        isStaking[msg.sender] = false;
        return true;
    }
    
        // Allows user to withdraw a desired amount of eth from their vault address.
    function withdrawEther(uint _ethAmount) public freezeFunction returns(bool success) {
        require(vaultBalance[msg.sender] != 0, "No funds to withdraw");
        require(isStaking[msg.sender] != true, "Cannot withdraw eth while staking");
        require(vaultBalance[msg.sender] >= _ethAmount, "Not enough funds to withdraw");
        
        vaultBalance[msg.sender] = vaultBalance[msg.sender].sub(_ethAmount);
        msg.sender.transfer(_ethAmount * 1000000000000000000);
        
        emit Withdrawal(msg.sender, _ethAmount);
        return true;
    }
}