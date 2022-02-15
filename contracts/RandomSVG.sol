//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "base64-sol/base64.sol";

contract RandomSVG is ERC721URIStorage, VRFConsumerBase {
    bytes32 public keyHash;
    uint256 public fee;
    uint256 public tokenCounter;

    //SVG parameters
    uint256 public maxNumberOfPath;
    uint256 public maxNumberOfPathCommands;
    uint256 public size;
    string[] public pathCommands;
    string[] public colors;
    //

    mapping(bytes32 => address) public requestIdToUserAddress; //should be private
    mapping(bytes32 => uint256) public requestIdtoTokenId; //should be private
    mapping(uint256 => uint256) public tokenIdToRandomNumber; //should be private
    event RequestRandomSVG(bytes32 indexed requestId, uint256 tokenId);
    event CreateUnfinishedRandomSVG(
        uint256 indexed tokenId,
        uint256 randomNumber
    );
    event TokenURIEvent(uint256 tokenId, string tokenURI);

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

        maxNumberOfPath = 10;
        maxNumberOfPathCommands = 5;
        size = 500;
        pathCommands = ["M", "L"];
        colors = ["red", "blue", "green", "yellow", "black", "white"];
    }

    function create() public returns (bytes32 requestId) {
        requestId = requestRandomness(keyHash, fee);
        requestIdToUserAddress[requestId] = msg.sender;
        uint256 tokenId = tokenCounter;
        requestIdtoTokenId[requestId] = tokenId;
        tokenCounter = tokenCounter + 1;
        emit RequestRandomSVG(requestId, tokenId);

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
        emit CreateUnfinishedRandomSVG(tokenId, randomNumber);
    }

    function finishMint(uint256 _tokenId) public {
        // check to see if it's been minted and a random number is returned
        // generate some random SVG code
        // turn that conde in the imageURI
        // use that imageURI to format into a tokenURI
        require(
            bytes(tokenURI(_tokenId)).length <= 0,
            "tokenURI is already all set!"
        );
        require(tokenCounter > _tokenId, "TokenId has not been minted yet");
        require(
            tokenIdToRandomNumber[_tokenId] > 0,
            "Need to wait for Chainlink VRF"
        );

        uint256 randomNumber = tokenIdToRandomNumber[_tokenId];
        string memory svg = generateSVG(randomNumber);
        string memory imageURI = svgToImageURI(svg);
        string memory tokenURI = formatTokenURI(imageURI);
        _setTokenURI(_tokenId, tokenURI);
        emit TokenURIEvent(_tokenId, tokenURI);
    }

    function generateSVG(uint256 _randomNumber)
        public
        returns (string memory finalSvg)
    {
        uint256 numberOfPaths = (_randomNumber % maxNumberOfPath) + 1;
        finalSvg = string(
            abi.encodePacked(
                "'<svg xmlns='http://www.w3.org/2000/svg' height='",
                uint2str(size),
                "' width='",
                uint2str(size),
                "'>"
            )
        );
        for (uint256 i = 0; i < numberOfPaths; i++) {
            uint256 newRNG = uint256(keccak256(abi.encode(_randomNumber, i)));
            string memory pathSvg = generatePath(newRNG);
            finalSvg = string(abi.encodePacked(finalSvg, pathSvg));
        }
        finalSvg = string(abi.encodePacked(finalSvg, " </svg>"));
    }

    function generatePath(uint256 _randomNumber)
        public
        view
        returns (string memory pathSvg)
    {
        uint256 numberOfCommands = (_randomNumber % maxNumberOfPathCommands) +
            1;
        string memory path = "<path d='";
        for (uint256 i = 0; i < numberOfCommands; i++) {
            uint256 newRand = uint256(
                keccak256(abi.encode(_randomNumber, size + 1))
            );
            string memory pathCommand = generatePathCommand(newRand);
            path = string(abi.encodePacked(path, pathCommand));
        }
        string memory color = colors[_randomNumber % colors.length];
        path = string(
            abi.encodePacked(path, "' fill='transparent' stroke='", color, "'>")
        );
    }

    function generatePathCommand(uint256 _randomNumber)
        public
        view
        returns (string memory pathCommand)
    {
        pathCommand = pathCommands[_randomNumber % pathCommands.length];
        uint256 parameterOne = uint256(
            keccak256(abi.encode(_randomNumber, size * 2))
        ) % size;
        uint256 parameterTwo = uint256(
            keccak256(abi.encode(_randomNumber, size * 3))
        ) % size;
        pathCommand = string(
            abi.encodePacked(
                pathCommand,
                " ",
                uint2str(parameterOne),
                " ",
                uint2str(parameterTwo)
            )
        );
    }

    function svgToImageURI(string memory _svg)
        public
        pure
        returns (string memory)
    {
        //<svg xmlns="http://www.w3.org/2000/svg" height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" /></svg>
        //data:image/svg+xml;base64,<Base64-encoding>
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(_svg)))
        );
        string memory imageURI = string(
            abi.encodePacked(baseURL, svgBase64Encoded)
        );
        return imageURI;
    }

    function formatTokenURI(string memory _imageURI)
        public
        pure
        returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        string memory json = string(
            abi.encodePacked(
                '{"name": "SVG NFT", "description": "An NFT based on SVG", "attributes": "", "image": "',
                _imageURI,
                '"}'
            )
        );

        return
            string(
                abi.encodePacked(
                    baseURL,
                    Base64.encode(bytes(abi.encodePacked(json)))
                )
            );
    }

    function uint2str(
        uint256 _i //From StackOverflow
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
