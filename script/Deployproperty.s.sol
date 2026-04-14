// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Property_listing} from "src/Property_listing.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployScript is Script {
    function DeployPropertyListing()public returns(propertylisting,helperconfig){
    HelperConfig helperconfig =new HelperConfig();
    address pricefeed=helperconfig.getNetworkConfigByChainId(block.chainid).pricefeed;
    vm.startBroadcast();
    PropertyListing propertylisting = new PropertyListing(pricefeed);
    vm.stopBroadcast();
    }

    function run() public returns(propertylisting, helperconfig){
        return DeployPropertyListing();
    }
}
