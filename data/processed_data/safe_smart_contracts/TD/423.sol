contract EtheremonDataBase is EtheremonEnum {
    function getMonsterObj(uint64 _objId) constant public returns(uint64 objId, uint32 classId, address trainer, uint32 exp, uint32 createIndex, uint32 lastClaimIndex, uint createTime);
    function getMonsterDexSize(address _trainer) constant public returns(uint);
    function getElementInArrayType(ArrayType _type, uint64 _id, uint _index) constant public returns(uint8);
    
    function addMonsterObj(uint32 _classId, address _trainer, string _name)  public returns(uint64);
    function addElementToArrayType(ArrayType _type, uint64 _id, uint8 _value) public returns(uint);
}

interface EtheremonRankData {
    function setPlayer(address _trainer, uint64 _a0, uint64 _a1, uint64 _a2, uint64 _s0, uint64 _s1, uint64 _s2) external returns(uint32 playerId);
}

