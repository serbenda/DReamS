// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Importamos librerías de contratos de OpenZeppelin para agregar funcionalidades adicionales al contrato
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Definimos el contrato MyToken que hereda de varios contratos de OpenZeppelin
// y del estándar ERC-721 para tokens no fungibles
contract MyToken is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    
    // Utilizamos la librería Counters de OpenZeppelin para llevar un control del contador de tokens emitidos
    using Counters for Counters.Counter;
    
    // Declaramos una variable pública para llevar un registro de la cantidad de tokens emitidos
    uint256 public supply;
    
    // Declaramos una variable privada de tipo Counters.Counter para llevar un control del contador de tokens emitidos
    Counters.Counter private _tokenIdCounter;

    // Declaramos una variable pública para llevar un registro del límite de tokens que pueden ser emitidos
    uint256 public MAX_SUPPLY = 9999;

    // Declaramos un mapeo público para llevar un registro de las URIs existentes
    mapping(string => uint8) public existingURIs;

    // El constructor inicializa el nombre y símbolo del token
    constructor() ERC721("MyToken", "MTK") {}

    // Esta función determina si una URI específica ha sido utilizada para crear un token
    function isOwned(string memory uri) public view returns (bool) {
        // Devuelve true si la URI está en el mapeo y su valor es 1, false en caso contrario
        return existingURIs[uri] == 1;
    }

    // Esta función es utilizada para obtener la URI base para los tokens
    function _baseURI() internal pure override returns (string memory) {
        // Devuelve "ipfs://" como URI base para los tokens
        return "ipfs://";
    }

    // Esta función permite consultar la cantidad de tokens emitidos
    function getSupply() public view returns (uint256) {
        // Devuelve el valor de la variable 'supply' que lleva un registro de la cantidad de tokens emitidos
        return supply;
    }

    // Esta función permite pausar el contrato
    function pause() public onlyOwner {
        // Llamamos a la función _pause() de la librería Pausable para pausar el contrato
        _pause();
    }

    // Esta función permite reanudar el contrato
    function unpause() public onlyOwner {
        // Llamamos a la función _unpause() de la librería Pausable para reanudar el contrato
        _unpause();
    }

    // Esta función permite a los usuarios pagar para crear un nuevo token con una URI específica
    function payToMint(
        // Recibe como argumento la dirección del receptor del nuevo token y la URI del nuevo token
        address recipient,
        string memory metadataURI
    ) public payable returns (uint256) {
        // Verificamos que la URI del nuevo token no haya sido utilizada previamente para crear un token
        require(existingURIs[metadataURI] != 1, "This token has already been minted");
        // Verificamos que el usuario haya enviado un pago de al menos 0.0555 ether para crear el nuevo token
        require (msg.value >= 0.0555 ether, "This contract requires a payment to mint");

        // Obtenemos el siguiente ID de token disponible utilizando el contador _tokenIdCounter
        uint256 newToken = _tokenIdCounter.current();
        // Incrementamos el contador para el próximo token
        _tokenIdCounter.increment();
        // Actualizamos el mapeo de URIs existentes para indicar que la URI del nuevo token ya ha sido utilizada
        existingURIs[metadataURI] = 1;

        // Llamamos a la función _mint() de la librería ERC721 para crear y transferir el nuevo token
        _mint(recipient, newToken);

        // Llamamos a la función _setTokenURI() de la librería ERC721URIStorage para establecer la URI del nuevo token
        _setTokenURI(newToken, metadataURI);

        
// Devolvemos el ID del nuevo token
        return newToken;
    }

    // Esta función permite al propietario del contrato crear y transferir un nuevo token con una URI específica
    // Recibe como argumento la dirección del receptor del nuevo token y la URI del nuevo token
    function safeMint(address to, string memory uri) public onlyOwner {
        // Verificamos que no se haya alcanzado el límite de tokens que pueden ser emitidos
        require(supply < MAX_SUPPLY, "Minted Out");
        // Obtenemos el siguiente ID de token disponible utilizando el contador _tokenIdCounter
        uint256 tokenId = _tokenIdCounter.current();
        // Incrementamos el contador para el próximo token
        _tokenIdCounter.increment();
        // Llamamos a la función _safeMint() de la librería ERC721 para crear y transferir el nuevo token
        _safeMint(to, tokenId);
        // Llamamos a la función _setTokenURI() de la librería ERC721URIStorage para establecer la URI del nuevo token
        _setTokenURI(tokenId, uri);
        // Incrementamos la cantidad de tokens emitidos
        supply++;
    }

    // Esta función es una sobrecarga (override) de la función _beforeTokenTransfer() de la librería ERC721
    function _beforeTokenTransfer(
        // Recibe como argumentos las direcciones de origen y destino, el ID del token y el tamaño del lote
        address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        // Llamamos a la función _beforeTokenTransfer() de la librería ERC721 para ejecutar la funcionalidad original
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    // Esta función es una sobrecarga (override) de la función _burn() de la librería ERC721
    // Esta función se ejecuta al quemar (borrar) un token
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        // Llamamos a la función _burn() de la librería ERC721 para ejecutar la funcionalidad original
        super._burn(tokenId);
    }

    // Esta función es una sobrecarga (override) de la función tokenURI() de la librería ERC721URIStorage
    // Esta función permite consultar la URI de un token específico
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        // Llamamos a la función tokenURI() de la librería ERC721URIStorage para ejecutar la funcionalidad original
        return super.tokenURI(tokenId);
    }
}

