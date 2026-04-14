//SPDX-LICENSE-Identfier:MIT;
pragma solidity ^0.8.19;
import {MockV3Aggregator} from "../test/mocks/MockV3AggregatorInterface.sol";
import {Script} from "../forge-std/scripts";


error NetworkNotwithinScope();
contract HelperConfig is script{
    //Create a medium of deploying to multi chain on the contract
    uint256 public SepoliaEthId= 11155111;
    uint256 public BaseNetworkId=84532;
    uint256 public LocalChainId=31337;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig{
        address pricefeed;
    }
    mapping (chainId => NetworkConfig) public networkConfigs;

    //Here the constructor is used to reference the map to get the pricefeed address
    constructor(){
        networkconfigs[SepoliaEthId]=getSepoliaEth();
        networkconfigs[BaseNetworkId]=getBaseNetwork();
    }

    function getNetworkConfigByChainId(uint256 chainID) public returns(NetworkConfig memory){
        if (networkConfigs[chainID].pricefeed != address(0)){
            networkconfigS[chainID];
        }
        else if(chainID== LocalchainID){
           return GetAnvilSepolia();
        }
        else{
            revert NetworkNotwithinScope();
        }
    }
    function getSepoliaEth()public returns(address memory){
        NetworkConfig{
            pricefeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        };
    }
    function getBaseNetwork()public returns(address memory){
        NetworkConfig{
            pricefeed:0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1
        };
    }
    function GetAnvilSepolia(){
        if (localNetworkConfig.priceFeed != address(0)) {
            return localNetworkConfig;
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        localNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return localNetworkConfig;
    }
}


}