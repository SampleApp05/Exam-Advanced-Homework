import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "./tasks/index.ts";
import "./tasks/create-signature.ts";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      //evmVersion: "cancun", // seems to be required for the latest hardhat || will use Paris evm
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./src", // Contracts location
    tests: "./hardhat-tests", // Hardhat tests
    artifacts: "./artifacts",
    cache: "./cache",
  },
  defaultNetwork: "localhost",
  networks: {
    sepolia: {
      url: `${process.env.SEPOLIA_RPC_URL}`,
      // accounts: [
      //   `0x${process.env.PRIMARY_WALLET_PRIVATE_KEY}`,
      //   `0x${process.env.SECONDARY_WALLET_PRIVATE_KEY}`,
      // ].filter(Boolean),
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  },
  sourcify: {
    enabled: true,
  },
};

export default config;
