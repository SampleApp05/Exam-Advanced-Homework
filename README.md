# Soft-Uni-Advanced-Exam

Soft Uni Advanced Course Exam repo

# Installation

NB! For Windows use WSL
NB! Run forge install if needed after cloning

1. Install and run foundryup => curl -L https://foundry.paradigm.xyz | bash. Init a forge project => forge init
2. Install hardhat => npm install --save-dev hardhat. Init a TS project => npx hardhat init
3. Install dependencies => node update.js. Use flag -f/-h to install forge/hardhat only dependencies
4. Add values for the following keys in the .env file
   3.1 SEPOLIA_RPC_URL = https://eth-sepolia.g.alchemy.com/v2/your-key-here;
   3.2 WALLET_PRIVATE_KEY = your-wallet-here;
   3.3 ETHERSCAN_API_KEY = your-key-here;

# Tests

# Deployment

# Contract Addresses

# On Chain Implementation and Tests

func_one => etherscan link
func_two => etherscan link
....

Addresses
logic => 0xA97Fe928737e65915dD89b3067879EcF440022Ff
factory => 0x3556c11ca0470fe7D84fE4d779D42e1935c0E49b

scripts =>
forge script script/DeployPayrollContract.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIMARY_WALLET_PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
forge script script/DeployPayrollFactory.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIMARY_WALLET_PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
