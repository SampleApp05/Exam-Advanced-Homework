// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {PayrollProxyFactory} from "src/PayrollProxyFactory.sol";

contract DeployFactory is Script {
    function run() external {
        address logicAddress = vm.envAddress("LOGIC_CONTRACT_ADDRESS");
        console2.log("Logic:", logicAddress);

        vm.startBroadcast();

        PayrollProxyFactory factory = new PayrollProxyFactory(logicAddress);
        console2.log("Deployed PayrollProxyFactory at:", address(factory));

        vm.stopBroadcast();
    }
}
