const { ethers } = require("hardhat");

async function main() {
  // Deploy Factory
  const CrowdFactory = await ethers.getContractFactory("CrowdFactory");
  const factory = await CrowdFactory.deploy();
  
  console.log(`Factory deployed to: ${factory.target}`);

  // Optional: Create a sample campaign
  const tx = await factory.createCrowdfundingCampaign();
  await tx.wait();
  const campaigns = await factory.getAllCampaigns();
  console.log(`First campaign deployed to: ${campaigns[0].campaignAddress}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});