// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Inventory is ERC1155, AccessControl, ERC1155Burnable, ERC1155Supply {

    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PLAYER_ROLE = keccak256("PLAYER_ROLE");

    uint256 registrationFee;
    mapping(uint256 => string) public idToName;

    constructor() ERC1155("{id}") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        _grantRole(PLAYER_ROLE, msg.sender);
        idToName[0] =  "GOLD";
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri); // Use IPFS CID for new items
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
    }

    function burn(address account, uint256 id, uint256 amount)
        public
        onlyRole(BURNER_ROLE)
        override
    {
        _burn(account, id, amount);
    }

    function burnBatch(address from, uint256[] memory ids, uint256[] memory amounts)
        public
        onlyRole(BURNER_ROLE)
        override
    {
        _burnBatch(from, ids, amounts);
    }

    function newMinter(address minter)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _grantRole(MINTER_ROLE, minter);
    }

    function newBurner(address burner)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _grantRole(BURNER_ROLE, burner);
    } 

    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool) 
    {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    // *-*-*-*-*-*-*-*-* // 
    
    // Used for registering a new item name to an ID 
    function newItem(uint256 id, string memory name)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            compareStrings(idToName[id], name) && !compareStrings(idToName[id], ""),
            "Item already exists!"
        );

        idToName[id] = name;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}