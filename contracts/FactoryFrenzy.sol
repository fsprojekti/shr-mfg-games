// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title FactoryFrenzy
 * @dev A simplified version of the manufacturing game where Automated Robot Vehicles (ARVs) collect rewards from various job spots.
 * Each job spot contains one job with a varying reward, which is paid in ERC20 tokens when the job is collected.
 */
contract FactoryFrenzy {

    IERC20 public rewardToken;  // ERC20 token used for paying rewards
    address public owner; // Owner of the factory

    // Struct representing a jobSpot
    struct JobSpot {
        uint256 reward;  // Reward for collecting the job at this jobSpot (in ERC20 tokens)
        address collector;  // Address of the ARV (user) who collected the job
        bytes4 tag;  // RFID tag for the job spot
    }

    // Mapping from jobSpot ID (as uint8) to JobSpot struct
    mapping(bytes4 => JobSpot) public jobSpots;

    // Array to store job spot IDs for easy retrieval
    bytes4[] public jobSpotTags;

    constructor(IERC20 _rewardToken) {
        rewardToken = _rewardToken;
        owner = msg.sender;

        // Hardcoded RFID spots
        _registerTag(hex"073618F2"); // A1
        _registerTag(hex"A73518F2"); // B1
        _registerTag(hex"D73418F2"); // C1
        _registerTag(hex"A7DB18F2"); // D1
        _registerTag(hex"27D718F2"); // E1

        _registerTag(hex"17DD18F2"); // A2
        _registerTag(hex"B7DC18F2"); // B2
        _registerTag(hex"873418F2"); // C2
        _registerTag(hex"373518F2"); // D2
        _registerTag(hex"C7D618F2"); // E2

        _registerTag(hex"17DE18F2"); // A3
        _registerTag(hex"A7AA19F2"); // B3
        _registerTag(hex"273818F2"); // C3
        _registerTag(hex"17D818F2"); // D3
        _registerTag(hex"773718F2"); // E3

        _registerTag(hex"B7DD18F2"); // A4
        _registerTag(hex"77DC18F2"); // B4
        _registerTag(hex"873818F2"); // C4
        _registerTag(hex"77D818F2"); // D4
        _registerTag(hex"273718F2"); // E4

        _registerTag(hex"573618F2"); // A5
        _registerTag(hex"B73618F2"); // B5
        _registerTag(hex"B7D718F2"); // C5
        _registerTag(hex"F7AB19F2"); // D5
        _registerTag(hex"07DC18F2"); // E5
    }

    function _registerTag(bytes4 tag) internal {
        require(jobSpots[tag].tag == 0x0, "tag already exists");
        uint256 reward = random(100) * 1e18;
        jobSpots[tag] = JobSpot({reward: reward, collector: address(0), tag: tag});
        jobSpotTags.push(tag);
    }

    /**
    * @dev Initializes all jobSpots with random rewards.
     * Uses the predefined RFID tags instead of numeric IDs.
     * Can be called again to reset rewards (collectors remain unchanged).
     */
    function initialize() public {
        for (uint i = 0; i < jobSpotTags.length; i++) {
            bytes4 tag = jobSpotTags[i];
            jobSpots[tag].reward = random(100) * 1e18;  // random reward
            jobSpots[tag].collector = address(0);       // reset collector
        }
    }

    /**
    * @dev Allows an ARV (msg.sender) to collect the job at a specific job spot.
     * The ARV must provide the correct RFID tag.
     * The ARV will receive the reward in ERC20 tokens.
     * @param tag The RFID tag of the job spot.
     */
    function collectJob(bytes4 tag) public {
        // Ensure the RFID tag exists
        require(jobSpots[tag].reward > 0, "Invalid RFID tag");

        // Ensure the job has not been collected yet
        require(jobSpots[tag].collector == address(0), "Job at this spot has already been collected");

        // Set the collector to the ARV's address
        jobSpots[tag].collector = msg.sender;

        // Transfer the ERC20 reward to the ARV
        uint256 reward = jobSpots[tag].reward;
        require(rewardToken.balanceOf(address(this)) >= reward, "Factory does not have enough reward tokens");
        rewardToken.transfer(msg.sender, reward);

        // Emit an event for reward collection
        emit JobCollected(msg.sender, tag, reward);
    }

    /**
     * @dev Generates a pseudo-random number between 1 and n, using block properties as a seed.
     * This randomness is used for determining the reward at each job spot.
     */
    function random(uint256 n) internal view returns (uint256) {
        return (uint256(keccak256(abi.encodePacked(block.number, block.timestamp, msg.sender, totalRewards()))) % n) + 1;
    }

    /**
    * @dev Update a single RFID tag for an existing jobSpot.
     */
    function updateTag(bytes4 oldTag, bytes4 newTag) external {
        require(msg.sender == owner, "Not the contract owner");
        require(jobSpots[oldTag].reward > 0, "Old tag does not exist");
        require(jobSpots[newTag].reward == 0, "New tag already exists");

        // Copy the jobSpot
        JobSpot memory spot = jobSpots[oldTag];
        delete jobSpots[oldTag];

        // Assign new tag
        spot.tag = newTag;
        jobSpots[newTag] = spot;

        // Update tag array
        for (uint256 i = 0; i < jobSpotTags.length; i++) {
            if (jobSpotTags[i] == oldTag) {
                jobSpotTags[i] = newTag;
                break;
            }
        }
    }

    /**
 * @dev Batch update multiple RFID tags.
     * oldTags[i] will be replaced by newTags[i].
     */
    function updateAllTags(bytes4[] memory oldTags, bytes4[] memory newTags) external {
        require(msg.sender == owner, "Not the contract owner");
        require(oldTags.length == newTags.length, "Array length mismatch");

        for (uint256 i = 0; i < oldTags.length; i++) {
            // same checks inside loop
            require(jobSpots[oldTags[i]].reward > 0, "Old tag does not exist");
            require(jobSpots[newTags[i]].reward == 0, "New tag already exists");

            JobSpot memory spot = jobSpots[oldTags[i]];
            delete jobSpots[oldTags[i]];
            spot.tag = newTags[i];
            jobSpots[newTags[i]] = spot;

            for (uint256 j = 0; j < jobSpotTags.length; j++) {
                if (jobSpotTags[j] == oldTags[i]) {
                    jobSpotTags[j] = newTags[i];
                    break;
                }
            }
        }
    }

    /**
     * @dev Returns the reward for a job at a given job spot.
     * If the job has already been collected, the reward will be 0.
     * @param tag The RFID tag of the job spot to query.
     */
    function getJobReward(bytes4 tag) public view returns (uint256) {
        JobSpot memory spot = jobSpots[tag];
        if (spot.collector != address(0)) {
            return 0;  // Return 0 if the job has already been collected
        }
        return spot.reward;
    }

    /**
     * @dev Returns an array of all job spot RFID tags.
     */
    function getAllJobSpots() public view returns (bytes4[] memory) {
        return jobSpotTags;
    }


    /**
     * @dev Calculates and returns the total rewards across all job spots.
     * This sums up the reward for each job spot, regardless of whether it has been collected.
     */
    function totalRewards() public view returns (uint256 totalReward) {
        for (uint256 i = 0; i < jobSpotTags.length; i++) {
            totalReward += jobSpots[jobSpotTags[i]].reward;
        }
        return totalReward;
    }


    /**
     * @dev Allows the factory owner to deposit ERC20 tokens into the factory for paying rewards.
     */
    function depositTokens(uint256 amount) public {
        rewardToken.transferFrom(msg.sender, address(this), amount);
    }

    /**
     * @dev Allows the factory owner to withdraw ERC20 tokens from the factory.
     */
    function withdrawTokens(uint256 amount) public {
        require(rewardToken.balanceOf(address(this)) >= amount, "Not enough tokens in the contract");
        rewardToken.transfer(msg.sender, amount);
    }

    // Event for job collection, including the ARV address, job spot RFID tag, and reward
    event JobCollected(address indexed collector, bytes4 indexed tag, uint256 reward);

}