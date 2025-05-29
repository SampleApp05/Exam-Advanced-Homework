// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {PayrollContract} from "src/Payroll-Logic/PayrollContract.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        PayrollContract deployedContract = new PayrollContract();

        console2.log("Deployed PayrollContract at:", address(deployedContract));

        vm.stopBroadcast();
    }
}
