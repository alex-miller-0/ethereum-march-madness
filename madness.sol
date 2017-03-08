contract Madness {
  address owner;
  uint COST = 100000000000000000; // 0.1 ETH
  uint STOP_TIME = 1489012283; // Time the tournament starts

  // The bracket is comprised of a bunch of integer slots.
  // The integer supplied indicates the seed number of the predicted winner.
  // Within each bracket, games are defined starting from the round of 64 and going down.
  struct bracket {
    // There are four quarter brackets (East, West, North, South) in a fullBracket
    // Indices: 0=South, 1=West, 2=East, 3=Midwest
    uint8[4][15] quarterBracket;
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
   * Begin a bracket as a user (before the expiration time).
   * The cost is 0.1 Ether.
   */
  function startBracket() public returns (bool) {
    if (now > STOP_TIME) { return false; }
    if (!userBrackets[msg.sender].started) {
      if (msg.value < COST) { return false; }
      if (msg.value > COST) { msg.sender.send(COST - msg.value); }
      pool += COST;
      userBrackets[msg.sender].started = true;
    }
    return true;
  }

  /**
   * Update a quarterBracket as a user
   * @param {uint8} region - 1=South, 2=West, 3=East, 4=Midwest
   * @param {uint8[15]} games - winning seed (1-16) for each game, starting at the top
   */
  function setQuarterBracket(uint8 region, uint8[15] games) public returns (bool) {
    if (msg.sender == owner) {
      oracleBracket.quarterBracket[region-1] = games;
    } else {
      userBrackets[msg.sender].quarterBracket[region-1] = games;
    }
    return true;
  }

  /**
   * Update the finalFour and championship predictions.
   * @param {uint[4]} finalFour - [finalFour[0][0], finalFour[0][1], finalFour[1][0], finalFour[1][1]
   * @param {uint[2]} championship - [region, seed]
   */
  function setFinals(uint[4] finalFour, uint[2] championship) public returns (bool) {
    if (msg.sender == owner) {
      oracleBracket.finalFour[0] = [finalFour[0], finalFour[1]];
      oracleBracket.finalFour[1] = [finalFour[2], finalFour[3]];
      oracleBracket.championship = championship;
    } else {
      userBrackets[msg.sender].finalFour[0] = [finalFour[0], finalFour[1]];
      userBrackets[msg.sender].finalFour[1] = [finalFour[2], finalFour[3]];
      userBrackets[msg.sender].championship = championship;
    }
    return true;
  }


  /**
   * Score a particular quarter bracket for the message sender.
   * Bracket must be stared.
   * @param  {uint8} region - 1=South, 2=West, 3=East, 4=Midwest
   */
  function scoreQuarterBracket(uint8 region) public returns (bool) {
    if (!userBrackets[msg.sender].started) { return false; }
    uint8 score = 0;
    for (uint i=0; i<15; i++) {
      if (userBrackets[msg.sender].quarterBracket[region-1][i] == oracleBracket.quarterBracket[region-1][i]) {
        score += 1;
      }
    }
    userBrackets[msg.sender].quarterBracketScore[region-1] = score;
    return true;
  }

  /**
   * Calculate the final score once all four quarterBracket scores have been calculated.
   * Bracket must be started.
   */
  function finishScore() public returns (bool) {
    if (!userBrackets[msg.sender].started) { return false; }
    uint8 score = 0;
    for (uint i=0; i<4; i++) {
      // Include all quarterBracketScores
      score += userBrackets[msg.sender].quarterBracketScore[i];
      // Add final four scores (worth 2 points for correct prediction)
      if (i < 2) {
        if (userBrackets[msg.sender].finalFour[i][0] == oracleBracket.finalFour[i][0]
          && userBrackets[msg.sender].finalFour[i][1] == oracleBracket.finalFour[i][1]) {
          score += 2;
        }
      }
    }
    // Championship prediction is worth 4 points
    if (userBrackets[msg.sender].championship[0] == oracleBracket.championship[0]
      && userBrackets[msg.sender].championship[1] == oracleBracket.championship[1]) {
      score += 4;
    }

    // Check the bracket against the leaderboard
    userBrackets[msg.sender].totalScore = score;
    if (score > leadingScore) {
      leadingScore = score;
      leaders = [msg.sender];
    } else if (score == leadingScore) {
      // If the sender ties, add him to the leaderboard.
      // NOTE: This could be problematic if there are many leaders, but let's hope it isn't?
      for (uint i=0; i<leaders.length; i++) {
        // Make sure the sender is not already among the leaders.
        if (msg.sender == leaders[i]) { return true; }
      }
      leaders.push(msg.sender);
    }

    return true;
  }

  //=========================================================
  // GETTERS
  //=========================================================

  /**
   * Get a user's quarter bracket
   * @param  {address} user - address of user. 0x0 for oracle bracket
   * @param  {uint8} region - 1=South, 2=West, 3=East, 4=Midwest
   */
  function getQuarterBracket(address user, uint region) public constant returns (uint8[15]){
    if (user == 0x0) { return oracleBracket.quarterBracket[region-1]; }
    else { return userBrackets[user].quarterBracket[region-1]; }
  }

  /**
   * Get a user's finalFour + championship brackets
   * @param  {address} user - address of user. 0x0 for oracle bracket
   */
  function getQuarterBracket(address user) public constant returns (uint8[6]){
    uint8[6] toReturn;
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
