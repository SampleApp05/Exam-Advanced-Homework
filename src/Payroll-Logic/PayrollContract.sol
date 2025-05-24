// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IPayrollContract} from "./IPayrollContract.sol";

contract PayrollContract is EIP712Upgradeable, IPayrollContract {
    event PayrollCreated(
        address indexed benefactor,
        string departmentName,
        string version
    );

    event SalaryClaimed(address indexed employee, uint256 period);

    error InvalidAddress();
    error InvalidSalaryPeriod();
    error SalaryClaimAlreadyPaid();
    error InvalidPriceData();
    error InvalidPriceFeedDecimalFormat();
    error InsufficientFunds();
    error SalaryTransferFailed();
    error InvalidSignature();

    bytes32 public constant CLAIM_SALARY_TYPEHASH =
        keccak256(
            "ClaimSalary(address employee,uint256 amount,uint256 period)"
        );

    address public benefactor;
    string public departmentName;
    string public version;
    AggregatorV3Interface public priceFeedContract;

    mapping(bytes32 => bool) public paidSalaries; // hashing msg.sender and salary period === unique ID

    constructor() {
        _disableInitializers();
    }

    // MARK: - Private
    function _zeroAddress() private pure returns (address) {
        return address(0);
    }

    function _getPaystupID(
        address target,
        uint256 period
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(target, period));
    }

    function _getLatestPrice() private view returns (int256) {
        (
            ,
            /* uint80 roundID */ int256 price /* uint startedAt */ /* uint timeStamp */ /* uint80 answeredInRound */,
            ,
            ,

        ) = priceFeedContract.latestRoundData();
        return price;
    }

    // MARK: - Internal
    function _convertSalaryToEth(
        uint256 salaryAmount,
        uint256 ethPrice
    ) internal view returns (uint256) {
        return (salaryAmount * 10 ** priceFeedContract.decimals()) / ethPrice; // assuming salary amount is given in proper decimal format
    }

    function _verifyPaystupSignature(
        address employee,
        uint256 amount,
        uint256 period,
        bytes calldata signature
    ) internal view returns (bool) {
        bytes32 dataHash = keccak256(
            abi.encode(CLAIM_SALARY_TYPEHASH, employee, amount, period)
        );

        bytes32 digest = _hashTypedDataV4(dataHash);

        address signer = ECDSA.recover(digest, signature);
        return signer == benefactor;
    }

    function _transferSalaryTo(address target, uint256 amount) internal {
        int256 ethPrice = _getLatestPrice();
        require(ethPrice > 0, InvalidPriceData());

        uint256 amountToPay = _convertSalaryToEth(amount, uint256(ethPrice));

        require(address(this).balance >= amountToPay, InsufficientFunds());

        (bool success, ) = payable(target).call{value: amountToPay}("");
        require(success, SalaryTransferFailed());

        emit SalaryClaimed(target, amountToPay);
    }

    // MARK: - Public
    function hasClaimedSalary(
        address employee,
        uint256 period
    ) public view returns (bool) {
        require(employee != _zeroAddress(), InvalidAddress());
        require(period > 0, InvalidSalaryPeriod());

        return paidSalaries[_getPaystupID(employee, period)];
    }

    function hasClaimedSalary(uint256 period) public view returns (bool) {
        return hasClaimedSalary(msg.sender, period);
    }

    function claimSalary(
        uint256 amount,
        uint256 period,
        bytes calldata signature
    ) public {
        require(period > 0, InvalidSalaryPeriod());
        require(
            hasClaimedSalary(msg.sender, period) == false,
            SalaryClaimAlreadyPaid()
        );

        paidSalaries[_getPaystupID(msg.sender, period)] = true;

        require(
            _verifyPaystupSignature(msg.sender, amount, period, signature),
            InvalidSignature()
        );

        _transferSalaryTo(msg.sender, amount);
    }

    // MARK: - External
    function initialize(
        address _benefactor,
        string calldata _departmentName,
        string calldata _version,
        address _priceFeedContract
    ) external initializer {
        benefactor = _benefactor;
        departmentName = _departmentName;
        version = _version;
        priceFeedContract = AggregatorV3Interface(_priceFeedContract);

        __EIP712_init(departmentName, version);

        emit PayrollCreated(benefactor, departmentName, version);
    }
}
