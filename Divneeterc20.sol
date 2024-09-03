// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable(msg.sender) {
    struct Item {
        uint itemId;
        string itemName;
        uint itemPrice;
    }

    mapping(uint => Item) public items;
    uint public itemCount;

    // Mapping to track redeemed items for each user
    mapping(address => mapping(uint => bool)) public redeemedItems;

    // Event to log item redemption
    event ItemRedeemed(address indexed user, uint indexed itemId, string itemName, uint itemPrice);

    constructor() ERC20("Degen", "DGN") {
        _mint(msg.sender, 0); // Initial supply of 0 tokens
    }

    function mint(address to, uint amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint amount) external {
        require(amount > 0, "Amount should not be zero");
        _burn(msg.sender, amount);
    }

    function addItem(string memory itemName, uint itemPrice) external onlyOwner {
        itemCount++;
        items[itemCount] = Item(itemCount, itemName, itemPrice);
    }

    function getItems() external view returns (Item[] memory) {
        Item[] memory allItems = new Item[](itemCount);
        for (uint i = 1; i <= itemCount; i++) {
            allItems[i - 1] = items[i];
        }
        return allItems;
    }

    function redeem(uint itemId) external {
    require(itemId > 0 && itemId <= itemCount, "Invalid item ID");
    Item memory redeemedItem = items[itemId];

    require(balanceOf(msg.sender) >= redeemedItem.itemPrice, "Insufficient Balance to redeem");
    require(!redeemedItems[msg.sender][itemId], "Item already redeemed");

    // Transfer the item price to the owner
    _transfer(msg.sender, owner(), redeemedItem.itemPrice);
    redeemedItems[msg.sender][itemId] = true;

    emit ItemRedeemed(msg.sender, itemId, redeemedItem.itemName, redeemedItem.itemPrice);
}
}
