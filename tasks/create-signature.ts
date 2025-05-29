import { task } from "hardhat/config";
import { IPayrollContract } from "../typechain-types";
import { writeToFile } from "../utils/writeToFile";
import { Signature } from "ethers";

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

    const name = await payrollContract.departmentName();
    const version = await payrollContract.version();

    const domain = {
      name,
      version,
      chainId: 31337, // hardhat //11155111 => Sepolia
      verifyingContract: contract,
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
      amount: hre.ethers.parseEther(amount),
      period: parseInt(period),
    };

    let signature = await benefactor.signTypedData(domain, types, value);

    const r = signature.slice(0, 66); // 0x + 64 chars
    const s = "0x" + signature.slice(66, 130); // next 64 chars
    const v = parseInt(signature.slice(130, 132), 16); // last 2 chars to int

    // Fix v if it's 0 or 1
    const adjustedV = v < 27 ? v + 27 : v;

    console.log("r:", r);
    console.log("s:", s);
    console.log("v:", adjustedV);
    console.log("Signature:", { v, r, s });

    await writeToFile(
      `signature-${period}-${employee}.json`,
      {
        employee,
        amount: hre.ethers.parseEther(amount).toString(),
        period: parseInt(period),
        signature: signature,
        v: adjustedV,
        r,
        s,
      },
      "signatures"
    );
  });
