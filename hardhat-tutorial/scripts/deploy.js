const { ethers } = require("hardhat");
require("dotenv").config({path:".env"});
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");

async function main() {
  // Address of my whitelist contract, previousely deployed
  const whitelistContract = WHITELIST_CONTRACT_ADDRESS;

  // URL from where we can extract the metadata for a crypto Dev NFT
  const metadataURL = METADATA_URL;

  /**
   * A contractFactory (in ethers.js), abstraction used to deploy new smart contracts
   */
  const cryptoDevsContract = await ethers.getContractFactory("CryptoDevs");

  // Deploy :
  const deployedCryptoDevsContract = await cryptoDevsContract.deploy(
    metadataURL,
    whitelistContract
  );

  // print the adress of the deployed contract 
  console.log(
    "Crypto Devs Contract Address : ",
    deployedCryptoDevsContract.address
  );

}

// call the main function and catch if there is any error

main()
  .then(() => process.exit(0))
  .catch((error) => {
  console.log(error);
  process.exit(1);
  });