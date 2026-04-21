contract DSBaseActor {
   /*
   Copyright 2016 Nexus Development, LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   */

    bool _ds_mutex;
    modifier mutex() {
        assert(!_ds_mutex);
        _ds_mutex = true;
        _;
        _ds_mutex = false;
    }
	
    function tryExec( address target, bytes calldata, uint256 value)
			mutex()
            internal
            returns (bool call_ret)
    {
		/** @dev Requests new StatiCoins be made for a given address
          * @param target where the ETH is sent to.
          * @param calldata
          * @param value
          * @return True if ETH is transfered
        */
        return target.call.value(value)(calldata);
    }
	
    function exec( address target, bytes calldata, uint256 value)
             internal
    {
        assert(tryExec(target, calldata, value));
    }
}

/** @title canFreeze. */
