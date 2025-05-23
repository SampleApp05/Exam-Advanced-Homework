// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IPayrollContract {
    function departmentName() external view returns (string memory);
    function version() external view returns (string memory);
}
