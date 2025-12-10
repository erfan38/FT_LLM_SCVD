contract GasToken2 {
    //////////////////////////////////////////////////////////////////////////
    // RLP.sol
    // Due to some unexplained bug, we get a slightly different bytecode if 
    // we use an import, and are then unable to verify the code in Etherscan
    //////////////////////////////////////////////////////////////////////////
    
    uint256 constant ADDRESS_BYTES = 20;
    uint256 constant MAX_SINGLE_BYTE = 128;
    uint256 constant MAX_NONCE = 256**9 - 1;

    // count number of bytes required to represent an unsigned integer
    function count_bytes(uint256 n) constant internal returns (uint256 c) {
        uint i = 0;
        uint mask = 1;
        while (n >= mask) {
            i += 1;
            mask *= 256;
        }

        return i;
    }

    function mk_contract_address(address a, uint256 n) constant internal returns (address rlp) {
        /*
         * make sure the RLP encoding fits in one word:
         * total_length      1 byte
         * address_length    1 byte
         * address          20 bytes
         * nonce_length      1 byte (or 0)
         * nonce           1-9 bytes
         *                ==========
         *                24-32 bytes
         */
        require(n <= MAX_NONCE);

        // number of bytes required to write down the nonce
        uint256 nonce_bytes;
        // length in bytes of the RLP encoding of the nonce
        uint256 nonce_rlp_len;

        if (0 < n && n < MAX_SINGLE_BYTE) {
            // nonce fits in a single byte
            // RLP(nonce) = nonce
            nonce_bytes = 1;
            nonce_rlp_len = 1;
        } else {
            // RLP(nonce) = [num_bytes_in_nonce nonce]
            nonce_bytes = count_bytes(n);
            nonce_rlp_len = nonce_bytes + 1;
        }

        // [address_length(1) address(20) nonce_length(0 or 1) nonce(1-9)]
        uint256 tot_bytes = 1 + ADDRESS_BYTES + nonce_rlp_len;

        // concatenate all parts of the RLP encoding in the leading bytes of
        // one 32-byte word
        uint256 word = ((192 + tot_bytes) * 256**31) +
                       ((128 + ADDRESS_BYTES) * 256**30) +
                       (uint256(a) * 256**10);

        if (0 < n && n < MAX_SINGLE_BYTE) {
            word += n * 256**9;
        } else {
            word += (128 + nonce_bytes) * 256**9;
            word += n * 256**(9 - nonce_bytes);
        }

        uint256 hash;

        assembly {
            let mem_start := mload(0x40)        // get a pointer to free memory
            mstore(0x40, add(mem_start, 0x20))  // update the pointer

            mstore(mem_start, word)             // store the rlp encoding
            hash := sha3(mem_start,
                         add(tot_bytes, 1))     // hash the rlp encoding
        }

        // interpret hash as address (20 least significant bytes)
        return address(hash);
    }
    
    //////////////////////////////////////////////////////////////////////////
    // Generic ERC20
    //////////////////////////////////////////////////////////////////////////

    // owner -> amount
    mapping(address => uint256) s_balances;
    // owner -> spender -> max amount
    mapping(address => mapping(address => uint256)) s_allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Spec: Get the account balance of another account with address `owner`
    function balanceOf(address owner) public constant returns (uint256 balance) {
        return s_balances[owner];
    }

    function internalTransfer(address from, address to, uint256 value) internal returns (bool success) {
        if (value <= s_balances[from]) {
            s_balances[from] -= value;
            s_balances[to] += value;
            Transfer(from, to, value);
            return true;
        } else {
            return false;
        }
    }

    // Spec: Send `value` amount of tokens to address `to`
    function transfer(address to, uint256 value) public returns (bool success) {
        address from = msg.sender;
        return internalTransfer(from, to, value);
    }

    // Spec: Send `value` amount of tokens from address `from` to address `to`
    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        address spender = msg.sender;
        if(value <= s_allowances[from][spender] && internalTransfer(from, to, value)) {
            s_allowances[from][spender] -= value;
            return true;
        } else {
            return false;
        }
    }

    // Spec: Allow `spender` to withdraw from your account, multiple times, up
    // to the `value` amount. If this function is called again it overwrites the
    // current allowance with `value`.
    function approve(address spender, uint256 value) public returns (bool success) {
        address owner = msg.sender;
        if (value != 0 && s_allowances[owner][spender] != 0) {
            return false;
        }
        s_allowances[owner][spender] = value;
        Approval(owner, spender, value);
        return true;
    }

    // Spec: Returns the `amount` which `spender` is still allowed to withdraw
    // from `owner`.
    // What if the allowance is higher than the balance of the `owner`?
    // Callers should be careful to use min(allowance, balanceOf) to make sure
    // that the allowance is actually present in the account!
    function allowance(address owner, address spender) public constant returns (uint256 remaining) {
        return s_allowances[owner][spender];
    }

    //////////////////////////////////////////////////////////////////////////
    // GasToken specifics
    //////////////////////////////////////////////////////////////////////////

    uint8 constant public decimals = 2;
    string constant public name = "Gastoken.io";
    string constant public symbol = "GST2";

    // We build a queue of nonces at which child contracts are stored. s_head is
    // the nonce at the head of the queue, s_tail is the nonce behind the tail
    // of the queue. The queue grows at the head and shrinks from the tail.
    // Note that when and only when a 