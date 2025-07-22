-include .env

test:
    forge test

coverage:
    forge coverage

clean:
    forge clean

build: 
	forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY_SEPOLIA) --broadcast --verify --etherscan-api-key $(ETHESCAN_API_KEY) -vvv