//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/Base64.sol";

contract SVGNFT is ERC721URIStorage {
    uint256 tokenCounter;

    constructor() ERC721("SVG NFT", "svgBFT") {
        tokenCounter = 0;
    }

    function create(string memory _svg) public {
        _safeMint(msg.sender, tokenCounter);
        tokenCounter = tokenCounter + 1;
        //imageURI
        string memory imageURI = svgToImageURI(_svg);
        //tokenURI
        string memory tokenURI = formatTokenURI(imageURI);
    }

    function svgToImageURI(string memory _svg)
        public
        pure
        returns (string memory)
    {
        //<svg xmlns="http://www.w3.org/2000/svg" height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" /></svg>
        //data:image/svg+xml;base64,<Base65-encoding>
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
}
