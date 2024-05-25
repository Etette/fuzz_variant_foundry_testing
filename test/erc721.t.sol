// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CypherNFT} from "../src/erc721.sol";

contract CypherNftTest is Test {
    CypherNFT nft;

    address owner = address(0x123);
    address minter = address(0x456);
    address recipient = address(0x789);
    address nonMinter = address(0xABC);

    function setUp() public {
        vm.prank(owner);
        nft = new CypherNFT("CypherNFT", "CYP");
    }

    function testConstructor() public view {
        assertEq(nft.name(), "CypherNFT" );
        assertEq(nft.symbol(), "CYP" );
        assertEq(nft.owner(), owner); 
    }

    function test_Fuzz_Mint(address to, uint256 tokenID, string memory uri) public {
        vm.prank(owner);
        nft.approveMinter_(minter, true);

        if(bytes(uri).length >  0 && to != address(0) && !nft.existToken(tokenID)) {
            vm.prank(minter);
            nft.mint(to, tokenID, uri);
            assertEq(nft._owners(tokenID), to);
            assertEq(nft.tokenURI(tokenID), uri);
        } else {
            vm.expectRevert();
            nft.mint(to, tokenID, uri);

        }


    }

    function testTransfer() public {
        vm.prank(owner);
        nft.approveMinter_(minter, true);

        vm.prank(minter);
        nft.mint(recipient, 1, "some uri");

        vm.prank(recipient);
        nft.transfer(nonMinter, 1);

        assertEq(nft.getBalance(nonMinter), 1);
        assertEq(nft.ownerOf(1), nonMinter);
    }

    function testMintExistingTokenId() public {
        vm.prank(owner);
        nft.approveMinter_(minter, true);

        vm.prank(minter);
        nft.mint(address(0x456), 1, "http://example.com");

        vm.prank(minter);
        vm.expectRevert("Token ID already exist");
        nft.mint(address(0x456), 1, "http://example.com");
    }

    function testMintWithoutURI() public {
        vm.prank(owner);
        nft.approveMinter_(minter, true);

        vm.prank(minter);
        vm.expectRevert("URI cannot be empty");
        nft.mint(address(0x456), 2, "");
    }

     function testMintingApproval() public {
        vm.prank(owner);
        nft.approveMinter_(minter, true);

        assertTrue(nft.approveMinter(minter));
    }

    function testMint() public {
        vm.prank(owner);
        nft.approveMinter_(minter, true);

        vm.prank(minter);
        nft.mint(recipient, 1, "some uri");

        assertEq(nft.getBalance(recipient), 1);
        assertEq(nft.ownerOf(1), recipient);
    }

}
