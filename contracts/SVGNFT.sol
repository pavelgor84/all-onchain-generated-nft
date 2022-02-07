//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SVGNFT is ERC721URIStorage {
    uint256 tokenCounter;

    constructor() ERC721("SVG NFT", "svgBFT") {
        tokenCounter = 0;
    }

    function create(string memory svg) public {
        _safeMint(msg.sender, tokenCounter);
    }
}
