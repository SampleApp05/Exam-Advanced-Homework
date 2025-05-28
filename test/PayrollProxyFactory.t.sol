// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {PayrollProxyFactory} from "../src/PayrollProxyFactory.sol";
import {PayrollContract} from "../src/Payroll-Logic/PayrollContract.sol";

contract PayrollProxyFactoryTest is Test {
    event ProxyCreated(address indexed proxy);
    event PayrollInitialized(
        address indexed benefactor,
        string departmentName,
        string version
    );

    PayrollProxyFactory public factory;

    PayrollContract public payrollImplementation;
    address public benefactor = address(0x123);
    string public departmentName = "Engineering";
    string public version = "1.0.0";
    address public priceFeedContract = address(0x456);

    function setUp() public {
        payrollImplementation = new PayrollContract();
        factory = new PayrollProxyFactory(address(payrollImplementation));
    }

    function testDeployment() public view {
        assertNotEq(address(factory), address(0), "Factory should be deployed");
        assertEq(
            factory.implementation(),
            address(payrollImplementation),
            "Implementation should be set correctly"
        );

        assertTrue(
            factory.hasRole(factory.ADMIN_ROLE(), address(this)),
            "Factory should have admin role for deployer"
        );
    }

    function testCreateProxy() public {
        vm.expectEmit(true, true, true, true);
        emit PayrollInitialized(benefactor, departmentName, version);

        vm.expectEmit(false, false, false, true);
        emit ProxyCreated(address(0));

        address proxy = factory.createProxy(
            benefactor,
            departmentName,
            version,
            priceFeedContract
        );

        assertNotEq(proxy, address(0), "Proxy should not be zero address");
        assertEq(factory.proxies(0), proxy, "Proxy should be stored correctly");

        PayrollContract payrollProxy = PayrollContract(proxy);
        assertEq(
            payrollProxy.benefactor(),
            benefactor,
            "Benefactor should be set correctly"
        );
        assertEq(
            payrollProxy.departmentName(),
            departmentName,
            "Department name should be set correctly"
        );

        assertEq(
            payrollProxy.version(),
            version,
            "Version should be set correctly"
        );

        assertEq(
            address(payrollProxy.priceFeedContract()),
            priceFeedContract,
            "Price feed contract should be set correctly"
        );
    }
}
