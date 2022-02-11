//SPDX-License-Identifer: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomSVG is ERC721URIStorage, VRFConsumerBase {
    bytes32 public keyHash;
    uint256 public fee;
    uint256 public tokenCounter;
    mapping(bytes32 => address) public requestIdToUserAddress; //should be private
    mapping(bytes32 => uint256) public requestIdtoTokenId; //should be private
    mapping(uint256 => uint256) public tokenIdToRandomNumber; //should be private
    event requestRandomSVG(bytes32 indexed requestId, uint256 tokenId);
    event createUnfinishedRandomSVG(
        uint256 indexed tokenId,
        uint256 randomNumber
    );

    constructor(
        address _VRFCoordinator,
        address _linkToken,
        bytes32 _keyHash,
        uint256 _fee
    )
        VRFConsumerBase(_VRFCoordinator, _linkToken)
        ERC721("Surpise SVG", "surpSVG")
    {
        keyHash = _keyHash;
        fee = _fee;
        tokenCounter = 0;
    }

    function create() public returns (bytes32 requestId) {
        requestId = requestRandomness(keyHash, fee);
        requestIdToUserAddress[requestId] = msg.sender;
        uint256 tokenId = tokenCounter;
        requestIdtoTokenId[requestId] = tokenId;
        tokenCounter = tokenCounter + 1;
        emit requestRandomSVG(requestId, tokenId);

        //get a random number
        //use this random number to tgenerate some random SVG
        //base64 encode the SCG
        //get the tokenURI and mint the NFT
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        address nftUser = requestIdToUserAddress[requestId];
        uint256 tokenId = requestIdtoTokenId[requestId];
        _safeMint(nftUser, tokenId);
        tokenIdToRandomNumber[tokenId] = randomNumber;
        emit createUnfinishedRandomSVG(tokenId, randomNumber);
    }

    function finishMint() public {}
}
