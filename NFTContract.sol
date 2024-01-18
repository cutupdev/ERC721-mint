// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@5.0.0/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VECNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    uint256 public ETHPrice;
    uint256 public TokenPrice;
    address public TokenAddr;
    Counters.Counter private _itemIds;

    struct NFTItem {
        uint256 id;
        address creator;
        string uri;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => NFTItem) private _items;

    constructor(address initialOwner)
        ERC721("VECNAZMAGANFT", "VEC")
        Ownable(initialOwner)
    {}

    function safeMint(
        address to,
        string memory uri,
        uint256 price
    ) public onlyOwner {
        _itemIds.increment();
        uint256 tokenId = _itemIds.current();

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _items[tokenId] = NFTItem(tokenId, msg.sender, uri, price, false);
    }

    // The following functions are overrides required by Solidity.
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
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function allowBuy(uint256 _tokenId, uint256 _price) external {
        require(msg.sender == ownerOf(_tokenId), "Not owner of this token");
        require(_price > 0, "Price zero");
        _items[_tokenId].price = _price;
    }

    function disallowBuy(uint256 _tokenId) external {
        require(msg.sender == ownerOf(_tokenId), "Not owner of this token");
        _items[_tokenId].price = 0;
    }

    function buy(uint256 _tokenId) external payable {
        uint256 price = _items[_tokenId].price;
        require(price > 0, "This token is not for sale");
        require(msg.value == price, "Incorrect value");

        address seller = ownerOf(_tokenId);
        _transfer(seller, msg.sender, _tokenId);
        _items[_tokenId].price = 0; // not for sale anymore
        payable(seller).transfer(msg.value); // send the ETH to the seller
    }
}