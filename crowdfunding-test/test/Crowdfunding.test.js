const { expect } = require("chai");
const hre = require("hardhat");

describe("Crowdfunding System", function () {
  let crowdfunding;
  let factory;
  let owner, backer1, backer2;

  before(async function () {
    [owner, backer1, backer2] = await hre.ethers.getSigners();

    // Deploy CrowdFactory
    const CrowdFactory = await hre.ethers.getContractFactory("CrowdFactory");
    factory = await CrowdFactory.deploy();
    
    // Deploy a Crowdfunding campaign
    await factory.createCrowdfundingCampaign();
    const campaigns = await factory.getAllCampaigns();
    const campaignAddress = campaigns[0].campaignAddress;

    // Get Crowdfunding instance
    const Crowdfunding = await hre.ethers.getContractFactory("Crowdfunding");
    crowdfunding = await Crowdfunding.attach(campaignAddress);
  });

  describe("Crowdfunding Contract", function () {
    it("Should create a campaign", async function () {
      await crowdfunding.connect(owner).createCampaign(
        "Test Campaign",
        "A test description",
        hre.ethers.parseEther("10"), // Using hre.ethers
        7
      );

      const campaign = await crowdfunding.campaigns(1);
      expect(campaign.creator).to.equal(owner.address);
      expect(campaign.goal).to.equal(hre.ethers.parseEther("10"));
    });
  });
});