// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./crowd.sol";

contract CrowdFactory {
    struct FactoryCampaign {
        address campaignAddress;
        address creator;
        uint256 creationTime;
    }
    
    FactoryCampaign[] public campaigns;
    
    event NewCrowdfundingCampaign(
        uint256 indexed id,
        address indexed creator,
        address campaignAddress,
        uint256 creationTime
    );
    
    function createCrowdfundingCampaign() external returns (address) {
        Crowdfunding newCampaign = new Crowdfunding();
        campaigns.push(FactoryCampaign({
            campaignAddress: address(newCampaign),
            creator: msg.sender,
            creationTime: block.timestamp
        }));
        
        emit NewCrowdfundingCampaign(
            campaigns.length - 1,
            msg.sender,
            address(newCampaign),
            block.timestamp
        );
        
        return address(newCampaign);
    }
    
    function getCampaignCount() external view returns (uint256) {
        return campaigns.length;
    }
    
    function getAllCampaigns() external view returns (FactoryCampaign[] memory) {
        return campaigns;
    }
    
    function getCampaignsByCreator(address _creator) external view returns (FactoryCampaign[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < campaigns.length; i++) {
            if (campaigns[i].creator == _creator) {
                count++;
            }
        }
        
        FactoryCampaign[] memory creatorCampaigns = new FactoryCampaign[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < campaigns.length; i++) {
            if (campaigns[i].creator == _creator) {
                creatorCampaigns[index] = campaigns[i];
                index++;
            }
        }
        
        return creatorCampaigns;
    }
}