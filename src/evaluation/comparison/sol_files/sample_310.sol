pragma solidity ^0.8.0;
event MetadataSet(bytes metadata);


function _setMetadata(bytes memory metadata) internal {
emit MetadataSet(metadata);
}