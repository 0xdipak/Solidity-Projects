//SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.0;

contract Portfolio {
    struct Project {
        uint id;
        string name;
        string description;
        string image;
        string githubLink;
    }

    struct Education {
        uint id;
        string date;
        string degree;
        string knowledgeAcquired;
        string institutionName;
    }

    Project[3] public projects;
    Education[3] public educations;

    string public imageLink = "linkFromIPFS";
    string public description = "linkFromIPFS";
    string public resumeLink = "linkFromIPFS";
    uint projectCount;
    uint educationCount;
    address public Owner;

    constructor() {
        Owner = msg.sender;
    }

    modifier onlyOwner() {
        require(Owner == msg.sender, "Only Owner Have Access To This Function");
        _;
    }

    function addProject(string calldata _name, string calldata _description, string calldata _image, string calldata _githubLink) external {
        require(projectCount < 3, "Only 3 projects allowed");
        projects[projectCount] = Project(projectCount, _name, _description, _image, _githubLink);
        projectCount++;
    }

    function updateProject(string calldata _name, string calldata _description, string calldata _image, string calldata _githubLink, uint _projectCount) external {
        require(_projectCount >= 0 && _projectCount < 3, "Only available projects allowed");
        projects[projectCount] = Project(_projectCount, _name, _description, _image, _githubLink);
    }

    function getProjects() external view returns(Project[3] memory) {
        return projects;
    }

    function addEducation(string calldata _date, string calldata _degree, string calldata _knowledgeAcquired, string calldata _institutionName) external {
        require(educationCount < 3, "Only 3 education allowed");
        educations[educationCount] = Education(educationCount, _date, _degree, _knowledgeAcquired, _institutionName);
        educationCount++;
    }

    function updateEducation(string calldata _date, string calldata _degree, string calldata _knowledgeAcquired, string calldata _institutionName, uint _educationCount) external {
        require(_educationCount >= 0 && _educationCount < 3, "");
        educations[_educationCount] = Education(_educationCount, _date, _degree, _knowledgeAcquired, _institutionName);
    }

    function getEducations() public view returns(Education[3] memory) {
        return educations;
    }

    function changeDescription(string calldata _description) external {
        description = _description;
    }

    function changeImage(string calldata _imageLink) external {
        imageLink = _imageLink;
    }

    function changeResume(string calldata _resumeLink) external {
        resumeLink = _resumeLink;
    }

    function donate() public payable {
        payable(Owner).transfer(msg.value);
    }

}
