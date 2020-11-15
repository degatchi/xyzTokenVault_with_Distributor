pragma solidity 0.6.6;

import "./XYZToken";
import "./SafeMath";
import "./ownerOnly";

// @notice Implements a basic ERC20 staking token with incentive distribution.
contract StakingToken is XYZToken, ownerOnly {
   using SafeMath for uint256;

   // @notice mapping(address => bool) public isStaking; inherited from XYZToken.

   /**
    * @notice The constructor for the Staking Token.
    * @param _owner The address to receive all tokens on construction.
    * @param _supply The amount of tokens to mint on construction.
    */
   constructor(address _owner, uint256 _supply) public {
       _mint(_owner, _supply);
   }
