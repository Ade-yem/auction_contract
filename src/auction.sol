// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./library.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface newIERC20 is IERC20 {
    function mint(address to, uint256 amount) external;
}

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
    // one ether == 50 tokens
    uint256 private multiplier = 50; 
    uint256 totalSupply = 0;
    bytes[] public listOfAuctionItems;
    mapping(string => auctionItem) private auctionRecords;
    mapping(address => uint256) public bidders;
    mapping(address => uint256) private amountToBePaid;
    event numberOfItemsAdded(uint256  numberOfItemsAllowed);
    event addedAuctionItem(address creator, string title);
    event ItemBought(address buyer, uint256 amount);
    event ItemBid(address bidder, uint256 amount);
    event sellerPaid(address seller, uint256 amount);
    event bidderRegistered(address bidder, uint256 amount);
    event returnedBidderMoney(address bidder, uint256 amount);

    newIERC20 public token;

    constructor(uint256 _number, string memory _name, uint _bidTime) {
        NUM_ITEMS_ALLOWED = _number;
        name = _name;
        bidTime = _bidTime;
        emit numberOfItemsAdded(_number);
        token.mint(address(this), 2000);
        totalSupply += 2000;
    }

    /**
     * @dev Mint token
     */
    function mintToken() private {
        token.mint(address(this), 2000);
        totalSupply += 2000;
    }

    /**
     * @dev transfer token to bidder. If current supply is not enough,
     * it mints more
     * Requirements:
     * - `to` address of the bidder
     * - `amount` amount of tokens to be sent 
     * Emits {returnedBidderMoney} event
     */
    function transferToken(address to, uint256 amount) private {
        if (totalSupply < amount) {
            mintToken();
        }
        token.transfer(to, amount);
        totalSupply -= amount;
    }

    /**
     * @dev withdraw token from the owner and adds it to the total supply
     * it mints more
     * Requirements:
     * - `from` address of the owner
     * - `amount` amount of tokens to be withdrawn 
     */
    function withdrawToken(address from, uint256 amount) private {
        token.transferFrom(from, address(this), amount);
        totalSupply += amount;
    }

    /**
     * @dev Registers bidder
     * Emits {bidderRegistered} event
     */
    function registerBidder() payable public {
        require(msg.value > 0, "You cannot send zero funds");
        uint256 amount = (msg.value / 1 ether) * 50;
        bidders[msg.sender] = amount;
        transferToken(msg.sender, amount);
        emit bidderRegistered(msg.sender, amount);
    }

    /**
     * @dev Removes the bidders tokens and return their remaining money
     * Emits {returnedBidderMoney} event
     */
    function returnBidderMoney() public {
        require(bidders[msg.sender] > 0, "We do not have your money");
        uint256 amount = (bidders[msg.sender] / 50) * 1 ether;
        withdrawToken(msg.sender, bidders[msg.sender]);
        bidders[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit returnedBidderMoney(msg.sender, amount);
    }

    /**
     * @dev adds items to the auction
     * Emits {addedAuctionItem} event
     */
    function addItem(string memory _title, string memory _description, uint256 minPrice, address seller) public {
        require(numItems <= NUM_ITEMS_ALLOWED, "Slot is full");
        bytes32 id = _title.generateID(_description);
        auctionItem memory item = auctionItem(id, _title, _description, 0, minPrice, false, seller, address(0), block.timestamp);
        auctionRecords[_title] = item;
        listOfAuctionItems.push(bytes(_title));
        emit addedAuctionItem(msg.sender, _title);
    }

    /**
     * @dev bid for item
     * Emits {ItemBid} event
     */
    function bidForItem(address bidder, uint256 amount, string memory _item) public {
        auctionItem memory item = auctionRecords[_item];
        require(amount >= item.minPrice, "Bid must be above the min price");
        require(bidders[bidder] >= amount, "Bros !, you no get money!!!");
        require(item.time + bidTime > block.timestamp, "Bid for this item is over");
        if (amount > item.highestBid) {
            item.highestBid = amount;
            item.highestBidder = bidder;
            auctionRecords[_item] = item;
        }
        emit ItemBid(bidder, amount);
    }

    /**
     * @dev Returns auction item based on its `_title`
     */
    function getItem(string memory _title) public view returns(auctionItem memory) {
        auctionItem memory item = auctionRecords[_title];
        return (item);
    }

    /**
     * @dev Pays money for the `_item' won from the auction
     * Emits {ItemBought} event
     */
    function payMoney(string memory _item) public {
        auctionItem memory item = auctionRecords[_item];
        require(msg.sender == item.highestBidder, "You are not the highest bidder");
        withdrawToken(msg.sender, item.highestBid);
        amountToBePaid[item.seller] = item.highestBid - item.highestBid / 10;
        bidders[msg.sender] -= msg.value;
        emit ItemBought(msg.sender, item.highestBid);
    }

    /**
     * @dev Returns amount to be paid to a `seller`
     */
    function getSellerAmount(address seller) public view returns(uint256) {
        return (amountToBePaid[seller]);
    }

    /**
     * @dev Returns the winner of an auction `item`
     */
    function showWiner(string memory _item) public view returns (address) {
        auctionItem memory item = auctionRecords[_item];
        require(item.time + bidTime < block.timestamp, "Bid for this item is not over");
        return (item.highestBidder);
    }

    /**
     * @dev Pay seller his money
     * Emits {sellerPaid} event
     */
    function paySeller(address seller) public {
        if (amountToBePaid[seller] <= 0) {
            revert("You cannot be paid");
        }
        transferToken(seller, amountToBePaid[seller]);
        emit sellerPaid(seller, amountToBePaid[seller]);
        amountToBePaid[seller] = 0;
    }

    /**
     * @dev cashout
     * Emits {returnedBidderMoney} event
     */
    function cashOut(uint256 amount) public {
        uint256 amt = (amount / 50) * 1 ether;
        withdrawToken(msg.sender, amount);
        payable(msg.sender).transfer(amt);
    }
}
