contract DSCache is DSValue
{
    uint128 public zzz;
//  from DSValue:
//  bool    has;
//  bytes32 val;
    function peek() constant returns (bytes32, bool) {
        return (val, has && now < zzz);
    }
    function read() constant returns (bytes32) {
        var (wut, has) = peek();
        assert(now < zzz);
        assert(has);
        return wut;
    }
    function prod(bytes32 wut, uint128 Zzz) note auth {
        zzz = Zzz;
        poke(wut);
    }
    // from DSValue:
    // function poke(bytes32 wut) note auth {
    //     val = wut;
    //     has = true;
    // }
    // function void() note auth { // unset the value
    //     has = false;
    // }

}

