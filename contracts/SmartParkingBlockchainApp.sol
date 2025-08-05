// Student Name: Waruna Deshan Henarangoda
// Student ID: 24910413
// Student Email: w.henarangoda.10@student.scu.edu.au
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
}

