contract MultiSend is Ownable {
	using SafeMath for uint256;


	Peculium public pecul; // token Peculium
	address public peculAdress = 0x3618516f45cd3c913f81f9987af41077932bc40d; // The address of the old Peculium 