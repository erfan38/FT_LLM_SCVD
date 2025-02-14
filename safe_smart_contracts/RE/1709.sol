contract HD is ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    address public governance;
    address public pendingGov;

    mapping (address => bool) public minters;

    event NewPendingGov(address oldPendingGov, address newPendingGov);

    event NewGov(address oldGov, address newGov);

    // Modifiers
    modifier onlyGov() {
        require(msg.sender == governance, "HUB-Token: !governance");
        _;
    }

    constructor () public ERC20Detailed("HUB.finance", "HD", 18, 21000000 * 10 ** 18) {
        governance = tx.origin;
    }

    /** 
     * Minte Token for Account
     * @param _account minter
     * @param _amount amount
     */
    function mint(address _account, uint256 _amount) public {
        require(minters[msg.sender], "HUB-Token: !minter");
        _mint(_account, _amount);
    }
    
    /** 
     * Add minter
     * @param _minter minter
     */
    function addMinter(address _minter) public onlyGov {
        minters[_minter] = true;
    }
    
    /** 
     * Remove minter
     * @param _minter minter
     */
    function removeMinter(address _minter) public onlyGov {
        minters[_minter] = false;
    }

    /** 
     * Set new governance
     * @param _pendingGov the new governance
     */
    function setPendingGov(address _pendingGov)
        external
        onlyGov
    {
        address oldPendingGov = pendingGov;
        pendingGov = _pendingGov;
        emit NewPendingGov(oldPendingGov, _pendingGov);
    }

    /** 
     * lets msg.sender accept governance
     */
    function acceptGov()
        external {
        require(msg.sender == pendingGov, "HUB-Token: !pending");
        address oldGov = governance;
        governance = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldGov, governance);
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= cap(), "HUB-Token: Cap exceeded");
        }
    }
}