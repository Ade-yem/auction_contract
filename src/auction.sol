// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./library.sol";
contract Auction {
    using stringManipulation for string;

    struct auctionItem {
        bytes32 id;
        string title;
        string description;
        uint256 highestBid;
        bool sold;
        address seller;
        address highestBidder;
        uint time;
    }
    
    uint256 public immutable NUM_ITEMS_ALLOWED;
    string public name;
    uint public numItems = 0;
    uint private bidTime;
    mapping(string => auctionItem) private auctionRecords;
    mapping(address => uint256) private amountToBePaid;
    event numberOfItemsAdded(uint256  numberOfItemsAllowed);
    event addedAuctionItem(address creator, string title);
    event ItemBought(address buyer, uint256 amount);
    event ItemBid(address bidder, uint256 amount);
    event sellerPaid(address seller, uint amount);

    constructor(uint256 _number, string memory _name, uint _bidTime) {
        NUM_ITEMS_ALLOWED = _number;
        name = _name;
        bidTime = _bidTime;
        emit numberOfItemsAdded(_number);
    }
    function addItem(string memory _title, string memory _description) public {
        require(numItems <= NUM_ITEMS_ALLOWED, "Slot is full");
        bytes32 id = _title.generateID(_description);
        auctionItem memory item = auctionItem(id, _title, _description, 0, false, msg.sender, address(0), block.timestamp);
        auctionRecords[_title] = item;
        emit addedAuctionItem(msg.sender, _title);
    }
    function payMoney(string memory _item) public payable {
        auctionItem memory item = auctionRecords[_item];
        require(msg.value == item.highestBid, "Insufficient fund baba, add more or face jail term");
        amountToBePaid[item.seller] = msg.value - msg.value/10;
        emit ItemBought(msg.sender, msg.value);
    }
    function bidForItem(uint256 amount, string memory _item) public {
        auctionItem memory item = auctionRecords[_item];
        require(item.time + bidTime > block.timestamp, "Bid for this item is over");
        if (amount > item.highestBid) {
            item.highestBid = amount;
            item.highestBidder = msg.sender;
            auctionRecords[_item] = item;
        }
    }
    function paySeller() public {
        if (amountToBePaid[msg.sender] <= 0) {
            revert("You cannot be paid");
        }
        payable(msg.sender).transfer(amountToBePaid[msg.sender]);
        emit sellerPaid(msg.sender, amountToBePaid[msg.sender]);
        amountToBePaid[msg.sender] = 0;
    }  
}
