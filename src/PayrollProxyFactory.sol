// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {PayrollContract} from "./Payroll-Logic/PayrollContract.sol";

contract PayrollProxyFactory is AccessControl {
    event ProxyCreated(address indexed proxy);

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public immutable implementation;
    uint256 public proxyCount;

    mapping(uint256 id => address proxy) public proxies;

    constructor(address _implementation) {
        implementation = _implementation;
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function createProxy(
        address benefactor,
        string calldata departmentName,
        string calldata version,
        address priceFeedContract
    ) external onlyRole(ADMIN_ROLE) returns (address proxy) {
        uint256 proxyID = proxyCount++;

        proxy = Clones.clone(implementation);
        PayrollContract(proxy).initialize(
            benefactor,
            departmentName,
            version,
            priceFeedContract
        );
        proxies[proxyID] = proxy;

        emit ProxyCreated(proxy);
        return proxy;
    }
}
