const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function deploy() {
  [account] = await ethers.getSigners();
  deployerAddress = account.address;
  console.log(`Deploying contracts using ${deployerAddress}`);
  const swapexample = await ethers.getContractFactory("SwapExamples");
  const swapexampleInstance = await swapexample.deploy(
    "0xE592427A0AEce92De3Edee1F18E0157C05861564"
  );
  await swapexampleInstance.deployed();
  console.log("Swap example contract deployed at", swapexampleInstance.address);

  await run(`verify:verify`, {
    address: swapexampleInstance.address,
    constructorArguments: ["0xE592427A0AEce92De3Edee1F18E0157C05861564"],
  });

  fs.writeFileSync(
    path.join(__dirname, "./address.json"),
    JSON.stringify({ address: swapexampleInstance.address })
  );
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
