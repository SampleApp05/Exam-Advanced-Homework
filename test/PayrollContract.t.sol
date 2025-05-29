// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {PayrollProxyFactory} from "../src/PayrollProxyFactory.sol";
import {PayrollContract} from "../src/Payroll-Logic/PayrollContract.sol";
import {MockPayrollContract} from "./MockPayrollContract.sol";
import {MockAggregatorV3Interface} from "./MockAggregatorV3Interface.sol";

contract PayrollProxyTests is Test {
    event SalaryClaimed(address indexed employee, uint256 period);

    MockPayrollContract public payrollContract;
    MockAggregatorV3Interface public mockPriceFeed;

    uint256 employeeKey =
        0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
    address public employee;
    uint256 benefactorKey =
        0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
    address public benefactor;

    string public departmentName = "Engineering";
    string public version = "1.0.0";

    function setUp() public {
        employee = vm.addr(employeeKey);
        benefactor = vm.addr(benefactorKey);

        MockPayrollContract implementation = new MockPayrollContract();
        PayrollProxyFactory factory = new PayrollProxyFactory(
            address(implementation)
        );

        mockPriceFeed = new MockAggregatorV3Interface(100000000, 8);

        address proxy = factory.createProxy(
            benefactor,
            departmentName,
            version,
            address(mockPriceFeed)
        );

        payrollContract = MockPayrollContract(payable(proxy));

        vm.deal(benefactor, 10_000 ether);
        vm.deal(proxy, 1000 ether);
    }

    function buildSignature(
        uint256 amount,
        uint256 period
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 dataHash = keccak256(
            abi.encode(
                payrollContract.CLAIM_SALARY_TYPEHASH(),
                employee,
                amount,
                period
            )
        );

        bytes32 digest = payrollContract.hashedSignatureData(dataHash);
        (v, r, s) = vm.sign(benefactorKey, digest);
    }

    function buildInvalidSignature(
        uint256 amount,
        uint256 period
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 dataHash = keccak256(
            abi.encode(
                payrollContract.CLAIM_SALARY_TYPEHASH(),
                employee,
                amount,
                period
            )
        );

        bytes32 digest = payrollContract.hashedSignatureData(dataHash);
        (v, r, s) = vm.sign(employeeKey, digest);
    }

    function testInitialSetup() public view {
        assertEq(payrollContract.benefactor(), benefactor);
        assertEq(payrollContract.departmentName(), departmentName);
        assertEq(payrollContract.version(), version);
        assertEq(
            address(payrollContract.priceFeedContract()),
            address(mockPriceFeed)
        );

        assertEq(
            address(payrollContract).balance,
            1000 ether,
            "Contract should be funded with 1000 ether"
        );
    }

    function testClaimSalary() public {
        uint256 amount = 1 ether;
        uint256 period = 202512; // December 2025

        assertFalse(
            payrollContract.hasClaimedSalary(employee, period),
            "Salary should not be claimed yet"
        );

        (uint8 v, bytes32 r, bytes32 s) = buildSignature(amount, period);

        vm.startPrank(employee);

        vm.expectEmit(true, true, false, true);
        emit SalaryClaimed(employee, period);
        payrollContract.mockClaimSalary(amount, period, v, r, s);

        vm.stopPrank();

        assertEq(
            payrollContract.hasClaimedSalary(employee, period),
            true,
            "Salary should be marked as claimed"
        );

        assertEq(employee.balance, 1 ether, "Employee should receive 1 ether");
        assertEq(
            address(payrollContract).balance,
            999 ether,
            "Payroll contract balance should decrease by 1 ether"
        );
    }

    function testAlreadyClaimedSalary() public {
        uint256 amount = 1 ether;
        uint256 period = 202512; // December 2025

        (uint8 v, bytes32 r, bytes32 s) = buildSignature(amount, period);

        vm.startPrank(employee);
        payrollContract.mockClaimSalary(amount, period, v, r, s);
        vm.stopPrank();

        vm.expectRevert(PayrollContract.SalaryClaimAlreadyPaid.selector);

        vm.startPrank(employee);
        payrollContract.mockClaimSalary(amount, period, v, r, s);
        vm.stopPrank();
    }

    function testInvalidSignature() public {
        uint256 amount = 1 ether;
        uint256 period = 202512; // December 2025

        (uint8 v, bytes32 r, bytes32 s) = buildInvalidSignature(amount, period);

        vm.expectRevert(PayrollContract.InvalidSignature.selector);

        vm.startPrank(employee);
        payrollContract.mockClaimSalary(amount, period, v, r, s);
        vm.stopPrank();
    }

    function testInvalidPriceData() public {
        uint256 amount = 1 ether;
        uint256 period = 202512; // December 2025

        (uint8 v, bytes32 r, bytes32 s) = buildSignature(amount, period);

        // Set the price feed to return an invalid price
        mockPriceFeed.setLatestPrice(0);

        vm.expectRevert(PayrollContract.InvalidPriceData.selector);

        vm.startPrank(employee);
        payrollContract.mockClaimSalary(amount, period, v, r, s);
        vm.stopPrank();
    }

    function testInsufficientFunds() public {
        uint256 amount = 100_000 ether; // More than the contract balance
        uint256 period = 202512; // December 2025

        (uint8 v, bytes32 r, bytes32 s) = buildSignature(amount, period);

        vm.expectRevert(PayrollContract.InsufficientFunds.selector);

        vm.startPrank(employee);
        payrollContract.mockClaimSalary(amount, period, v, r, s);
        vm.stopPrank();
    }
}
