import { task } from "hardhat/config";
import { PayrollContract } from "../typechain-types";
import { PayrollProxyFactory } from "../typechain-types";

task("deployPayrollTemplate", "Deploy Payroll template contract").setAction(
  async (_, hre) => {
    const factory = await hre.ethers.getContractFactory("PayrollContract");
    const contract = await factory.deploy();
    await contract.waitForDeployment();

    console.log("PayrollContract deployed to:", contract.target);
    return contract;
  }
);

task("deployPayrollFactory", "Deploy PayrollProxyFactory contract").setAction(
  async (_, hre) => {
    let templateContract = (await hre.run(
      "deployPayrollTemplate"
    )) as PayrollContract;

    const factory = await hre.ethers.getContractFactory("PayrollProxyFactory");
    const contract = await factory.deploy(templateContract.target);
    await contract.waitForDeployment();

    console.log("PayrollProxyFactory deployed to:", contract.target);
    return contract;
  }
);

task("deployPayrollProxy", "Deploy PayrollContract proxy")
  .addParam("department", "The name of the department")
  .addParam("v", "The version of the contract")
  .addParam("feed", "The address of the price feed contract")
  .setAction(async (taskArgs, hre) => {
    let [owner, benefactor] = await hre.ethers.getSigners();

    let factory = (await hre.run(
      "deployPayrollFactory"
    )) as PayrollProxyFactory;

    let hasRole = await factory.hasRole(
      await factory.ADMIN_ROLE(),
      owner.address
    );

    const tx = await factory.createProxy(
      benefactor.address,
      taskArgs.department,
      taskArgs.v,
      taskArgs.feed
    );

    const receipt = await tx.wait();

    const event = receipt.logs.find((log: { fragment: { name: string } }) => {
      return log.fragment?.name === "ProxyCreated"; // match the event name
    });

    if (!event) {
      console.error("ProxyCreated event not found");
      return;
    }

    const proxyAddress = event.args?.[0]; // assuming the address is the first argument
    console.log("PayrollContract proxy deployed to:", proxyAddress);
  });
//0xf0D7de80A1C242fA3C738b083C422d65c6c7ABF1
