contract mockOVM_GenericCrossDomainMessenger {
    address public xDomainMessageSender;

    event SentMessage(
        address _sender,
        address _target,
        bytes _message,
        uint256 _gasLimit
    );

    function sendMessage(
        address _target,
        bytes memory _message,
        uint32 _gasLimit
    )
        public
    {
        emit SentMessage(
            msg.sender,
            _target,
            _message,
            _gasLimit
        );
    }

    function relayMessage(
        address _sender,
        address _target,
        bytes memory _message,
        uint256 _gasLimit
    )
        public
    {
        xDomainMessageSender = _sender;
        (bool success, ) = _target.call{gas: _gasLimit}(_message);
        require(success, "Cross-domain message call reverted. Did you set your gas limit high enough?");
        xDomainMessageSender = address(0);
    }
}
