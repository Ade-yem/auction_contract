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
        uint256 minimumPrice = 2;
        auction = new Auction(20, "Adeyemi & Co Auction House", bidTime);
        vm.prank(seller);
        auction.addItem("Duplex house", "Four bedroom fully detached duplex", minimumPrice, seller);
    }

    function testNameOfCompany() public view {
        assertEq(auction.name(), "Adeyemi & Co Auction House");
    }
    function test_TotalSupply() public view {
        assertEq(auction.totalSupply(), 2000);
    }


    function test_expectRegisterBidder() public {
        vm.prank(bidder1);
        uint256 amount = 0 ether;
        vm.expectRevert("You cannot send zero funds");
        auction.registerBidder{value: amount}();
    }
    function test_registerBidder() public {   
        uint256 amount = 5 ether;
        vm.prank(bidder1);
        auction.registerBidder{value: amount}();
        assertEq(auction.bidders(bidder1), 250);
    }


    function test_addItem() public {
        uint256 minPrice = 2;
        auction.addItem("Self contained house", "One bedroom self contained", minPrice, seller);
        Auction.auctionItem memory item = auction.getItem("Self contained house");
        assertEq(minPrice, item.minPrice);
        assertEq("Self contained house", item.title);
    }

    // function test_bidForItem() public {
    //     uint256 amount = 4;
    //     vm.prank(bidder1);
    //     vm.warp(block.timestamp + 2 minutes);
    //     auction.bidForItem(bidder1, amount, "Duplex house");
    //     Auction.auctionItem memory item = auction.getItem("Duplex house");
    //     assertEq(item.highestBidder, bidder1);
    // }

    // function test_bidTimeIsOver() public {
    //     vm.prank(bidder2);
    //     uint256 amount = 4;
    //     vm.warp(block.timestamp + 30 minutes);
    //     vm.expectRevert("Bid for this item is over");
    //     auction.bidForItem(bidder2, amount, "Duplex house");
    // }

    // function test_bidNotEnough() public {
    //     vm.warp(block.timestamp + 1 minutes);
    //     vm.expectRevert("Bid must be above the min price");
    //     auction.bidForItem(bidder2, 1, "Duplex house");

    //     uint256 amount = 4;
    //     auction.bidForItem(bidder2, amount, "Duplex house");
    //     Auction.auctionItem memory item = auction.getItem("Duplex house");
    //     assertEq(item.highestBid, amount);
    //     assertEq(item.highestBidder, bidder2);

    // }


    // function test_payMoney() public {
    //     uint256 amount = 5;
    //     uint256 expectedSellerPayment = amount - (amount / 10);
    //     vm.prank(bidder2);
    //     auction.bidForItem(bidder2, amount, "Duplex house");
    //     auction.payMoney("Duplex house");
    //     uint256 sellerAmount = auction.getSellerAmount(seller);
    //     assertEq(sellerAmount, expectedSellerPayment);
    // }
    
    function test_paySeller() public {
        uint256 amount = 5;
        uint256 expectedSellerPayment = amount - (amount / 10);
        vm.prank(bidder2);
        auction.bidForItem(amount, "Duplex house");
        auction.payMoney("Duplex house");
        uint256 sellerAmount = auction.getSellerAmount(seller);
        assertEq(sellerAmount, expectedSellerPayment);
        auction.paySeller(seller);
        assertEq(auction.getSellerAmount(seller), 0);
    }

}
