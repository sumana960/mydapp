// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonadNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    uint256 public mintPrice = 0; // ✅ GRATUIT POUR TEST
    uint256 public maxSupply = 10000;
    bool public paused = false;
    string private _baseTokenURI;

    event Minted(address indexed to, uint256 indexed tokenId);

    constructor() ERC721("MonadNFT", "MNFT") Ownable(msg.sender) {}

    // --------------------
    // ADMIN
    // --------------------

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    // --------------------
    // MINT
    // --------------------

    function mint() external payable {
        require(!paused, "Mint paused");
        require(_nextTokenId < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment");

        uint256 tokenId = _nextTokenId;
        _nextTokenId++;

        _safeMint(msg.sender, tokenId);
        emit Minted(msg.sender, tokenId);
    }

    function mintBatch(uint256 quantity) external payable {
        require(!paused, "Mint paused");
        require(quantity > 0, "Quantity zero");
        require(_nextTokenId + quantity <= maxSupply, "Max supply exceeded");
        require(msg.value >= mintPrice * quantity, "Insufficient payment");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _nextTokenId;
            _nextTokenId++;
            _safeMint(msg.sender, tokenId);
            emit Minted(msg.sender, tokenId);
        }
    }

    function mintTo(address to, string memory uri) external onlyOwner {
        require(_nextTokenId < maxSupply, "Max supply reached");

        uint256 tokenId = _nextTokenId;
        _nextTokenId++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit Minted(to, tokenId);
    }

    // --------------------
    // WITHDRAW
    // --------------------

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance");

        (bool success, ) = owner().call{value: balance}("");
        require(success, "Withdraw failed");
    }

    // --------------------
    // OVERRIDES
    // --------------------

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
