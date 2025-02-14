contract Parameters {

  /*
   * Time Constants
   *
   * Phases are, in this order: 
   *  earlyContribution (defined by end time)
   *  pause
   *  donation round0 (defined by start and end time)
   *  pause
   *  donation round1 (defined by start and end time)
   *  pause
   *  finalization (defined by start time, ends manually)
   *  done
   */

  // The start of round 0 is set to 2017-01-17 19:00 of timezone Europe/Zurich
  uint public constant round0StartTime      = 1484676000; 
  
  // The start of round 1 is set to 2017-05-17 19:00 of timezone Europe/Zurich
  // TZ="Europe/Zurich" date -d "2017-05-17 19:00" "+%s"
  uint public constant round1StartTime      = 1495040400; 
  
  // Transition times that are defined by duration
  uint public constant round0EndTime        = round0StartTime + 6 weeks;
  uint public constant round1EndTime        = round1StartTime + 6 weeks;
  uint public constant finalizeStartTime    = round1EndTime   + 1 weeks;
  
  // The finalization phase has a dummy end time because it is ended manually
  uint public constant finalizeEndTime      = finalizeStartTime + 1000 years;
  
  // The maximum time by which donation round 1 can be delayed from the start 
  // time defined above
  uint public constant maxRoundDelay     = 270 days;

  // The time for which donation rounds remain open after they reach their 
  // respective targets   
  uint public constant gracePeriodAfterRound0Target  = 1 days;
  uint public constant gracePeriodAfterRound1Target  = 0 days;

  /*
   * Token issuance
   * 
   * The following configuration parameters completely govern all aspects of the 
   * token issuance.
   */
  
  // Tokens assigned for the equivalent of 1 CHF in donations
  uint public constant tokensPerCHF = 10; 
  
  // Minimal donation amount for a single on-chain donation
  uint public constant minDonation = 1 ether; 
 
  // Bonus in percent added to donations throughout donation round 0 
  uint public constant round0Bonus = 200; 
  
  // Bonus in percent added to donations at beginning of donation round 1  
  uint public constant round1InitialBonus = 25;
  
  // Number of down-steps for the bonus during donation round 1
  uint public constant round1BonusSteps = 5;
 
  // The CHF targets for each of the donation rounds, measured in cents of CHF 
  uint public constant millionInCents = 10**6 * 100;
  uint public constant round0Target = 1 * millionInCents; 
  uint public constant round1Target = 20 * millionInCents;

  // Share of tokens eventually assigned to DFINITY Stiftung and early 
  // contributors in % of all tokens eventually in existence
  uint public constant earlyContribShare = 22; 
}

// FDC.sol

