// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// Import the required contracts from the OpenZeppelin library
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Define the DReamS contract as a subclass of ERC721, ERC721URIStorage, and Ownable
contract DReamS is ERC721, ERC721URIStorage, Ownable {
    // Use the Counter struct from the Counters library
    using Counters for Counters.Counter;

    // Define the supply variable as a public variable of type uint256
    uint256 public supply;

    // Define the _tokenIdCounter storage variable as a private Counter
    Counters.Counter private _tokenIdCounter;

    // Define the MAX_SUPPLY and existingURIs variables as public variables
    uint256 public MAX_SUPPLY = 9999; // Set max supply
    mapping(string => uint8) public existingURIs; // Mapping to ensure unique URI

    // Define the constructor function
    constructor() ERC721("NFT Contract", "NFT") {
        // Initialize the counter with 1 to leave 0 available for the "null item"
        _tokenIdCounter.set(1);
    }

    /**
    * @notice Check if a token with the given URI has already been minted
    * @param uri The URI of the token to check
    * @return A boolean indicating whether the token has been minted
    */
    function isOwned(string memory uri) public view returns (bool) {
        // Return true if the token has been minted, false otherwise
        return existingURIs[uri] == 1;
    }

    /**
    * @notice Return the base URI for the contract
    * @dev This function is required by the ERC721URIStorage contract and must be implemented
    * @return The base URI for the contract
    */
    function _baseURI() internal pure override returns (string memory) {
        // Return the base URI for the contract
        return "ipfs://";
    }

    /**
    * @notice Return the total supply of tokens in the contract
    * @return The total supply of tokens
    */
    function getSupply() public view returns (uint256) {
        // Return the value of the supply variable
        return supply;
    }

    /**
    The payToMint function is a public function that can be called from outside the smart contract 
    and can receive Ether as a payment. It takes in two input parameters: an address named recipient 
    and a string named metadataURI.

    The function begins by checking if the value of existingURIs[metadataURI] is equal to 1. If it is, 
    the function will revert and stop executing. This is to ensure that the token identified by metadataURI
    has not already been minted.

    Next, the function checks if the value of msg.value is greater than or equal to 0.0555 Ether. 
    If it is not, the function will also revert and stop executing. This is to ensure that a payment 
    of at least 0.0555 Ether is made to mint a new token.

    If both of these checks are satisfied, the function will execute the following code:

    1. It will retrieve the current value of _tokenIdCounter and store it in a variable named newToken.
    2. It will increment the value of _tokenIdCounter.
    3. It will set the value of existingURIs[metadataURI] to 1. This marks the token identified by 
       metadataURI as having been minted.
    4. It will call the internal function _mint and pass in the recipient and newToken as arguments. 
       This function mints a new token and assigns it to the recipient address.
    5. It will call the internal function _setTokenURI and pass in the newToken and metadataURI as arguments. 
       This function associates the metadataURI with the newly minted token
    */

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

    /**
    The safeMint function is a public function that can only be called by the contract owner. 
    It takes in two input parameters: an address named to and a string named uri.

    The function begins by checking if the value of supply is less than MAX_SUPPLY. If it is not, 
    the function will revert and stop executing, with the error message "Minted Out." This is to 
    ensure that the maximum number of tokens allowed by the contract has not been reached.

    If the check is satisfied, the function will execute the following code:

    1. It will retrieve the current value of _tokenIdCounter and store it in a variable named tokenId.
    2. It will increment the value of _tokenIdCounter.
    3. It will call the internal function _mint and pass in the to and tokenId as arguments. This 
    4. function mints a new token and assigns it to the to address.
    5. It will call the internal function _setTokenURI and pass in the tokenId and uri as arguments. 
    6. This function associates the uri metadata URI with the newly minted token identified by tokenId.
    7. It will increment the value of supply by 1.
    */

    function safeMint(address to, string memory uri) public onlyOwner {
        require(supply < MAX_SUPPLY, "Minted Out");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        supply++;
    }

    /**
    The _burn function is an internal function that can only be called from within the smart contract. 
    It takes in one input parameter: an uint256 named tokenId.
    The function simply calls the _burn function of the superclass (i.e., the ERC721 contract) and passes
    in the tokenId as an argument. This function burns (i.e., destroys) the token identified by tokenId, 
    removing it from circulation.
    The override keyword indicates that this function is an override of a function with the same name 
    defined in the ERC721 and ERC721URIStorage contracts that the contract is subclassing. This means 
    that the implementation of the _burn function in this contract will replace the implementation in the 
    superclass.
    */
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /**
    The tokenURI function is a public function that can be called from outside the smart contract. 
    It takes in one input parameter: an uint256 named tokenId.

    The function calls the tokenURI function of the superclass (i.e., the ERC721URIStorage contract)
    and passes in the tokenId as an argument. This function retrieves the metadata URI associated 
    with the token identified by tokenId.

    The view keyword indicates that this function is a read-only function and does not modify the 
    state of the contract. The override keyword indicates that this function is an override of a 
    function with the same name defined in the ERC721 and ERC721URIStorage contracts that the contract
    is subclassing. This means that the implementation of the tokenURI function in this contract will 
    replace the implementation in the superclass.
    */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
