contract Helper_PrecompileCaller is Helper_SimpleProxy {
    function callPrecompile(
        address _precompile,
        bytes memory _data
    )
        public
    {
        if (msg.sender == owner) {
            makeExternalCall(_precompile, _data);
        } else {
            makeExternalCall(target, msg.data);
        }
    }

    function callPrecompileAbi(
        address _precompile,
        bytes memory _data
    )
        public
        returns (
            bytes memory
        )
    {

        bool success;
        bytes memory returndata;
        if (msg.sender == owner) {
            (success, returndata) = _precompile.call(_data);
        } else {
            (success, returndata) = target.call(msg.data);
        }
        require(success, "Precompile call reverted");
        return returndata;
    }

    function getL1MessageSender(
        address _precompile,
        bytes memory _data
    )
        public
        returns (
            address
        )
    {
        callPrecompile(_precompile, _data);
        return address(0); // unused: silence compiler
    }
}
