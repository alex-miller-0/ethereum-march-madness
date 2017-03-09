pragma solidity ^0.4.8;


contract Madness {
  address owner;
  uint COST = 100000000000000000; // 0.1 ETH
  uint STOP_TIME = 1489012283; // Time the tournament starts
  uint FINAL_TIME = 1489012283; // 48 hours after the tournament ends
  bool ABORTED = false;

  // The bracket is comprised of a bunch of integer slots.
  // The integer supplied indicates the seed number of the predicted winner.
  // Within each bracket, games are defined starting from the round of 64 and going down.
  struct bracket {
    // There are four quarter brackets (East, West, North, South) in a fullBracket
    uint8[15] south;
    uint8[15] west;
    uint8[15] east;
    uint8[15] midwest;

    // Index is 0=South, 1=West, 2=East, 3=Midwest
    uint8[4] quarterBracketScore;
    // The final four is 2 games (South-West and North-East)
    // The first dimension is the game, the second dimension is [region, seed]
    // Region is 1=South, 2=West, 3=East, 4=Midwest
    // E.g. to predict a 7 seed winner from the West:
    //    finalFour[0] = [2, 5]
    uint8[2][2] finalFour;
    // The championship is the final game. Again it is [region, seed]
    // So to predict a 6-east winner, championship = [3, 6]
    uint8[2] championship;
    uint8 totalScore;
    bool started;
  }

  // Users may submit brackets here
  mapping (address => bracket) userBrackets;

  // The pool of funds (in wei)
  uint pool;

  // This is input by the owner of the contract. It may be disputed for 24 hours.
  bracket oracleBracket;

  // Keep a tally of the leading score and the leaders
  uint8 leadingScore;
  address[] leaders;

  // Set the msg.sender as the owner.
  function Madness() {
    owner = msg.sender;
  }

  //=========================================================
  // BRACKET API FUNCTIONS
  //=========================================================

  /**
   * Setup a bracket!
   * param {uint8[15]} south - picks in south quarter
   * param {uint8[15]} west - picks in west quarter
   * param {uint8[15]} east - picks in east quarter
   * param {uint8[15]} midwest - picks in midwest quarter
   * param {uint8[4]}  final_four - picks for final Four [[region, seed], ]
   * param {uint8[2]}  championship - picks for champ [region, seed]

   */
  function setBracket(uint8[15] south, uint8[15] west, uint8[15] east,
  uint8[15] midwest, uint8[4] finalFour, uint8[2] championship) payable
  public returns (bool) {

    if (msg.sender == owner) {
      oracleBracket.south = south;
      oracleBracket.west = west;
      oracleBracket.east = east;
      oracleBracket.midwest = midwest;
      oracleBracket.finalFour[0] = [finalFour[0], finalFour[1]];
      oracleBracket.finalFour[1] = [finalFour[2], finalFour[3]];
      oracleBracket.championship = championship;
    }

    if (now > STOP_TIME) { return false; }
    if (!userBrackets[msg.sender].started) {
      if (msg.value < COST) { return false; }
      if (msg.value > COST) { if (!msg.sender.send(COST - msg.value)) { throw; } }
      pool += COST;
      userBrackets[msg.sender].started = true;
    }
    userBrackets[msg.sender].south = south;
    userBrackets[msg.sender].west = west;
    userBrackets[msg.sender].east = east;
    userBrackets[msg.sender].midwest = midwest;
    userBrackets[msg.sender].finalFour[0] = [finalFour[0], finalFour[1]];
    userBrackets[msg.sender].finalFour[1] = [finalFour[2], finalFour[3]];
    userBrackets[msg.sender].championship = championship;
    return true;
  }

  /**
   * Calculate the score of the bracket and put the user in the leaderboard
   * if appropriate.
   */
  function scoreBracket() public returns (bool) {
    uint8 score = getCurrentScore();

    // Check the bracket against the leaderboard
    userBrackets[msg.sender].totalScore = score;
    if (score > leadingScore) {
      leadingScore = score;
      leaders = [msg.sender];
    } else if (score == leadingScore) {
      // If the sender ties, add him to the leaderboard.
      // NOTE: This could be problematic if there are many leaders, but let's hope it isn't?
      for (uint j=0; j<leaders.length; j++) {
        // Make sure the sender is not already among the leaders.
        if (msg.sender == leaders[j]) { return true; }
      }
      leaders.push(msg.sender);
    }

    return true;
  }

  //=========================================================
  // Payout functions
  //=========================================================

  function issueWinner() {
    if (now > FINAL_TIME) {
      if (leaders.length == 1) { if (!leaders[0].send(pool)) { throw; } }
      else {
        // Hopefully this rounds down...
        uint slice = pool / leaders.length;
        for (uint i=0; i<leaders.length; i++) {
          if (!leaders[i].send(slice)) { throw; }
        }
      }
    }
  }

  function abort() {
    // If something went wrong, users can withdraw their funds
    if (ABORTED && userBrackets[msg.sender].started) {
      if (!msg.sender.send(COST)) { throw; }
    }
  }

  function setAbort() {
    if (msg.sender == owner) {
      if (!ABORTED) { ABORTED = true; }
      ABORTED = false;
    }
  }

  //=========================================================
  // GETTERS
  //=========================================================

  function getCurrentScore() public constant returns (uint8) {
    uint8 score = getQuarterScore(msg.sender);
    score += getFinalScores(msg.sender);
    return score;
  }

  function getQuarterScore(address user) public constant returns (uint8) {
    uint8 score = 0;
    for (uint i=0; i<15; i++) {
      if (userBrackets[user].south[i] == oracleBracket.south[i]) { score += 1; }
      if (userBrackets[user].west[i] == oracleBracket.west[i]) { score += 1; }
      if (userBrackets[user].east[i] == oracleBracket.east[i]) { score += 1; }
      if (userBrackets[user].midwest[i] == oracleBracket.midwest[i]) { score += 1; }
    }
    return score;
  }

  function getFinalScores(address user) public constant returns (uint8) {
    uint8 score = 0;
    for (uint i=0; i<4; i++) {
      // Include all quarterBracketScores
      score += userBrackets[user].quarterBracketScore[i];
      // Add final four scores (worth 2 points for correct prediction)
      if (i < 2) {
        if (userBrackets[user].finalFour[i][0] == oracleBracket.finalFour[i][0]
          && userBrackets[user].finalFour[i][1] == oracleBracket.finalFour[i][1]) {
          score += 2;
        }
      }
    }
    // Championship prediction is worth 4 points
    if (userBrackets[user].championship[0] == oracleBracket.championship[0]
      && userBrackets[user].championship[1] == oracleBracket.championship[1]) {
      score += 4;
    }
  }

  /**
   * Get a user's quarter bracket
   * param  address user - address of user. 0x0 for oracle bracket
   * param  uint8 region - 1=South, 2=West, 3=East, 4=Midwest
   */
  function getQuarterBracket(address user, uint region) public constant returns (uint8[15]){
    if (user == 0x0) {
      if (region == 1) { return oracleBracket.south; }
      else if (region == 2) { return oracleBracket.west; }
      else if (region == 3) { return oracleBracket.east; }
      else if (region == 4) { return oracleBracket.midwest; }
    } else {
      if (region == 1) { return userBrackets[msg.sender].south; }
      else if (region == 2) { return userBrackets[msg.sender].west; }
      else if (region == 3) { return userBrackets[msg.sender].east; }
      else { return userBrackets[msg.sender].midwest; }
    }
  }

  /**
   * Get a user's finalFour + championship brackets
   * param  address user - address of user. 0x0 for oracle bracket
   */
  function getQuarterBracket(address user) public constant returns (uint8[6]){
    uint8[6] memory toReturn;
    if (user == 0x0) {
      toReturn[0] = oracleBracket.finalFour[0][0];
      toReturn[1] = oracleBracket.finalFour[0][1];
      toReturn[2] = oracleBracket.finalFour[1][0];
      toReturn[3] = oracleBracket.finalFour[1][1];
      toReturn[4] = oracleBracket.championship[0];
      toReturn[5] = oracleBracket.championship[1];
    } else {
      toReturn[0] = userBrackets[user].finalFour[0][0];
      toReturn[1] = userBrackets[user].finalFour[0][1];
      toReturn[2] = userBrackets[user].finalFour[1][0];
      toReturn[3] = userBrackets[user].finalFour[1][1];
      toReturn[4] = userBrackets[user].championship[0];
      toReturn[5] = userBrackets[user].championship[1];
    }
    return toReturn;
  }



}
