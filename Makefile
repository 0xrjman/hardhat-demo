.PHONY: test
test:
	npx hardhat compile
	npx hardhat test

.PHONY: deploy-rinkeby
deploy-rinkeby: test
	npx hardhat run scripts/tokenDeploy.ts --network rinkeby
