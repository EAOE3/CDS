// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import "OERC721.sol";

contract chaoticDJs is OERC721 {
    using Strings for uint256;

    mapping(address => uint256) _glAccess;
    uint256 private _glPrice;
    uint256 private _glUserMintLimit;
    uint256 private _glMintLimit;
    uint256 private _glActive;

    mapping(address => uint256) _glUserMints; //Amount of mints performed by this user
    uint256 private _glMints; //Amount of mints performed in this mint



    mapping(address => uint256) _wlAccess;
    uint256 private _wlPrice;
    uint256 private _wlUserMintLimit;
    uint256 private _wlMintLimit;
    uint256 private _wlActive;

    mapping(address => uint256) _wlUserMints; //Amount of mints performed by this user
    uint256 private _wlMints; //Amount of mints performed in this mint


    uint256 private _pmPrice;
    uint256 private _pmUserMintLimit;
    uint256 private _pmMintLimit;
    uint256 private _pmActive;

    mapping(address => uint256) _pmUserMints; //Amount of mints performed by this user

    uint256 _maxSupply;

    uint256 private _reveal;

    constructor() {
        _name = "Chaotic DJs";
        _symbol = "CDS";
    }

    //Read Functions===========================================================================================================================================================

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        if(_reveal == 1) {return string(abi.encodePacked(uriLink, tokenId.toString(), ".json"));}

        return string(abi.encodePacked(uriLink, "secret.json"));
    }

    function glData(address user) external view returns(bool listed, uint256 userMints, uint256 mints, uint256 price, uint256 userMintLimit, uint256 mintLimit, bool active) {
        listed = _glAccess[user] == 1;
        userMints = _glUserMints[user];
        mints = _glMints;
        price = _glPrice;
        userMintLimit = _glUserMintLimit;
        mintLimit = _glMintLimit;
        active = _glActive == 1;
    }

    function wlData(address user) external view returns(bool listed, uint256 userMints, uint256 mints, uint256 price, uint256 userMintLimit, uint256 mintLimit, bool active) {
        listed = _wlAccess[user] == 1;
        userMints = _wlUserMints[user];
        mints = _wlMints;
        price = _wlPrice;
        userMintLimit = _wlUserMintLimit;
        mintLimit = _wlMintLimit;
        active = _wlActive == 1;
    }

    function pmData(address user) external view returns(uint256 userMints, uint256 price, uint256 userMintLimit, bool active) {
        userMints = _pmUserMints[user];
        price = _pmPrice;
        userMintLimit = _pmUserMintLimit;
        active = _pmActive == 1;
    }

    function maxSupply() external view returns(uint256) {return _maxSupply;}

    //Moderator Functions======================================================================================================================================================

    function addGLusers(address[] calldata users) external Manager {
        uint256 size = users.length;

        for(uint256 t; t < size; ++t) {
            _glAccess[users[t]] = 1;
        }
    }

    function addWLusers(address[] calldata users) external Manager {
        uint256 size = users.length;

        for(uint256 t; t < size; ++t) {
            _wlAccess[users[t]] = 1;
        }
    }

    function removeGLusers(address[] calldata users) external Manager {
        uint256 size = users.length;

        for(uint256 t; t < size; ++t) {
            _glAccess[users[t]] = 0;
        }
    }

    function removeWLusers(address[] calldata users) external Manager {
        uint256 size = users.length;

        for(uint256 t; t < size; ++t) {
            _wlAccess[users[t]] = 0;
        }
    }

    function setGlData(uint256 price, uint256 userMintLimit, uint256 mintLimit, uint256 active) external Manager {
        _glPrice = price;
        _glUserMintLimit = userMintLimit;
        _glMintLimit = mintLimit;
        _glActive = active;
    }

    function setWlData(uint256 price, uint256 userMintLimit, uint256 mintLimit, uint256 active) external Manager {
        _wlPrice = price;
        _wlUserMintLimit = userMintLimit;
        _wlMintLimit = mintLimit;
        _wlActive = active;
    }

    function setPmData(uint256 price, uint256 userMintLimit, uint256 active) external Manager {
        _pmPrice = price;
        _pmUserMintLimit = userMintLimit;
        _pmActive = active;
    }

    function setMaxSupply(uint256 maxSupply) external Manager {
        _maxSupply = maxSupply;
    }

    function setReveal(uint256 reveal) external Manager {
        _reveal = reveal;
    }

    //User Functions======================================================================================================================================================

    function glMint() external payable {
        require(_glMints < _glMintLimit, "CDS: WL has sold out");
        require(_glActive == 1, "CDS: WL minting is closed");
        require(_glAccess[msg.sender] == 1, "CDS: Invalid Access");

        uint256 price = _glPrice;

        require(msg.value % price == 0, "CDS: Wrong Value");

        uint256 amount = msg.value / price;

        require((_glMints += amount) <= _glMintLimit, "CDS: Mint Limit Exceeded");
        require((_glUserMints[msg.sender] += amount) <= _glUserMintLimit, "CDS: User Mint Limit Exceeded");

        _mint(msg.sender, amount);

        require(_totalSupply <= _maxSupply, "CDS: Supply Exceeded");
    }

    function wlMint() external payable {
        require(_wlMints < _wlMintLimit, "CDS: WL has sold out");
        require(_wlActive == 1, "CDS: WL minting is closed");
        require(_wlAccess[msg.sender] == 1, "CDS: Invalid Access");

        uint256 price = _wlPrice;

        require(msg.value % price == 0, "CDS: Wrong Value");

        uint256 amount = msg.value / price;

        require((_wlMints += amount) <= _wlMintLimit, "CDS: Mint Limit Exceeded");
        require((_wlUserMints[msg.sender] += amount) <= _wlUserMintLimit, "CDS: User Mint Limit Exceeded");

        _mint(msg.sender, amount);

        require(_totalSupply <= _maxSupply, "CDS: Supply Exceeded");
    }

    function pmMint() external payable {
        require(_pmActive == 1, "CDS: WL minting is closed");

        uint256 price = _pmPrice;

        require(msg.value % price == 0, "CDS: Wrong Value");

        uint256 amount = msg.value / price;

        require((_pmUserMints[msg.sender] += amount) <= _pmUserMintLimit, "CDS: User Mint Limit Exceeded");

        _mint(msg.sender, amount);

        require(_totalSupply <= _maxSupply, "CDS: Supply Exceeded");
    }



}
