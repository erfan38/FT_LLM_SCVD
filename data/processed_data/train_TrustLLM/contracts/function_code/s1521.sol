function settleFunding() override external whenNotPaused { for (uint i = 0; i < amms.length; i++) { amms[i].settleFunding(); } }
