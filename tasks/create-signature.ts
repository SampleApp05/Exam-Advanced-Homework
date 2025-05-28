import { task } from "hardhat/config";
import { IPayrollContract } from "../typechain-types";
import { writeToFile } from "../utils/writeToFile"; // will be used to write each signature to a file

task("createTSignature", "Create a typed testnet signature for payroll")
  .addParam("employee", "The address allowed to withdraw")
  .addParam("amount", "The amount to withdraw")
  .addParam("period", "The period (e.g. 202505)")
  .addParam("contract", "The deployed payroll contract address")
  .setAction(async ({ employee, amount, period, contract }, hre) => {
    const [, benefactor] = await hre.ethers.getSigners();

    const payrollContract = (await hre.ethers.getContractAt(
      "PayrollContract",
      contract
    )) as IPayrollContract;

    let name = await payrollContract.departmentName();
    let version = await payrollContract.version();

    console.log("Department Name:", name);
    console.log("Version:", version);

    const domain = {
      name: name,
      version: version,
      chainId: 11155111, // Sepolia
      verifyingContract: payrollContract.target,
    };

    const types = {
      ClaimSalary: [
        { name: "employee", type: "address" },
        { name: "amount", type: "uint256" },
        { name: "period", type: "uint256" },
      ],
    };

    const value = {
      employee,
      amount: parseInt(amount),
      period: parseInt(period),
    };

    const signature = await benefactor.signTypedData(domain, types, value);
    console.log("Signature:", signature);

    await writeToFile(
      `signature-${period}-${employee}.json`,
      {
        employee,
        amount: parseInt(amount),
        period: parseInt(period),
        signature,
      },
      "signatures"
    );
  });
