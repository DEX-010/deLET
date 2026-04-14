// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PropertyListing {
    
    enum PropertyType {
        Shortlet,
        Lease,
        Hostel,
    }

    struct ListedProperty {
        uint256 id;
        string location;
        PropertyType propertyType;
        address payable letterAddress;
        uint256 listingTimestamp;
    }

    ListedProperty[] public allProperties;
    ListedProperty[] public shortletProperties;
    ListedProperty[] public leaseProperties;
    ListedProperty[] public hostelProperties;

    uint256 public propertyCounter;

    // Mapping for property details by ID
    mapping(uint256 => ListedProperty) public propertyById;

    function listProperty(
        string memory _location,
        PropertyType _propertyType
    ) external returns (uint256) {
        
        uint256 newId = propertyCounter++;

        ListedProperty memory newProperty = ListedProperty({
            id: newId,
            location: _location,
            propertyType: _propertyType,
            letterAddress: payable(msg.sender),
            listingTimestamp: block.timestamp,
        });

        allProperties.push(newProperty);
        propertyById[newId] = newProperty;

        // Add to category-specific arrays
        if (_propertyType == PropertyType.Shortlet) {
            shortletProperties.push(newProperty);
        } else if (_propertyType == PropertyType.Lease) {
            leaseProperties.push(newProperty);
        } else if (_propertyType == PropertyType.Hostel) {
            hostelProperties.push(newProperty);
        }

        emit PropertyListed(newId, msg.sender, _propertyType, _location);

        return newId;
    }

    struct Amenity {
        string name;
        string description;
        uint256 addedAt;
    }

    mapping(uint256 => Amenity[]) public shortletAmenities;   // propertyId => list of amenities

    event PropertyListed(
        uint256 indexed propertyId,
        address indexed letterAddress,
        PropertyType propertyType,
        string location
    );

    event AmenitiesAdded(
        uint256 indexed propertyId,
        address indexed addedBy,
        string[] amenityNames,
        uint256 timestamp
    );

    struct LeaseDetails {
        uint256 yearsOfLease;      
        uint256 amountPerYear;     
        uint256 startDate;         
        bool isActive;
    }

    mapping(uint256 => LeaseDetails) public leaseInfo;

    struct HostelRoom {
        uint256 maxOccupants;           
        uint256 currentOccupants;
        string roomNumber;              
        address[] checkedInUsers;       
    }

    mapping(uint256 => HostelRoom[]) public hostelRooms;   // propertyId => list of rooms

    event UserCheckedIn(
        uint256 indexed propertyId,
        uint256 roomIndex,
        address user,
        uint256 timestamp
    );

    event UserCheckedOut(
        uint256 indexed propertyId,
        uint256 roomIndex,
        address user,
        uint256 timestamp
    );
    function getAllProperties() external view returns (ListedProperty[] memory) {
        return allProperties;
    }

    function getShortletProperties() external view returns (ListedProperty[] memory) {
        return shortletProperties;
    }

    function getLeaseProperties() external view returns (ListedProperty[] memory) {
        return leaseProperties;
    }

    function getHostelProperties() external view returns (ListedProperty[] memory) {
        return hostelProperties;
    }

    function getProperty(uint256 _id) external view returns (ListedProperty memory) {
        return propertyById[_id];
    }

    function addAmenities(
        uint256 _propertyId,
        string[] calldata _names,
        string[] calldata _descriptions
    ) external {
        require(_names.length == _descriptions.length, "Arrays length mismatch");
        require(propertyById[_propertyId].letterAddress != address(0), "Property does not exist");
        require(propertyById[_propertyId].letterAddress == msg.sender, "Only letter can add amenities");
        require(propertyById[_propertyId].propertyType == PropertyType.Shortlet, "Not a Shortlet property");

        string[] memory addedNames = new string[](_names.length);

        for (uint256 i = 0; i < _names.length; i++) {
            Amenity memory newAmenity = Amenity({
                name: _names[i],
                description: _descriptions[i],
                addedAt: block.timestamp
            });

            shortletAmenities[_propertyId].push(newAmenity);
            addedNames[i] = _names[i];
        }

        emit AmenitiesAdded(_propertyId, msg.sender, addedNames, block.timestamp);
    }

    function getAmenities(uint256 _propertyId) external view returns (Amenity[] memory) {
        return shortletAmenities[_propertyId];
    }

 

    function setLeaseTerms(
        uint256 _propertyId,
        uint256 _yearsOfLease,
        uint256 _amountPerYear,
        uint256 _startDate
    ) external {
        require(propertyById[_propertyId].letterAddress == msg.sender, "Only letter can set lease terms");
        require(propertyById[_propertyId].propertyType == PropertyType.Lease, "Not a Lease property");

        leaseInfo[_propertyId] = LeaseDetails({
            yearsOfLease: _yearsOfLease,
            amountPerYear: _amountPerYear,
            startDate: _startDate,
            isActive: true
        });
    }

    function getLeaseTerms(uint256 _propertyId) external view returns (LeaseDetails memory) {
        return leaseInfo[_propertyId];
    }


    function addHostelRoom(
        uint256 _propertyId,
        uint256 _maxOccupants,
        string memory _roomNumber
    ) external {
        require(propertyById[_propertyId].letterAddress == msg.sender, "Only letter can manage rooms");
        require(propertyById[_propertyId].propertyType == PropertyType.Hostel, "Not a Hostel property");

        HostelRoom memory newRoom = HostelRoom({
            maxOccupants: _maxOccupants,
            currentOccupants: 0,
            roomNumber: _roomNumber,
            checkedInUsers: new address[](0)
        });

        hostelRooms[_propertyId].push(newRoom);
    }

    function checkIn(
        uint256 _propertyId,
        uint256 _roomIndex,
        address _user
    ) external {
        require(propertyById[_propertyId].propertyType == PropertyType.Hostel, "Not a Hostel");
        HostelRoom storage room = hostelRooms[_propertyId][_roomIndex];
        
        require(room.currentOccupants < room.maxOccupants, "Room is full");
        require(room.currentOccupants < room.checkedInUsers.length + 1, "Array size error"); // safety

        room.checkedInUsers.push(_user);
        room.currentOccupants++;

        emit UserCheckedIn(_propertyId, _roomIndex, _user, block.timestamp);
    }

    function checkOut(uint256 _propertyId, uint256 _roomIndex,address _user) external {
        require(propertyById[_propertyId].letterAddress == msg.sender || msg.sender == _user, "Unauthorized");
        HostelRoom storage room = hostelRooms[_propertyId][_roomIndex];
        
        // Find and remove user
        for (uint256 i = 0; i < room.checkedInUsers.length; i++) {
            if (room.checkedInUsers[i] == _user) {
                room.checkedInUsers[i] = room.checkedInUsers[room.checkedInUsers.length - 1];
                room.checkedInUsers.pop();
                room.currentOccupants--;
                
                emit UserCheckedOut(_propertyId, _roomIndex, _user, block.timestamp);
                return;
            }
        }        
        revert("User not checked in");
    }

    function getHostelRooms(uint256 _propertyId) external view returns (HostelRoom[] memory) {
        return hostelRooms[_propertyId];
    }
}