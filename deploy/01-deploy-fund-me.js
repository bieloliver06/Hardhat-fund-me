const { network } = require("hardhat");

const { verify } = require("../utils/verify");

const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config.js");

module.exports = async (hre) => {
  const { getNamedAccounts, deployments } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  //const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
  let ethUsdPriceFeedAddress;
  if (developmentChains.includes(network.name)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }

  const args = [ethUsdPriceFeedAddress];

  const FundMe = await deploy("FundMe", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: network.config.blockConfrimations || 1,
  });

  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(FundMe.address, args);
  }

  log(
    "______________________________________________________________________________________________________________________________"
  );
};

module.exports.tags = ["all", "fundme"];
