// SPDX-License-Identifier: DReamS
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TREEMINTTEST is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    uint256 public supply;

    Counters.Counter private _tokenIdCounter;

    // CUSTOM PARAMETERS
    uint256 public MAX_SUPPLY = 9999; // Set max supply
    mapping(string => uint8) public existingURIs; // Mapping to ensure unique URI

    constructor() ERC721("NFT Contract", "NFT") {
        // Initialize the counter with 1 to leave 0 available for the "null item"
        _tokenIdCounter.set(1);
    }

    function isOwned(string memory uri) public view returns (bool) {
        return existingURIs[uri] == 1;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function getSupply() public view returns (uint256) {
        return supply;
    }

    // Pay to mint function
    function payToMint(
        address recipient,
        string memory metadataURI
    ) public payable returns (uint256) {
        require(existingURIs[metadataURI] != 1, "This token has already been minted");
        require (msg.value >= 0.0555 ether, "This contract requires a payment to mint");

        uint256 newToken = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        existingURIs[metadataURI] = 1;

        _mint(recipient, newToken);
        _setTokenURI(newToken, metadataURI);

        return newToken;
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        require(supply < MAX_SUPPLY, "Minted Out");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        supply++;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
