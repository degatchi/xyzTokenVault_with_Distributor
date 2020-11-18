pragma solidity 0.6.6;

import "./XYZToken.sol";
import "./SafeMath.sol";

contract tokenDistributor is xyzToken {
    using SafeMath for uint;

    address[] addresses;
    uint public totalAddresses;
    mapping(address => bool) public addressIsAdded;

    function addMyAddress() public {
        require(addressIsAdded[msg.sender] != true, "address already added");
        addressIsAdded[msg.sender] = true;
        addresses.push(msg.sender);
        totalAddresses++;
    }

    function addAddress(address _address) public onlyOwner {
        require(addressIsAdded[_address] != true, "address already added");
        addressIsAdded[_address] = true;
        addresses.push(_address);
        totalAddresses++;
    }

    function distributeTokens(uint amount) public  {
        require(amount/totalAddresses != 0, "addresses exceed input amount (minimum one per address)");
        totalSupply = totalSupply.add(amount);

        for (uint i = 0; i < addresses.length; i++) {
            address a = addresses[i];
            balanceOf[a] = balanceOf[a].add(amount.div(addresses.length));
        }
    }

}
