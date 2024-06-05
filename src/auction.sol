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
        uint256 minPrice;
        bool sold;
        address seller;
        address highestBidder;
        uint time;
    }
    
    string public name;
    uint public immutable NUM_ITEMS_ALLOWED;
    uint public numItems = 0;
    uint private bidTime;
    mapping(string => auctionItem) private auctionRecords;
    // mapping(address => bool) private sellers;
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



    // function registerSeller() public {
    //     sellers[msg.sender] = true;
    // }
    function addItem(string memory _title, string memory _description, uint256 minPrice, address seller) public {
        require(numItems <= NUM_ITEMS_ALLOWED, "Slot is full");
        bytes32 id = _title.generateID(_description);
        auctionItem memory item = auctionItem(id, _title, _description, 0, minPrice, false, seller, address(0), block.timestamp);
        auctionRecords[_title] = item;
        emit addedAuctionItem(msg.sender, _title);
    }
    function getItem(string memory _title) public view returns(auctionItem memory) {
        auctionItem memory item = auctionRecords[_title];
        return (item);
    }
    function payMoney(string memory _item) public payable {
        auctionItem memory item = auctionRecords[_item];
        // require(msg.sender == item.highestBidder, "You are not the highest bidder");
        require(msg.value == item.highestBid, "Insufficient fund baba, add more or face jail term");
        amountToBePaid[item.seller] = msg.value - msg.value/10;
        emit ItemBought(msg.sender, msg.value);
    }
    function getSellerAmount(address seller) public view returns(uint256) {
        return (amountToBePaid[seller]);
    }
    function bidForItem(address bidder, uint256 amount, string memory _item) public {
        auctionItem memory item = auctionRecords[_item];
        require(amount >= item.minPrice, "Bid must be above the min price");
        require(item.time + bidTime > block.timestamp, "Bid for this item is over");
        if (amount > item.highestBid) {
            item.highestBid = amount;
            item.highestBidder = bidder;
            auctionRecords[_item] = item;
        }
    }
    function showWiner(string memory _item, uint time) public view returns (address) {
        auctionItem memory item = auctionRecords[_item];
        // require(item.time + bidTime < block.timestamp, "Bid for this item is not over");
        require(item.time + bidTime < time, "Bid for this item is not over");
        return (item.highestBidder);
    }
    function paySeller(address seller) public {
        if (amountToBePaid[seller] <= 0) {
            revert("You cannot be paid");
        }
        payable(seller).transfer(amountToBePaid[seller]);
        emit sellerPaid(seller, amountToBePaid[seller]);
        amountToBePaid[seller] = 0;
    }  
}
