// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Donate {
    uint256 idLength;

    struct Project {
        address creator;
        uint256 value;
        uint256 shareLength;
        uint256 sharePer;
        uint256 donateLength;
        uint256 perShareAmount;
        mapping(address => bool) isShare;
        mapping(address => uint256) claimedPerShareAmount;
        string url;
    }

    mapping(uint256 => Project) public projectList;

    function create(
        address creator,
        uint256 shareLength,
        uint256 sharePer,
        string memory url
    ) public returns (uint256) {
        idLength++;
        projectList[idLength].creator = creator;
        projectList[idLength].url = url;
        projectList[idLength].shareLength = shareLength;
        projectList[idLength].sharePer = sharePer;
        return idLength;
    }

    function donate(uint256 id) external payable {
        if (projectList[id].shareLength < projectList[id].donateLength) {
            projectList[id].isShare[msg.sender] = true;
            projectList[id].value += msg.value;
        } else {
            uint256 shareAmount = (msg.value * projectList[id].sharePer) / 100;
            projectList[id].value += msg.value - shareAmount;
            projectList[id].perShareAmount +=
                shareAmount /
                projectList[id].shareLength;
        }
        projectList[id].donateLength++;
    }

    function getShare(uint256 id) external {
        if (projectList[id].isShare[msg.sender]) {
            if (
                projectList[id].perShareAmount >
                projectList[id].claimedPerShareAmount[msg.sender]
            ) {
                uint256 value = projectList[id].perShareAmount -
                    projectList[id].claimedPerShareAmount[msg.sender];
                projectList[id].claimedPerShareAmount[msg.sender] = projectList[
                    id
                ].perShareAmount;
                payable(msg.sender).transfer(value);
            }
        }
    }

    function getDonate(uint256 id) external {
        require(msg.sender == projectList[id].creator);
        uint256 value = projectList[id].value;
        projectList[id].value = 0;
        payable(msg.sender).transfer(value);
    }
}
