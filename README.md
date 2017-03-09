# March Madness (on Ethereum)

**Contract address: **

Welcome to March, my favorite month! I love this month because here in America we host the best sports tournament in the world - the [NCAA Basketball Tournament](https://en.wikipedia.org/wiki/NCAA_Division_I_Men's_Basketball_Tournament) (a.k.a. March Madness).

## Background

64 college basketball teams from all across America go head-to-head in a single-elimination fight to the top. Well, technically there are 68 teams, but I'll get into that later.

The week before the tournament starts, it is customary here in America to fill out brackets with your predictions of who will win each game. It's a lot of picks (59 games) and the probability of guessing every game correctly is almost zero (there are upsets every year). Within a pool, the person who picks the most winners is crowned the champion. There are many strategies ranging from picking your favorite teams to always picking the highest seed (usually a bad idea in big pools) to consulting a [probability distribution](http://bracketodds.cs.illinois.edu/2015%20Omega.pdf). Which is the best strategy? Who knows.

As a huge [Arizona basketball](http://www.arizonawildcats.com/schedule.aspx?schedule=368) fan I thought it would be fun to put my Ethereum skills to the test and deploy a bracket pool to the Ethereum network.

If you would like to participate (**buy in is 0.5ETH**), read on!

Since I have a real job at ConsenSys and I just recently though of this, I don't have time to put out a fully functioning website, so I'm going to force you to use Python.

### Time-frame

The tournament starts promptly at 12:00 PM EST on Thursday, March 16 (unix = 1489683600) and concludes with the championship game at 9:00 PM EST on Monday, April 3 (ending roughly 3 hours later, at unix = 1491282000).

## How to participate

You will fill out a bracket and submit this to the blockchain along with the buy-in cost of 0.5 ETH. You must submit your bracket **before** the tournament commences (i.e. before 1489683600). You may only submit one bracket per Ethereum address.

Points are allocated as follows:
* 1 point for each correctly chosen team in round of 64, 32, and sweet 16
* 2 points for each correctly chosen team in the final four
* 4 points for the correctly chosen champion

*NOTE: Each game is scored independently of others, so as long as you pick the winning team, it doesn't matter if you incorrectly picked their opponent.*

I will be responsible for submitting the **oracle bracket** (that is, the winners of the each game). I will add to it each day once games are concluded and you may compare your score whenever you'd like (more on this later).

Shortly after the tournament ends (give me ~15 min), you will have **72 hours** to submit your score for review (ending at 1491530400). When you submit your score (discussed later), you will be added as the leader if your score is higher than the current leader score. The highest score wins. If there is a tie, the pool is distributed evenly across winners.

And before you ask, yes I know that you need to trust me to be an arbiter of the truth. If you're uncomfortable with that, you are welcome to re-deploy this contract and start your own pool.

*NOTE: I have built an escape hatch so if something goes wrong, I will notify everyone with instructions on how to withdraw your 0.5 ETH. Sorry in advance if that happens.*

### Fees

There are no fees. 100% of the pool goes to the winner[s].

## Creating a bracket

Before doing anything, you will need this repo. Open up your command line, navigate to a new directory, and type the following:

```
git clone https://github.com/alex-miller-0/ethereum-march-madness.git
```

### Fill out a bracket

It's probably a good idea to fill out a bracket visually first. You can find one [here](http://www.ncaa.com/news/basketball-men/bracket-beat/march-madness-printable-ncaa-tournament-bracket) or [here](http://www.cbssports.com/college-basketball/ncaa-tournament/brackets/games/). You will only need this for reference later.

I guess I should address the issue of there being 68 teams. For some reason, the tournament has the 4 weakest teams each play an extra game ahead of the tournament to vie for a 16 seed (the worst seed). The following day, the two winning teams must face the top 2 teams in the tournament (both 1 seeds). Historically, no 16 seed has ever beaten a 1 seed, so I'm going to neglect these extra 4 teams and mark them simply as 16 seeds (i.e. whoever wins a spot in the round of 64). *Hint: you might want to pick the 1 seed for these matchups.*

### Transcribe your picks into this command line tool

To boot up the tool:

```
python cli.py
```

If you run into problems, make sure you have [python installed](http://docs.python-guide.org/en/latest/starting/installation/) along with the following packages: `pysha3, glob, pickle` (the latter 2 should come with your python installation). To install a python package, make sure you have [pip](https://pip.pypa.io/en/stable/installing/) installed and run `pip install <packagename>` (you may need to include `sudo` at the front if that doesn't work).

Once the program in running, it will ask you for your picks for all 59 games. After you're done with that, you will see something like the following:

```
Cool. You've made your picks. Now we need to put it on the blockchain.


Setup your bracket:
--------------------
Please copy the following string and send a raw transaction with it as the data parameter:
### YOU MUST SEND 0.5ETH WITH THIS TRANSACTION ###

61422a670000000100000008000000050000000400000006000000030000000700000002000000010000000500000006000000020000000100000001000000010000000800000005000000040000000600000003000000070000000200000008000000050000000600000007000000080000000800000001000000080000000500000004000000060000000300000007000000020000000800000005000000060000000200000005000000020000000100000008000000050000000400000006000000030000000700000002000000010000000500000006000000070000000100000007000000000000000100000002000000020000000000000001
```

That hex string at the bottom is what you will need to copy and paste into your Ethereum wallet in the `data` field.

### Sending your Ethereum transaction with MEW

If you're using My Ether Wallet:

1. Copy the `data` parameter provided to you in the previous step and go to `Send Ether & Tokens`.
2. In the `Amount to send` field, put `0.5ETH`.
3. In the `gasLimit` put `2000000` (it shouldn't use this much and the remainder will be refunded).
4. Click `Advanced: Add Data` and paste the `data` parameter from before.
5. Send the transaction!

### Sending your Ethereum transaction locally

If you have a node running locally, you can do cURL requests:

```
curl --data '{"method":"personal_unlockAccount","params":["<your address>","<your password>",null],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
curl --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"to":"<contract address>","gas":"0x1E8480","value":"0x6F05B59D3B20000","from": "<your address>","data":"<string you got>"}],"id":1}'  -H "Content-Type: application/json" -X POST localhost:8545
```

You have now created your bracket!

## During the tournament: Checking your score

Once the tournament starts, you can check your score by opening up a web3 console and doing the following:

```
var addr = "<contract address>";
var contract = web3.eth.contract([{"constant":false,"inputs":[],"name":"setAbort","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"pool","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"abort","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"user","type":"address"}],"name":"getQuarterScore","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"south","type":"uint8[15]"},{"name":"west","type":"uint8[15]"},{"name":"east","type":"uint8[15]"},{"name":"midwest","type":"uint8[15]"},{"name":"finalFour","type":"uint8[4]"},{"name":"championship","type":"uint8[2]"}],"name":"setBracket","outputs":[{"name":"","type":"bool"}],"payable":true,"type":"function"},{"constant":false,"inputs":[],"name":"issueWinner","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"leadingScore","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"leaders","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"user","type":"address"}],"name":"getCurrentScore","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"ABORTED","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"scoreBracket","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"user","type":"address"}],"name":"getFinalScores","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"}])
var instance = contract.at(addr)

// Check your score
instance.getScore(<your address>)

// Check the highest score
instance.leadingScore()

// Get the leader(s)
instance.leaders()

// Get the total pool (in wei)
instance.pool()
```

## After the tournament: Submitting your score

Once the championship ends, you have 72 hours to submit your score if you think it is high enough to win (note: you can't win if you don't submit!). You will need to submit a new transaction to claim it. Use the following as your data parameter:

```
dc26824f
```

(fun fact: this is the first 4 bytes of the [keccak_256](https://emn178.github.io/online-tools/keccak_256.html) hash of the function you are calling, which is `scoreBracket()`)

### Using MEW

If you're using My Ether Wallet:

1. Go to `Send Ether & Tokens`.
2. In the `Amount to send` field, put `0`.
3. In the `gasLimit` put `2000000` (it shouldn't use this much and the remainder will be refunded).
4. Click `Advanced: Add Data` and use `dc26824f` for the `data` parameter.
5. Send the transaction!

### Using a local node:

If you have a node running locally:

```
curl --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"to":"<contract address>","gas":"0x1E8480","from": "<your address>","data":"0xdc26824f"}],"id":1}'  -H "Content-Type: application/json" -X POST localhost:8545
```

## Ending the pool

After the 72 hour submission period, I will call the `issueWinner()` function, which will send all funds to the winner(s) of the bracket pool. I will subsequently announce the winner and the winnings on Reddit.

Good luck!
