pragma solidity 0.6.6;

import "./ownerOnly.sol";

contract FreezeFunction is ownerOnly {
	// Determines whether functions with freezeFunction modiferier pause/freeze
	bool isFrozen = false;

	// On - Off feature to free functionality
	modifier freezeFunction {
		require(isFrozen != true, "Function is frozen");
		_;
	}

	// Owner freezes the contract - DISABLING functionality
	function freezeContract() public onlyOwner {
		isFrozen = true;
	}

	// Owner unfreezes the contract - ENABLING functionality
	function unfreezeContract() public onlyOwner {
		isFrozen = false;
	}
}

