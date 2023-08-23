//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Instagram {
    struct Image {
        uint256 id;
        string url;
        string caption;
        uint256 totalTipped;
        address payable author;
        address[] tipperAddress;
    }

    uint256 public imageCount;

    mapping(uint256 => Image) public images;

    event imageCreated(uint256 id, string url, string caption, address indexed author);
    event imageTipped(uint256 id, string url, string caption, uint256 currentTip, uint256 totalTipped, address indexed author);


    function uploadImage(string memory _imgUrl, string memory _caption) public {
        require(msg.sender != address(0),"Invalid wallet address");

        imageCount++;
        images[imageCount] = Image(imageCount, _imgUrl, _caption, 0, payable(msg.sender), new address[](0));

        emit imageCreated(imageCount, _imgUrl, _caption, msg.sender);
    }

    function tipImageOwner(uint256 _id) public payable {
        Image memory image = images[_id];

        require(_id > 0 && _id <= imageCount, "ID not found");
        require(msg.value > 0, "Insufficient tip ampunt");
        require(msg.sender != image.author, "Author can not tip ");

        payable(address(image.author)).transfer(msg.value);
        image.totalTipped += msg.value;
        images[_id] = image;

        emit imageTipped(_id, image.url, image.caption, msg.value, image.totalTipped, image.author);
    }
}
