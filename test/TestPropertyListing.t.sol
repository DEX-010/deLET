//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test} from "lib/forge-std/src/Test.sol";
import {PropertyListing} from "../src/Property_listing.sol";

contract testProperty is Test{
    uint256 public DexFunds=200e18;
    PropertyListing public propertylisting;
    function setup(){
        vm.startBroadcast();
        propertylisting = new PropertyListing();
        vm.stopBroadcast();
        Dex=vm.makeAddr("Dex");
        vm.deal(Dex, DexFunds);
    }

    function testListng()public{
      uint256 id= 0;
      string memory Location= "14, Ola Agoro, Ijaiye";
      propertyType= Shortlet;
      address dex= Dex;
      uint256 timestamp= 1_700_000;

      propertylisting.listProperty(id, Location, propertyType, dex, timestamp);
      propertylisting.getShortLetProperties();
      vm.expectRevert();
      assert(msg.sender, Dex);
    }

   

}
