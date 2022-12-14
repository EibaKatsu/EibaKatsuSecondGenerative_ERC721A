// SPDX-License-Identifier: MIT
// Copyright (c) 2022 Katsuro Eibayashi

/*

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

pragma solidity >=0.7.0 <0.9.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol"; 

contract EibaKatsuSecondGenerative is ERC721A, Ownable {
    string baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.0005 ether;
    uint256 public maxSupply = 1000;
    uint256 public preSaleSupply = 1000;
    uint256 public maxMintAmount = 5;
    bool public paused = false;
    bool public onlyWhitelisted = true;
    mapping(address => uint256) public whitelistUserAmount;
    mapping(address => uint256) public whitelistMintedAmount;

    constructor(
        string memory token_name,
        string memory token_code,
        string memory _initBaseURI
    ) ERC721A(token_name, token_code) {
        setBaseURI(_initBaseURI);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(uint256 _mintAmount) public payable {

    console.log(
      " cost confirmation.\n value: %s,\n sender: %s,\n owner: %s",
      msg.value,
      msg.sender,
      owner()
    );

        require(!paused, "the contract is paused");
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        require(
            _mintAmount <= maxMintAmount,
            "max mint amount per session exceeded"
        );
        require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");
        require(
            supply + _mintAmount <= preSaleSupply,
            "pre Sale NFT limit exceeded"
        );

        // Owner also can mint.
        if (msg.sender != owner()) {
            require(msg.value >= cost * _mintAmount, "insufficient funds");
            if (onlyWhitelisted == true) {
                require(
                    whitelistUserAmount[msg.sender] != 0,
                    "user is not whitelisted"
                );
                require(
                    whitelistMintedAmount[msg.sender] + _mintAmount <=
                        whitelistUserAmount[msg.sender],
                    "max NFT per address exceeded"
                );
                whitelistMintedAmount[msg.sender] += _mintAmount;
            }
        }

        _safeMint(msg.sender, _mintAmount);
    }

    function airdropMint(
        address[] calldata _airdropAddresses,
        uint256[] memory _UserMintAmount
    ) public onlyOwner {
        uint256 supply = totalSupply();
        uint256 _mintAmount = 0;
        for (uint256 i = 0; i < _UserMintAmount.length; i++) {
            _mintAmount += _UserMintAmount[i];
        }
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

        for (uint256 i = 0; i < _UserMintAmount.length; i++) {
            _safeMint(_airdropAddresses[i], _UserMintAmount[i]);
        }
    }

    function setWhitelist(
        address[] memory addresses,
        uint256[] memory saleSupplies
    ) public onlyOwner {
        require(addresses.length == saleSupplies.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelistUserAmount[addresses[i]] = saleSupplies[i];
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return
            string(abi.encodePacked(ERC721A.tokenURI(tokenId), baseExtension));
    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setOnlyWhitelisted(bool _state) public onlyOwner {
        onlyWhitelisted = _state;
    }

    function setpreSaleSupply(uint256 _newpreSaleSupply) public onlyOwner {
        preSaleSupply = _newpreSaleSupply;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}
