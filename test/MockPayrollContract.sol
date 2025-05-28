// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {PayrollContract} from "../src/Payroll-Logic/PayrollContract.sol";

contract MockPayrollContract is PayrollContract {
    function hashedSignatureData(bytes32 data) external view returns (bytes32) {
        return _hashTypedDataV4(data);
    }

    function mockClaimSalary(
        uint256 amount,
        uint256 period,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        super.claimSalary(amount, period, v, r, s);
    }
}
