// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Auction} from "../src/auction.sol";

contract AuctionTest is Test {
    Auction public auction;
    address bidder1;
    address bidder2;
    address seller;
    uint bidTime = block.timestamp + 5 minutes;

    function setUp() public {
        bidder1 = address(0x01);
        bidder2 = address(0x02);
        seller = address(0x03);
        uint256 minimumPrice = 2 * 10 ** 18;
        auction = new Auction(20, "Adeyemi & Co Auction House", bidTime);
        vm.prank(seller);
        auction.addItem("Duplex house", "Four bedroom fully detached duplex", minimumPrice, seller);
    }

    function test_addItem() public {
        uint256 minPrice = 2 * 10 ** 18;
        auction.addItem("Self contained house", "One bedroom self contained", minPrice, seller);
        Auction.auctionItem memory item = auction.getItem("Self contained house");
        assertEq(minPrice, item.minPrice);
        assertEq("Duplex house", item.title);
    }

    function test_bidForItem() public {
        // auction.addItem("Duplex house", "Four bedroom fully detached duplex", minPrice);
        uint256 amount = 4 * 10 ** 18;
        vm.prank(bidder1);
        auction.bidForItem(bidder1, 3 * 10 ** 18, "Duplex house", block.timestamp + 2 minutes);
        Auction.auctionItem memory item = auction.getItem("Duplex house");
        assertEq(item.highestBidder, bidder1);

        vm.prank(bidder2);
        auction.bidForItem(bidder2, amount, "Duplex house", block.timestamp + 5 minutes);
        vm.expectRevert("Bid for this item is over");

        auction.bidForItem(bidder2, 1 * 10 ** 18, "Duplex house", block.timestamp + 2 minutes);
        vm.expectRevert("Bid must be above the min price");

        auction.bidForItem(bidder2, amount, "Duplex house", block.timestamp + 2 minutes);
        assertEq(item.highestBid, amount);
        assertEq(item.highestBidder, bidder2);
    }

    function test_payMoney() public {
        uint256 amount = 4 * 10 ** 18;
        uint256 expectedSellerPayment = amount - (amount / 10);
        vm.prank(bidder2);
        auction.bidForItem(bidder2, amount, "Duplex house", block.timestamp + 2 minutes);
        address(vm).call(address(this), abi.encodeWithSignature("payMoney(string)", "Duplex house"));
        Auction.auctionItem memory item = auction.getItem("Duplex house");
        uint256 sellerAmount = auction.getSellerAmount(seller);
        assertEq(sellerAmount, expectedSellerPayment);
    }
    
    function test_paySeller() public {
        uint256 amount = 4 * 10 ** 18;
        uint256 expectedSellerPayment = amount - (amount / 10);
        vm.prank(bidder2);
        auction.bidForItem(bidder2, amount, "Duplex house", block.timestamp + 2 minutes);
        address(vm).call(address(this), abi.encodeWithSignature("payMoney(string)", "Duplex house"));
        Auction.auctionItem memory item = auction.getItem("Duplex house");
        uint256 sellerAmount = auction.getSellerAmount(seller);
        assertEq(sellerAmount, expectedSellerPayment);
        auction.paySeller(seller);
        assertEq(auction.getSellerAmount(seller), 0);
    }

}
