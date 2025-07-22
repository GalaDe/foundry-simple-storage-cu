// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.18;

// 2. Imports
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// 3. Interfaces, Libraries, Contracts
error FundMe__NotOwner();

/**
 * @title A sample Funding Contract
 * @author Galina K
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type Declarations: solidity feature that allows you to attach library functions to existing types — in this case, uint256
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18; //5 * 10 ** 18 – The value, representing 5 USD with 18 decimal places.
    address private immutable i_owner; //imutable vars shoud start with i_
    address[] private s_funders; // storage vars shoud start with s_
    mapping(address => uint256) private s_addressToAmountFunded; //mapping(...) → A key-value store in Solidity, address => uint256 → Maps a wallet address to a number (amount in wei).
    AggregatorV3Interface private s_priceFeed;

    /// @notice Emitted when a user sends ETH to fund the contract
    /// @param funder The address of the user who funded
    /// @param amount The amount of ETH (in wei) sent
    event Funded(address indexed funder, uint256 amount);

    /// @notice Emitted when the owner withdraws funds
    /// @param owner The address of the contract owner
    /// @param amount The total amount withdrawn
    event Withdrawn(address indexed owner, uint256 amount);

    // Modifiers
    //Restricts access so that only the contract owner can call certain functions.
    modifier onlyOwner() {
        //Uses a custom error (FundMe__NotOwner) to save gas compared to a traditional require(...) with a string.
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    /// @notice Funds our contract based on the ETH/USD price
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD
        );
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);

        emit Funded(msg.sender, msg.value);
    }

    /**
     * @notice Allows the contract owner to withdraw all funds
     * @dev Resets funder balances and transfers all ETH to the owner
     */
    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        uint256 contractBalance = address(this).balance;
        //sends Ether to the contract owner using the .call low-level function.
        //i_owner - the address to send ETH to — the contract owner.
        //.call{value: address(this).balance} - send all the ETH in the contract to that address.
        //(bool success, ) - destructures the result, success is true if the transfer succeeded. _ ignores the second return value (returned data).
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success); //stops everything if the transfer failed.
        emit Withdrawn(i_owner, contractBalance);
    }

    /**
     * @notice Efficiently withdraws all ETH from the contract to the owner
     * @dev Resets funder balances and transfers all ETH to the owner
     */
    function cheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory, sorry!
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        uint256 contractBalance = address(this).balance;
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
        emit Withdrawn(i_owner, contractBalance);
    }

    /**
     * Getter Functions
     */

    /**
     * @notice Gets the amount that an address has funded
     *  @param fundingAddress the address of the funder
     *  @return the amount funded
     */
    function getAddressToAmountFunded(
        address fundingAddress
    ) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    /// @notice Called when ETH is sent directly to the contract with empty calldata
    receive() external payable {
        fund();
    }

    /// @notice Called when calldata is not empty and no function matches
    fallback() external payable {
        fund();
    }
}
