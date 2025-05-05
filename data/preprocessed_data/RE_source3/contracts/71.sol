contract acl{

    enum Role {
        USER,
        ORACLE,
        ADMIN
    }

    mapping (address=> Role) permissions;

    constructor() public {
        permissions[msg.sender] = Role(2);
    }

    function setRole(uint8 rolevalue,address entity)external check(2){
        permissions[entity] = Role(rolevalue);
    }

    function getRole(address entity)public view returns(Role){
        return permissions[entity];
    }

    modifier check(uint8 role) {
        require(uint8(getRole(msg.sender)) == role);
        _;
    }
}

// File: contracts/ERC721BasicToken.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev edited verison of Open Zepplin implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 * @dev edited _mint & isApprovedOrOwner modifiers
 */
