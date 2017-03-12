pragma solidity ^0.4.8;

contract Madness {
  address public owner;
  uint COST = 500000000000000000; // 0.5 ETH
  uint STOP_TIME = 1489680000; // 3/16/17 11AM EST (Time the tournament starts)
  uint FINAL_TIME = 1491541200; // 4/7/17 12AM EST (~72 hours after the tournament ends)
  bool public ABORTED = false;

  // The bracket is comprised of a bunch of integer slots.
  // The integer supplied indicates the seed number of the predicted winner.
  // Within each bracket, games are defined starting from the round of 64 and going down.
  struct bracket {
    // There are four quarter brackets (East, West, North, South) in a fullBracket
    uint8[14] south;
    uint8[14] west;
    uint8[14] east;
    uint8[14] midwest;

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
  uint public pool;

  // This is input by the owner of the contract. It may be disputed for 24 hours.
  bracket oracleBracket;

  // Keep a tally of the leading score and the leaders
  uint8 public leadingScore;
  address[] public leaders;

  // Set the msg.sender as the owner.
  function Madness() {
    owner = msg.sender;
  }

  //=========================================================
  // BRACKET API FUNCTIONS
  //=========================================================

  /**
   * Setup a bracket!
   * param uint8[14] south - picks in south quarter
   * param uint8[14] west - picks in west quarter
   * param uint8[14] east - picks in east quarter
   * param uint8[14] midwest - picks in midwest quarter
   * param uint8[4]  final_four - picks for final Four [[region, seed], ]
   * param uint8[2]  championship - picks for champ [region, seed]

   */
  function setBracket(uint8[14] south, uint8[14] west, uint8[14] east,
  uint8[14] midwest, uint8[4] finalFour, uint8[2] championship) payable
  public returns (bool) {

    if (msg.sender == owner) {
      // Owner can update oracleBracket any time and for free
      oracleBracket.south = south;
      oracleBracket.west = west;
      oracleBracket.east = east;
      oracleBracket.midwest = midwest;
      oracleBracket.finalFour[0] = [finalFour[0], finalFour[1]];
      oracleBracket.finalFour[1] = [finalFour[2], finalFour[3]];
      oracleBracket.championship = championship;
      // Refund if owner accidentally sent ether
      if (msg.value > 0) {
        if (!msg.sender.send(msg.value)) { throw; }
      }
    } else {
      // Users may only submit/update brackets before the tournament starts.
      if (now > STOP_TIME) { return false; }
      // Refunds and checks on msg.value
      if (userBrackets[msg.sender].started && msg.value > 0) { if (!msg.sender.send(msg.value)) { throw; } }
      else if (!userBrackets[msg.sender].started && msg.value < COST) { return false; }
      else if (msg.value > COST) { if (!msg.sender.send(COST - msg.value)) { throw; } }
      // Increase the pool if this is the first time the user has submitted
      if (!userBrackets[msg.sender].started) {
        pool += COST;
        userBrackets[msg.sender].started = true;
      }
      // Update the data regardless
      userBrackets[msg.sender].south = south;
      userBrackets[msg.sender].west = west;
      userBrackets[msg.sender].east = east;
      userBrackets[msg.sender].midwest = midwest;
      userBrackets[msg.sender].finalFour[0] = [finalFour[0], finalFour[1]];
      userBrackets[msg.sender].finalFour[1] = [finalFour[2], finalFour[3]];
      userBrackets[msg.sender].championship = championship;
    }
    return true;
  }

  /**
   * Calculate the score of the bracket and put the user in the leaderboard
   * if appropriate.
   */
  function scoreBracket() public returns (bool) {
    uint8 score = getCurrentScore(msg.sender);
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

  function issueWinner() public returns (bool) {
    if (now > FINAL_TIME) {
      if (leaders.length == 1) { if (!leaders[0].send(pool)) { throw; } }
      else {
        // Hopefully this rounds down... ¯\_(ツ)_/¯
        uint slice = pool / leaders.length;
        for (uint i=0; i<leaders.length; i++) {
          if (!leaders[i].send(slice)) { throw; }
        }
      }
      return true;
    }
    return false;
  }

  // If something went wrong, users can withdraw their funds here
  function withdraw() public returns (bool) {
    if (ABORTED && userBrackets[msg.sender].started) {
      userBrackets[msg.sender].started = false;
      if (!msg.sender.send(COST)) { throw; }
    }
    return true;
  }

  function abort() public returns (bool) {
    if (msg.sender == owner) { ABORTED = true; }
    return true;
  }

  //=========================================================
  // GETTERS
  //=========================================================

  /**
   * Get a user's bracket for a given region
   * param  address user - address of the user in question (can be anyone)
   * param  uint    region  - 1=south, 2=west, 3=east, 4=midwest
   * return uint8[14]       - the user's 15 winners for the quarter bracket
   */
  function getQuarter(address user, uint8 region) public constant returns (uint8[14]) {
    if (region == 1) {
      return userBrackets[user].south;
    } else if (region == 2) {
      return userBrackets[user].west;
    } else if (region == 3) {
      return userBrackets[user].east;
    } else if (region == 4) {
      return userBrackets[user].midwest;
    }
  }

  /**
   * Get a user's picks for the final four and championship
   * param  address user - address of the user in question (can be anyone)
   * return uint8[6]     - [ff_game1_winner_region, ff_game1_winner_seed,
   *                           ff_game2_winner_region, ff_game2_winner_seed,
   *                           champ_winner_region, champ_winner_seed]
   *                          (region - 1=south, 2=west, 3=east, 4=midwest)
   */
  function getFinals(address user) public constant returns (uint8[6]) {
    return [
      userBrackets[user].finalFour[0][0],
      userBrackets[user].finalFour[0][1],
      userBrackets[user].finalFour[1][0],
      userBrackets[user].finalFour[1][1],
      userBrackets[user].championship[0],
      userBrackets[user].championship[1]
    ];
  }

  /**
   * Get the oracle's bracket for a given region
   * param  uint8    region  - 1=south, 2=west, 3=east, 4=midwest
   * return uint8[14]       - the user's 15 winners for the quarter bracket
   */
  function getOracleQuarter(uint8 region) public constant returns (uint8[14]) {
    if (region == 1) {
      return oracleBracket.south;
    } else if (region == 2) {
      return oracleBracket.west;
    } else if (region == 3) {
      return oracleBracket.east;
    } else if (region == 4) {
      return oracleBracket.midwest;
    }
  }

  /**
   * Get the oracle's picks for the final four and championship
   * return uint8[6]     - [ff_game1_winner_region, ff_game1_winner_seed,
   *                         ff_game2_winner_region, ff_game2_winner_seed,
   *                         champ_winner_region, champ_winner_seed]
   *                        (region - 1=south, 2=west, 3=east, 4=midwest)
   */
  function getOracleFinals() public constant returns (uint8[6]) {
    return [oracleBracket.finalFour[0][0],oracleBracket.finalFour[0][1],oracleBracket.finalFour[1][0],oracleBracket.finalFour[1][1],oracleBracket.championship[0],oracleBracket.championship[1]];
  }

  /**
   * Get the current score of the user
   * param  address user  - address of the user
   * return uint8         - score so far, as compared to the oracle
   *                           (0 if the user doesn't have a bracket)
   */
  function getCurrentScore(address user) public constant returns (uint8) {
    uint8 score = 0;
    if (userBrackets[user].started) { score += 1; }
    for (uint i=0; i<14; i++) {
      if (oracleBracket.south[i] > 0 && userBrackets[user].south[i] == oracleBracket.south[i]) { score += 1; }
      if (oracleBracket.west[i] > 0 && userBrackets[user].west[i] == oracleBracket.west[i]) { score += 1; }
      if (oracleBracket.east[i] > 0 && userBrackets[user].east[i] == oracleBracket.east[i]) { score += 1; }
      if (oracleBracket.midwest[i] > 0 && userBrackets[user].midwest[i] == oracleBracket.midwest[i]) { score += 1; }

      if (
        i < 2
        && oracleBracket.finalFour[0][i] > 0
        && userBrackets[user].finalFour[i][0] == oracleBracket.finalFour[i][0]
        && userBrackets[user].finalFour[i][1] == oracleBracket.finalFour[i][1]
      ) { score += 2; }

      // Championship prediction is worth 4 points
      if (
        i == 0
        && userBrackets[user].championship[0] == oracleBracket.championship[0]
        && oracleBracket.championship[0] > 0
        && userBrackets[user].championship[1] == oracleBracket.championship[1]
        && oracleBracket.championship[1] > 0
      ) { score += 4; }
    }

    return score;
  }

}
