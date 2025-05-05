contract Haltable is System {
	bool public halted;
	
	 

	modifier stopInEmergency {
		if (halted) {
			error('Haltable: stopInEmergency function called and 