//SPDX-Licence-identifier: MIT
pragma solidity ^0.8.19;

import {PropertyListing} from "Property_listing.sol";

contract ShortLetLogic{
    PropertyListing public propertylisting = new PropertyListing;
    //Get available shortlets
    //Virtual interaction/property acquiring
    //The logic is to allow users input amenities required
    //Whatever amenities match the users current need is mapped by the ID
    //This Id can be used to further map the actual struct of the given in the shortlet array and users can make a choice

    function getavailableShortlets(uint256 id)public returns(propertylisting.ListedProperty memory){
        propertylisting.getShortletProperties().id;
        propertylisting.getAmenities(id);

    }

    function SecureAccomodation(yint256 _id)public payable{
        propertylisting.PropertyById[_id]= getavailableshortlets();

    }
}