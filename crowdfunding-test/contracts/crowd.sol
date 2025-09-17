// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Campaign {
        address creator;
        string title;
        string description;
        uint256 goal;
        uint256 deadline;
        uint256 totalFunded;
        bool withdrawn;
    }
    
    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public pledges;
    
    event CampaignCreated(uint256 id, address creator, uint256 goal, uint256 deadline);
    event Pledged(uint256 campaignId, address backer, uint256 amount);
    event Withdrawn(uint256 campaignId, uint256 amount);
    event Refunded(uint256 campaignId, address backer, uint256 amount);
    
    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _goal,
        uint256 _durationDays
    ) external {
        require(_goal > 0, "Goal must be positive");
        
        uint256 deadline = block.timestamp + (_durationDays * 1 days);
        
        campaignCount++;
        campaigns[campaignCount] = Campaign({
            creator: msg.sender,
            title: _title,
            description: _description,
            goal: _goal,
            deadline: deadline,
            totalFunded: 0,
            withdrawn: false
        });
        
        emit CampaignCreated(campaignCount, msg.sender, _goal, deadline);
    }
    
    function pledge(uint256 _campaignId) external payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Pledge amount must be positive");
        
        campaign.totalFunded += msg.value;
        pledges[_campaignId][msg.sender] += msg.value;
        
        emit Pledged(_campaignId, msg.sender, msg.value);
    }
    
    function withdraw(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.creator, "Only creator can withdraw");
        require(block.timestamp >= campaign.deadline, "Campaign not ended");
        require(campaign.totalFunded >= campaign.goal, "Goal not reached");
        require(!campaign.withdrawn, "Already withdrawn");
        
        campaign.withdrawn = true;
        payable(msg.sender).transfer(campaign.totalFunded);
        
        emit Withdrawn(_campaignId, campaign.totalFunded);
    }
    
    function refund(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign not ended");
        require(campaign.totalFunded < campaign.goal, "Goal was reached");
        
        uint256 amount = pledges[_campaignId][msg.sender];
        require(amount > 0, "No pledge to refund");
        
        pledges[_campaignId][msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        
        emit Refunded(_campaignId, msg.sender, amount);
    }
    
    function getCampaignDetails(uint256 _campaignId) external view returns (
        address creator,
        string memory title,
        string memory description,
        uint256 goal,
        uint256 deadline,
        uint256 totalFunded,
        bool withdrawn
    ) {
        Campaign memory campaign = campaigns[_campaignId];
        return (
            campaign.creator,
            campaign.title,
            campaign.description,
            campaign.goal,
            campaign.deadline,
            campaign.totalFunded,
            campaign.withdrawn
        );
    }
}