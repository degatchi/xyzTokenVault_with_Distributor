pragma solidity 0.6.6;

// All external smart contracts in use
import "./SafeMath.sol";
import "./ownerOnly.sol";
import "./Vault.sol";
import "./FreezeFunction.sol";

contract XYZToken is ownerOnly, FreezeFunction, Vault {
    // Using SafeMath to prevent underflow and overflow 
    using SafeMath for uint;

    // Variables
    string  name = "XYZ Token";
    string  symbol = "XYZ";
    uint256 public totalSupply = 10000000000000000000000; // 10k tokens
    uint8 decimals = 18;
    
    // balanceOf displays balanceOf XYZ Token for an address
    mapping(address => uint256) public balanceOf;
    // how mcuh an address is allowed to spend 
    mapping(address => mapping(address => uint256)) internal allowance;
    // [Staking] * work in progress
    // mapping(address => uint256) public stakeBalance;

    // Broadcasted Events
    event returnTokens(address indexed _address, uint _amount);
    event TokensMinted(uint indexed _mintedTokens);
    event TokensBurned(uint indexed _burnedSupply);
    event Deposit(address indexed dst, uint val);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Swap(address indexed _user, string inputCurrency, uint input, string outputCurrency, uint output);
    
    // Marks that the deployer (msg.sender) controls the supply
    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }

    // Transfer tokens to address
    function transfer(address _to, uint256 _value) public freezeFunction returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve tokens (allow someone to spend tokens)
    function approve(address _spender, uint256 _value) public freezeFunction returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    // Transfer from (allow transfer instead of us)
    function transferFrom(address _from, address _to, uint256 _value) public freezeFunction returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

// ---------------------------------[Mint + Burn]--------------------------------------

    // Removes x amount from totalSupply
    function burnTokens(uint tokens) external onlyOwner freezeFunction returns (bool success) {
        require(msg.sender == owner, "Not owner");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(tokens);
        totalSupply = totalSupply.sub(tokens);

        emit Transfer(msg.sender, address(0), tokens);
        emit TokensBurned(tokens);
        return true;
    }

    // Creates more totalSupply of the token
    function mintTokens( uint tokens) external onlyOwner freezeFunction returns (bool success) {
        require(msg.sender == owner, "Not owner");

        balanceOf[msg.sender] = balanceOf[msg.sender].add(tokens);
        totalSupply = totalSupply.add(tokens);

        emit Transfer(msg.sender, address(0), tokens);
        emit TokensMinted(tokens);
        return true;
    }
// --------------------------------[Swap Functions]------------------------------------
    
    // User swaps 1 eth for 100 xyzToken
    function swapToXYZ(uint _ethAmount) external freezeFunction returns (bool success) {
        require(vaultBalance[msg.sender] != 0, "Insufficient eth available");
        require(vaultBalance[msg.sender] >= _ethAmount, "Insufficient funds available");
        
        vaultBalance[msg.sender] = vaultBalance[msg.sender].sub(_ethAmount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_ethAmount.mul(100));

        emit Swap(msg.sender, "ETH", _ethAmount, "XYZ", _ethAmount*100);
        return success;
    }

    // User swaps 100 xyzToken for 1 eth
    function swapToETH(uint _xyzAmount) external freezeFunction returns (bool success) {
        require(balanceOf[msg.sender] != 0, "Insufficient xyz available");
        require(balanceOf[msg.sender] >= _xyzAmount, "Insufficient funds available");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_xyzAmount);
        vaultBalance[msg.sender] = vaultBalance[msg.sender].add(_xyzAmount.div(100));

        emit Swap(msg.sender, "XYZ", _xyzAmount, "ETH", _xyzAmount/100);
        return success;
    } 
// -------------------------------------------------------------------------------------

//                             @notice work in progress staking system
//                            was originally the swapping functionality

// // ----------------------------------------[Staking]------------------------------------------------
// //                               *[Need to add staking rewards]*

//     // Stakes tokens from vault deposit
//     // Sets isStaking to: true
//     // Removes amount from vaultBalance to stakeBalance
//     // calls receiveXYZ function
//     function stake(uint _stakeAmount) external freezeFunction returns (bool success) {
//         require(_stakeAmount != 0, "Cannot stake 0 eth");
//         require(vaultBalance[msg.sender] != 0, "You have no eth deposited to stake");
//         require(isStaking[msg.sender] != true, "You are already staking");
        
//         isStaking[msg.sender] = true;
//         vaultBalance[msg.sender] -= _stakeAmount;
//         balanceOf[msg.sender] += _stakeAmount;
        
//         emit Staking(msg.sender, true);
//         receiveXYZ();
//         return true;
//     }
    
//     // Issues tokens equal to the amount of eth deposited
//     function receiveXYZ() internal freezeFunction returns(bool success) {
//         require(balanceOf[msg.sender] != 0, "You have no eth staked");
//         require(hasDepositedEther[msg.sender] = true, "You have no deposited any ether");
//         require(isStaking[msg.sender] = true, "You must stake to receive XYZ Tokens");
        
//         uint stakeBal = balanceOf[msg.sender];
//         balanceOf[msg.sender] = 0;
//         stakeBalance[msg.sender] = stakeBal.mul(100);
        
//         emit Deposit(msg.sender, stakeBal);
//         emit Staking(msg.sender, true);
//         return true;
//     }

//     function unstake(uint _unstakeAmount) external freezeFunction returns (bool success) {
//         require(_unstakeAmount != 0, "Cannot unstake 0 eth");
//         require(stakeBalance[msg.sender] != 0, "You have no funds staked");
//         require(isStaking[msg.sender] == true, "You are already staking");
        
//         isStaking[msg.sender] = false;
//         stakeBalance[msg.sender] -= _unstakeAmount;
//         balanceOf[msg.sender] += _unstakeAmount;
        
//         emit Staking(msg.sender, false);
//         returnXYZ();
//         return true;
//     }
    
//     // Checks if staking: true & stakeBalance: != 0
//     // Switches staking to off, makes stakeBalance: 0, transfers previous stakeBalance to vaultBalance
//     function returnXYZ() internal freezeFunction returns(bool success) {
//         require(isStaking[msg.sender] = true, "You are not staking");
//         require(balanceOf[msg.sender] != 0, "You have no XYZ Tokens to return");
        
//         isStaking[msg.sender] = false;
//         uint stakeBal = balanceOf[msg.sender];
//         balanceOf[msg.sender] = 0;
//         vaultBalance[msg.sender] = stakeBal.div(100);
        
//         emit returnTokens(msg.sender, stakeBal);
//         emit Staking(msg.sender, false);
//         return true;
//     }

// ---------------------------------------------------------------------------------------------
}


