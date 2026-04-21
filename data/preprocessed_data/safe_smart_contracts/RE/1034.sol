contract oneWrite {  
	//  Adds modifies that allow one function to be called only once
	//Copyright (c) 2017 GenkiFS
  bool written = false;
  function oneWrite() {
	/** @dev Constuctor, make sure written=false initally
	*/
    written = false;
  }
  modifier LockIfUnwritten() {
    if (written){
        _;
    }
  }
  modifier writeOnce() {
    if (!written){
        written=true;
        _;
    }
  }
}

/** @title pricerControl. */
