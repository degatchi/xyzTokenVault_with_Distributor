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
    uint256 public totalSupply = 10000000000000000000000; // 10k tokens
    uint8 decimals = 18;
    uint256 public conversionRate = 100;
    
    // balanceOf displays balanceOf XYZ Token for an address
    mapping(address => uint256) public balanceOf;
    // how mcuh an address is allowed to spend 
    mapping(address => mapping(address => uint256)) internal allowance;
    mapping(address => uint256) internal vaultBalance;

    // Broadcasted Events
    event returnTokens(address indexed _address, uint _amount);
    event TokensMinted(uint indexed _mintedTokens);
    event TokensBurned(uint indexed _burnedSupply);
    event Deposit(address indexed dst, uint val);
    event Withdrawal(address indexed src, uint _xyzAmount);
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
    // User deposits eth -> vaultBalance -> vaultBalance bal updates
    function depositETHforXYZ(uint _ethAmount) public payable freezeFunction returns(bool success) {
        require(_ethAmount > 0 ether, "Cannot be 0");
 
        // address(vaultBalance[msg.sender]).transfer(_ethAmount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_ethAmount.mul(conversionRate));

        emit Swap(msg.sender, "ETH", _ethAmount, "XYZ", _ethAmount.mul(conversionRate));
        emit Deposit(msg.sender, _ethAmount);

        return true;
    }

        // Allows user to withdraw a desired amount of eth from their vault address.
    function withdrawXYZforETH(uint _xyzAmount) public freezeFunction returns(bool success) {
        require(balanceOf[msg.sender] != 0, "No funds to withdraw");
        require(balanceOf[msg.sender] >= _xyzAmount, "Not enough funds to withdraw");
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_xyzAmount);
        msg.sender.transfer((_xyzAmount.div(conversionRate)).mul(1000000000000000000));
        
        
        emit Swap(msg.sender, "XYZ", _xyzAmount, "ETH", _xyzAmount.div(conversionRate));
        emit Withdrawal(msg.sender, _xyzAmount.div(conversionRate));
        return true;
    }
}