// Student Name: Waruna Deshan Henarangoda
// Student ID: 24910413
// Student Email: w.henarangoda.10@student.scu.edu.au
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Define ERC-20 reward token entity details
contract ParkingRewardToken {
    string public name;
    string public symbol;
    uint8 public immutable decimals = 18;
    uint256 public totalSupply;
    address public immutable minter;

    mapping(address => uint256) public balanceOf; // balance per address
    mapping(address => mapping(address => uint256)) public allowance; // spender allowance per owner

    event Transfer(address indexed from, address indexed to, uint256 value); // emitted on token transfer
    event Approval(address indexed owner, address indexed spender, uint256 value); // emitted on approval

    constructor(string memory _name, string memory _symbol, address _minter) {
        name = _name;   // set the token name at deployment
        symbol = _symbol; // set the token symbol at deployment
         minter = _minter; // set SmartParking contract as the minter
    }

    function mint(address to, uint256 amount) external {
    require(msg.sender == minter, "Not minter"); // allow only the authorized minter
    totalSupply += amount;                        // increase total supply
    balanceOf[to] += amount;                      // credit recipient
    emit Transfer(address(0), to, amount);        // emit standard mint-as-transfer event
    }

    function _transfer(address from, address to, uint256 amount) internal {
    require(to != address(0), "Zero address"); // prevent sending to zero address
    uint256 bal = balanceOf[from];
    require(bal >= amount, "Balance too low"); // check balance
    unchecked { balanceOf[from] = bal - amount; } // subtract from sender
    balanceOf[to] += amount; // add to recipient
    emit Transfer(from, to, amount); // log the transfer
    }

    function transfer(address to, uint256 amount) external returns (bool) {
    _transfer(msg.sender, to, amount); // move tokens from sender to recipient
    return true; // indicate success
    }

    function approve(address spender, uint256 amount) external returns (bool) {
    allowance[msg.sender][spender] = amount; // set spender's allowance
    emit Approval(msg.sender, spender, amount); // log approval
    return true; // success
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
    uint256 allowed = allowance[from][msg.sender]; // check current allowance
    require(allowed >= amount, "Allowance too low"); // ensure enough approved
    if (allowed != type(uint256).max) { // if not unlimited
        allowance[from][msg.sender] = allowed - amount; // reduce allowance
        emit Approval(from, msg.sender, allowance[from][msg.sender]); // log change
    }
    _transfer(from, to, amount); // move tokens
    return true; // success
    }

}   
    

