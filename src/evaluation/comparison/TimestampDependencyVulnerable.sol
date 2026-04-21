// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TimestampDependencyVulnerable
 * @dev This contract is intentionally vulnerable to timestamp dependency.
 *      DO NOT USE IN PRODUCTION.
 */
contract TimestampDependencyVulnerable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev A simple "lottery" that uses block.timestamp as a source of randomness.
     *      Miners can influence block.timestamp slightly, so this is insecure.
     */
    function playLottery() external payable {
        require(msg.value == 0.1 ether, "Send exactly 0.1 ETH to play");

        // VULNERABLE: Using block.timestamp for randomness (timestamp dependency)
        if (block.timestamp % 2 == 0) {
            // If the timestamp is even, player "wins" all the contract balance
            payable(msg.sender).transfer(address(this).balance);
        }
        // If odd, the contract keeps the funds
    }

    /**
     * @dev Owner can withdraw remaining funds.
     */
    function ownerWithdraw() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }

    // Receive ETH directly
    receive() external payable {}
}
