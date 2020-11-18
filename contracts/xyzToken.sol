pragma solidity 0.6.6;

// All external smart contracts in use
import "./SafeMath.sol";
import "./Permissions.sol";

contract xyzToken is Permissions {
    // Using SafeMath to prevent underflow and overflow 
    using SafeMath for uint;

    // Variables
    string  name = "XYZ Token";
    string  symbol = "XYZ";
    uint256 public totalSupply; // dynamic supply
    uint8 decimals = 18;
    uint256 public conversionRate = 100;
    
    // balanceOf displays balanceOf XYZ Token for an address
    mapping(address => uint256) public  balanceOf;
    mapping(address => uint256) internal vaultBalance;
    // Mapping owner address to those who are allowed to use the contract 
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => mapping (address => bool)) hasAccess;

    // Broadcasted Events
    event returnTokens(address indexed _address, uint _amount);
    event TokensMinted(uint indexed _mintedTokens);
    event TokensBurned(uint indexed _burnedSupply);
    event Deposit(address indexed dst, uint val);
    event Withdrawal(address indexed src, uint _xyzAmount);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event deductionOfFundsAllowed(address indexed _address, uint removed);
    event allowanceChange(address indexed _owner, address indexed _spender, uint256 _value);
    event Swap(address indexed _user, string inputCurrency, uint input, string outputCurrency, uint output);
    
    // Marks that the deployer (msg.sender) controls the supply
    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }
    
// ----------------------------------------[Allowance]---------------------------------------------

    // Check if address is allowed to spend on the owner's behalf 
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) { 
        return allowed[_owner][_spender]; 
    } 

    // function approve 
    function approve(address _spender, uint256 _amount) public freezeFunction returns (bool success) {
        require(balanceOf[msg.sender] != 0, "No funds available to use");
        require(_amount <= balanceOf[msg.sender], "No funds available to use");
        hasAccess[_spender][msg.sender] = true;
        // If the adress is allowed to spend from this contract
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_amount); 
        emit Approval(msg.sender, _spender, _amount); 
        return true; 
    } 
    
// ---------------------------------------[Transfer]-----------------------------------------------
    
    function transfer(address _to, uint256 _amount) public freezeFunction returns (bool success) {
        require(_amount <= balanceOf[msg.sender], "insufficient funds");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);  
        return true;
    }
    
    // allows contracts to send tokens on your behalf, 
    // for example to "deposit" to a contract address and/or to charge fees in sub-currencies
    function transferFrom(address _from, address _to, uint256 _amount) public freezeFunction returns (bool success) {
        require(_amount <= allowed[msg.sender][_from], "insufficient amount allowed to transfer from allower");
        require(_amount <= balanceOf[msg.sender], "insufficient funds available for trasnfer");
        
        allowed[msg.sender][_from] = allowed[msg.sender][_from].sub(_amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        
        emit deductionOfFundsAllowed(_from, _amount);
        emit Transfer(_from, _to, _amount);  
        return true; 
    } 

// -------------------------------------[Mint + Burn]--------------------------------------

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
    function mintTokens(uint tokens) external onlyOwner freezeFunction returns (bool success) {
        require(msg.sender == owner, "Not owner");
        balanceOf[msg.sender] = balanceOf[msg.sender].add(tokens);
        totalSupply = totalSupply.add(tokens);
        emit Transfer(msg.sender, address(0), tokens);
        emit TokensMinted(tokens);
        return true;
    }
    
//-----------------------------[Conversion Rate Adjustment]----------------------------

    function setConversion(uint _conversionRate) public onlyOwner freezeFunction returns (bool success) {
        conversionRate = _conversionRate;
        return true;
    }

// -------------------------------[Deposit & Withdraw]----------------------------------
    function depositETHforXYZ() public payable freezeFunction returns(bool success) {
        require(msg.value > 0 wei, "Cannot be 0");
        require(msg.sender.balance > 0 wei, "Not enough funds");
        totalSupply = totalSupply.add((msg.value.mul(conversionRate)).div(1000000000000000000));
        balanceOf[msg.sender] = balanceOf[msg.sender].add((msg.value.mul(conversionRate)).div(1000000000000000000));
        emit Swap(msg.sender, "ETH", msg.value, "XYZ", msg.value.mul(conversionRate));
        emit TokensMinted(msg.value.mul(conversionRate));
        emit Deposit(msg.sender, msg.value);
        return true;
    }

    function withdrawXYZforETH(uint _xyzAmount) public freezeFunction returns(bool success) {
        require(balanceOf[msg.sender] != 0, "No funds to withdraw");
        require(balanceOf[msg.sender] >= _xyzAmount, "Not enough funds to withdraw");
        totalSupply = totalSupply.sub(_xyzAmount);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_xyzAmount);
        _xyzAmount = _xyzAmount.mul(1000000000000000000);
        msg.sender.transfer(_xyzAmount.div(conversionRate));
        emit Swap(msg.sender, "XYZ", _xyzAmount, "ETH", _xyzAmount.div(conversionRate));
        emit TokensBurned(_xyzAmount);
        emit Withdrawal(msg.sender, (_xyzAmount.div(conversionRate)));
        return true;
    }
}
