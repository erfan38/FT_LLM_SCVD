contract NameableMixin {

    // String manipulation is expensive in the EVM; keep things short.

    uint constant minimumNameLength = 1;
    uint constant maximumNameLength = 25;
    string constant nameDataPrefix = "NAME:";

    /// @notice Check if `_name` is a reasonable choice of name.
    /// @return True if-and-only-if `_name_` meets the criteria
    /// below, or false otherwise:
    ///   - no fewer than 1 character
    ///   - no more than 25 characters
    ///   - no characters other than:
    ///     - "roman" alphabet letters (A-Z and a-z)
    ///     - western digits (0-9)
    ///     - "safe" punctuation: ! ( ) - . _ SPACE
    ///   - at least one non-punctuation character
    /// Note that we deliberately exclude characters which may cause
    /// security problems for websites and databases if escaping is
    /// not performed correctly, such as < > " and '.
    /// Apologies for the lack of non-English language support.
    function validateNameInternal(string _name) constant internal
    returns (bool allowed) {
        bytes memory nameBytes = bytes(_name);
        uint lengthBytes = nameBytes.length;
        if (lengthBytes < minimumNameLength ||
            lengthBytes > maximumNameLength) {
            return false;
        }
        bool foundNonPunctuation = false;
        for (uint i = 0; i < lengthBytes; i++) {
            byte b = nameBytes[i];
            if (
                (b >= 48 && b <= 57) || // 0 - 9
                (b >= 65 && b <= 90) || // A - Z
                (b >= 97 && b <= 122)   // a - z
            ) {
                foundNonPunctuation = true;
                continue;
            }
            if (
                b == 32 || // space
                b == 33 || // !
                b == 40 || // (
                b == 41 || // )
                b == 45 || // -
                b == 46 || // .
                b == 95    // _
            ) {
                continue;
            }
            return false;
        }
        return foundNonPunctuation;
    }

    // Extract a name from bytes `_data` (presumably from `msg.data`),
    // or throw an exception if the data is not in the expected format.
    // 
    // We want to make it easy for people to name things, even if
    // they're not comfortable calling functions on contracts.
    //
    // So we allow names to be sent to the fallback function encoded
    // as message data.
    //
    // Unfortunately, the way the Ethereum Function ABI works means we
    // must be careful to avoid clashes between message data that
    // represents our names and message data that represents a call
    // to an external function - otherwise:
    //   a) some names won't be usable;
    //   b) small possibility of a phishing attack where users are
    //     tricked into using certain names which cause an external
    //     function call - e.g. if the data sent to the 