contract SmartParkingBlockchainApp {
    // Driver Profile
    struct Driver {
        string name; // Driver name
        string homeAddress; // Driver address
        string licenseId; // Driver license or ID
        bool exists; // Existence flag
    }

    // Sensor Device
    struct SensorDevice {
        bytes32 deviceId; // Unique device ID
        string location; // Physical location
        address owner; // Registrar address
        bool exists; // Existence flag
    }

    // Service Point
    struct ServicePoint {
        bytes32 pointId; // Unique point ID
        string name; // Point name
        string location; // Physical location
        address owner; // Registrar address
        bool exists; // Existence flag
    }


     // Mapping for registered drivers by address
    mapping(address => Driver) public drivers;

    // Mapping for registered sensor devices by device ID
    mapping(bytes32 => SensorDevice) public sensors;

    // Mapping for registered service points by point ID
    mapping(bytes32 => ServicePoint) public servicePoints;

    // Mapping how many reports each driver submits
    mapping(address => uint256) public driverReportCount;

    // Mapping how many readings each sensor submits
    mapping(bytes32 => uint256) public sensorReadingCount;

    // Mapping the last submitted value for each sensor
    mapping(bytes32 => int256) public lastSensorValue;

    // Mapping how many events each service point logs
    mapping(bytes32 => uint256) public servicePointEventCount;

    // Mapping the last event note for each service point
    mapping(bytes32 => string) public lastServicePointNote;

    // Reward token handle and fixed reward amount per driver report
    ParkingRewardToken public rewardToken;
    uint256 public constant REWARD_PER_REPORT = 10 * 10**18;

    // Emits when a driver submits a report
    event DriverReportSubmitted(address indexed driver, string message, uint256 count);

    // Emits when a sensor submits a reading
    event SensorReadingSubmitted(bytes32 indexed deviceId, int256 value, uint256 count);

    // Emits when a service point logs an event
    event ServicePointEventLogged(bytes32 indexed pointId, string note, uint256 count);

        // Register a new driver
    modifier notRegisteredDriver() { require(!drivers[msg.sender].exists, "Driver already registered"); _; }

    // Ensures only registered drivers submit reports
    modifier registeredDriver() { 
    require(drivers[msg.sender].exists, "Not a registered driver"); 
    _; 
    }

    function registerDriver(string calldata name, string calldata homeAddress, string calldata licenseId)
        external
        notRegisteredDriver
    {
        require(bytes(name).length > 0, "Name required"); // Validate
        require(bytes(licenseId).length > 0, "License required"); // Validate
        drivers[msg.sender] = Driver(name, homeAddress, licenseId, true); // Save
    }

    // Register a sensor device with a unique device ID
    modifier uniqueSensor(bytes32 deviceId) { require(!sensors[deviceId].exists, "Sensor already registered"); _; } 

    // Ensures the sensor is already registered
    modifier sensorExists(bytes32 deviceId) {
    require(sensors[deviceId].exists, "Sensor not found");
    _;
    }

    // Ensures only the owner of the sensor can submit readings
    modifier onlySensorOwner(bytes32 deviceId) {
    require(sensors[deviceId].owner == msg.sender, "Not sensor owner");
    _;
    }

    function registerSensor(bytes32 deviceId, string calldata location)
        external
        uniqueSensor(deviceId)
    {
        require(bytes(location).length > 0, "Location required"); // Validate
        sensors[deviceId] = SensorDevice(deviceId, location, msg.sender, true); // Save
    }

    // Register a service point with a unique point ID
    modifier uniqueServicePoint(bytes32 pointId) { require(!servicePoints[pointId].exists, "Service point already registered"); _; } 

    // Ensures the service point is already registered
    modifier servicePointExists(bytes32 pointId) {
    require(servicePoints[pointId].exists, "Service point not found");
    _;
    }

    function registerServicePoint(bytes32 pointId, string calldata name, string calldata location)
        external
        uniqueServicePoint(pointId)
    {
        require(bytes(name).length > 0, "Name required"); // Validate
        require(bytes(location).length > 0, "Location required"); // Validate
        servicePoints[pointId] = ServicePoint(pointId, name, location, msg.sender, true); // Save
    }

    // Allows registered drivers to submit a parking-related report
        function submitDriverReport(string calldata message)
    external
    registeredDriver // Ensures caller is a registered driver
    {
    require(bytes(message).length > 0, "Message required"); // Prevent empty reports
    uint256 newCount = ++driverReportCount[msg.sender]; // Increment and store report count
    emit DriverReportSubmitted(msg.sender, message, newCount); // Emit log for record keeping
    }

    // Allows the registered owner of a sensor to submit a reading
    function submitSensorReading(bytes32 deviceId, int256 value)
    external
    sensorExists(deviceId)       // Checks that the sensor exists
    onlySensorOwner(deviceId)    // Checks that the caller owns the sensor
    {
    lastSensorValue[deviceId] = value; // Updates the last recorded reading
    uint256 newCount = ++sensorReadingCount[deviceId]; // Increments reading count
    emit SensorReadingSubmitted(deviceId, value, newCount); // Emits event
    }

    // Allows a registered service point to log an event with a descriptive note
    function logServicePointEvent(bytes32 pointId, string calldata note)
    external
    servicePointExists(pointId) // Checks that the service point exists
    {
    require(bytes(note).length > 0, "Note required"); // Ensures note is not empty
    lastServicePointNote[pointId] = note; // Updates the last note for this service point
    uint256 newCount = ++servicePointEventCount[pointId]; // Increments event count
    emit ServicePointEventLogged(pointId, note, newCount); // Emits event for logging
    }

}

