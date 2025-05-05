contract DSMath {

	// Copyright (C) 2015, 2016, 2017  DappHub, LLC

	// Licensed under the Apache License, Version 2.0 (the "License").
	// You may not use this file except in compliance with the License.

	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
    
	// /*
    // uint128 functions (h is for half)
    //  */

    function hmore(uint128 x, uint128 y) constant internal returns (bool) {
        return x>y;
    }

    function hless(uint128 x, uint128 y) constant internal returns (bool) {
        return x<y;
    }

    function hadd(uint128 x, uint128 y) constant internal returns (uint128 z) {
        require((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) constant internal returns (uint128 z) {
        require((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        require(y == 0 ||(z = x * y)/ y == x);
    }

    function hdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = x / y;
    }

    function hmin(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x <= y ? x : y;
    }

    function hmax(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x >= y ? x : y;
    }

    // /*
    // int256 functions
    //  */

    /*
    WAD math
     */
    uint64 constant WAD_Dec=18;
    uint128 constant WAD = 10 ** 18;

    function wmore(uint128 x, uint128 y) constant internal returns (bool) {
        return hmore(x, y);
    }

    function wless(uint128 x, uint128 y) constant internal returns (bool) {
        return hless(x, y);
    }

    function wadd(uint128 x, uint128 y) constant  returns (uint128) {
        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) constant   returns (uint128) {
        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) constant returns (uint128 z) {
        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) constant internal  returns (uint128 z) {
        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) constant internal  returns (uint128) {
        return hmin(x, y);
    }

    function wmax(uint128 x, uint128 y) constant internal  returns (uint128) {
        return hmax(x, y);
    }

    function cast(uint256 x) constant internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }
	
}
 
/** @title I_minter. */
