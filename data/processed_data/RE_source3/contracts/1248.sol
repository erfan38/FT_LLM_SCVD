contract HumanStandardTokenFactory {

    mapping(address => address[]) public created;
    mapping(address => bool) public isHumanToken; //verify without having to do a bytecode check.
    bytes public humanStandardByteCode;

    function HumanStandardTokenFactory() {
      //upon creation of the factory, deploy a HumanStandardToken (parameters are meaningless) and store the bytecode provably.
      address verifiedToken = createHumanStandardToken(10000, "Verify Token", 3, "VTX");
      humanStandardByteCode = codeAt(verifiedToken);
    }

    //verifies if a 