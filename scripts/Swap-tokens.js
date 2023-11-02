const { ethers } = require("hardhat");
const erc20ABI = require("../abi/erc20.json");
const uniswapRouterABI = require("../abi/uniswapRouter.json");
const UniSwap = require("./address.json");


async function SwapTokens() {
  // Get the signer account
  const [account] = await ethers.getSigners();
  const deployerAddress = account.address;

  // Token addresses
  const token0 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; // WETH
  const token1 = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"; // USDC

  // Amount to swap (1 WETH in this case)
  const tokenAmount = ethers.utils.parseEther("1");

  // Uniswap Router contract address
  const uniswapRouterAddress = UniSwap.address;

  // Create contract instances
  const token0Contract = new ethers.Contract(token0, erc20ABI, account);
  const uniswapRouter = new ethers.Contract(uniswapRouterAddress, uniswapRouterABI, account);

  // Mint WETH tokens
  const mintTransaction = await token0Contract.deposit({ value: tokenAmount });
  await mintTransaction.wait();
  console.log(`${ethers.utils.formatEther(tokenAmount)} WETH tokens minted successfully`);

  // Approve WETH tokens for the Uniswap Router
  const approveTransaction = await token0Contract.approve(uniswapRouterAddress, tokenAmount);
  await approveTransaction.wait();
  console.log("WETH tokens approved to Uniswap Router");

  // Swap WETH for USDC
  const swapTransaction = await uniswapRouter.swapExactInputSingle(
    token0,
    token1,
    tokenAmount,
    3000
  );

  await swapTransaction.wait();
  console.log("Tokens swapped successfully");
}


SwapTokens()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
