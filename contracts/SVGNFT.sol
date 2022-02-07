//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/Base64.sol";

contract SVGNFT is ERC721URIStorage {
    uint256 tokenCounter;

    constructor() ERC721("SVG NFT", "svgBFT") {
        tokenCounter = 0;
    }

    function create(string memory svg) public {
        _safeMint(msg.sender, tokenCounter);
        tokenCounter = tokenCounter + 1;
        //imageURI
        //tokenURI
    }

    function svgToImageURI(string memory svg) {
        //<svg xmlns="http://www.w3.org/2000/svg" height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" /></svg>
        //data:image/svg+xml;base64,<Base65-encoding>
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory imageURI = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
    }
}
