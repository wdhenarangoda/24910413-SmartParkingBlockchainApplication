# Smart Parking Blockchain App 🚗🅿️⛓️

A blockchain-based application that registers drivers, sensors, and service points, rewards drivers with ERC-20 tokens for valid reports, and logs important parking-related events.

---

## 🔹 Tech Stack
- **Solidity** `^0.8.20`
- **ERC-20** standard token (`ParkingRewardToken`)
- **Remix IDE** 💻 for compiling and deploying
- **Ethereum Virtual Machine (EVM)** compatible
- **Events** for transaction logging
- **JavaScript (Hardhat optional)** for automated testing

---

## 🔹 Key Features
- 📋 **Driver Registry** – Secure driver onboarding with license ID validation
- 📡 **Sensor Registry** – Track IoT parking sensors by unique `bytes32` ID
- 🏷️ **Service Point Registry** – Manage parking entry/exit points
- 🎁 **Token Rewards** – Mint **PRT** tokens to drivers for submitting valid reports
- 🔒 **Access Control** – Only registered owners can submit data
- 📝 **On-Chain Logs** – Transparent and immutable event records

---

## 🔹 Functionalities
- **Register Driver** → Requires name, address, and license ID  
- **Register Sensor** → Requires unique `bytes32` ID and location  
- **Register Service Point** → Requires unique `bytes32` ID, name, and location  
- **Submit Driver Report** → Validates driver & mints reward tokens  
- **Submit Sensor Reading** → Only sensor owner can update readings  
- **Log Service Point Event** → Records service activities with notes  
- **Token Operations** → View balances, transfer, approve, and spend via ERC-20

---

## 🔹 Main Test Scenarios
1. ✅ **Register a new driver** → Verify stored data matches input  
2. ❌ **Duplicate driver registration** → Expect revert `"Driver already registered"`  
3. ❌ **Missing required fields** → Expect revert `"Name required"`, `"Address required"`, `"License required"`  
4. 📡 **Register sensor** with valid `bytes32` ID and location  
5. ❌ **Invalid or duplicate sensor** → Expect revert  
6. 📝 **Submit driver report** → Emits event + mints tokens  
7. ❌ **Report without message** → Expect revert `"Message required"`  
8. 📊 **Submit sensor reading** by owner → Emits event + updates state  
9. ❌ **Nonexistent or unauthorized sensor** → Expect revert  
10. 🏷️ **Register service point** and log valid event → Verify stored note  
11. ❌ **Nonexistent service point** → Expect revert `"Service point not found"`  
12. 🔵 **Verify token metadata** (`name`, `symbol`, `minter`)

---

## 🔹 Acknowledgement
Special thanks to the **Remix IDE** team and the wider **Ethereum developer community** for providing the tools, documentation, and guidance that made building and testing this project possible. 🙌

---
