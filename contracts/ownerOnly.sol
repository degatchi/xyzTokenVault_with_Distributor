pragma solidity 0.6.6;

contract ownerOnly {
    bool initialised;
    address owner = msg.sender;

    event OwnershipTransferred(address indexed from, address indexed to);

    // Used to add ownerOnly functionality
    modifier onlyOwner {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // Initialises address of owner/Assigns owner
    function initOwned(address _owner) internal {
        require(!initialised, "Already initialised");
        owner = address(uint160(_owner));
        initialised = true;
    }

    // Owner transfers ownership to new address
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner, "Already owner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}
