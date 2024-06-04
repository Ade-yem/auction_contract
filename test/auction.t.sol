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
        auction = Auction(20, "Adeyemi & Co Auction House", bidTime);
    }

    function test_addItem() public {

    }
    function test_payMoney() public {
        
    }
    function test_bidForItem() public {

    }
    function test_paySeller() public {

    }

}
