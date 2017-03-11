# March Madness (on Ethereum)

**Technical Warning**: This process requires some working technical understanding of Ethereum. If you don't have that, this may be a good opportunity to learn! If you can't get something to work, feel free to open up an issue in this repo and I will try to give you some assistance if I have time.

## Contract address: 0x2dcbe558103caa847d5580604272321284cc312a

### Updates
**3/12 9AM PST: Contract deployed! Brackets closing at 11:00 AM EST on Thursday, March 16**

Welcome to March, my favorite month! I love this month because here in America we host the best sports tournament on the planet - the [NCAA Basketball Tournament](https://en.wikipedia.org/wiki/NCAA_Division_I_Men's_Basketball_Tournament) (a.k.a. March Madness).

## Background

64 college basketball teams from all across America go head-to-head in a single-elimination fight to the top. Well, technically there are 68 teams, but I'll get into that later.

The week before the tournament starts, it is customary here in America to fill out brackets with your predictions of who will win each game. It's a lot of picks (59 games) and the probability of guessing every game correctly is almost zero (there are upsets every year). Within a bracket pool (usually comprised of your friends and family), the person who picks the most winners is crowned the champion. There are many strategies ranging from picking your favorite teams to always picking the highest seed (usually a bad idea in big pools) to consulting a [probability distribution](http://bracketodds.cs.illinois.edu/2015%20Omega.pdf). Which is the best strategy? Who knows.

As a huge [Arizona basketball](http://www.arizonawildcats.com/schedule.aspx?schedule=368) fan I thought it would be fun to put my Ethereum skills to the test and deploy a bracket pool to the Ethereum network.

If you would like to participate (**buy in is 0.5ETH**), read on!

Since I have a real job at ConsenSys and I just recently though of this, I don't have time to put out a fully functioning website, so I'm going to force you to use Python.

### Time-frame

The tournament starts promptly at 11:00 AM EST on Thursday, March 16 (unix = 1489680000) and concludes with the championship game at 9:00 PM EST on Monday, April 3 (ending roughly 3 hours later, at unix = 1491541200).

## How to participate

You will fill out a bracket and submit this to the blockchain along with the buy-in cost of 0.5 ETH. You must submit your bracket **before** the tournament commences (i.e. before 1489680000). You may only submit one bracket per Ethereum address.

Points are allocated as follows:
* 1 point for submitting a braket
* 1 point for each correctly chosen team in round of 64, 32, and sweet 16
* 2 points for each correctly chosen team in the final four
* 4 points for the correctly chosen champion

This means the highest possible score is 65.

*NOTE: Each game is scored independently of others, so as long as you pick the winning team, it doesn't matter if you incorrectly picked their opponent.*

I will be responsible for submitting the **oracle bracket** (that is, the winners of the each game). I will add to it each day once games are concluded and you may compare your score whenever you'd like (more on this later).

Shortly after the tournament ends (give me ~15 min to update the oracle), you will have **72 hours** to submit your score for review (ending at 1491541200). When you submit your score (discussed later), you will be added as the leader if your score is higher than the current leader score. The highest score wins. If there is a tie, the pool is distributed evenly across winners.

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

0x58b72327000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001
```

That hex string at the bottom is what you will need to copy and paste into your Ethereum wallet in the `data` field.

### Sending your Ethereum transaction with MEW

If you're using My Ether Wallet:

1. Go to `Send Ether & Tokens`
2. Set the `To Address` field to `0x2dcbe558103caa847d5580604272321284cc312a`
3. In the `Amount to send` field, put `0.5ETH`.
4. In the `gasLimit` put `2000000` (it shouldn't use this much and the remainder will be refunded).
5. Click `Advanced: Add Data` and paste the hex string from before into the `Data` field.
6. Sign and send the transaction!

### Sending your Ethereum transaction locally

If you have a node running locally, you can do cURL requests:

```
curl --data '{"method":"personal_unlockAccount","params":["<your address>","<your password>",null],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
curl --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"to":"0x2dcbe558103caa847d5580604272321284cc312a","gas":"0x1E8480","value":"0x6F05B59D3B20000","from": "<your address>","data":"<string you got>"}],"id":1}'  -H "Content-Type: application/json" -X POST localhost:8545
```

You have now created your bracket!

## During the tournament: Checking your score

Once the tournament starts, you can check your score by opening up a web3 console and doing the following:

```
var addr = "0x2dcbe558103caa847d5580604272321284cc312a";
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
0xdc26824f
```

(fun fact: this is the first 4 bytes of the [keccak_256](https://emn178.github.io/online-tools/keccak_256.html) hash of the function you are calling, which is `scoreBracket()`)

Make sure you do this from the same address you used to make the bracket!

### Using MEW

If you're using My Ether Wallet:

1. Go to `Send Ether & Tokens`.
2. In the `Amount to send` field, put `0`.
3. In the `gasLimit` put `2000000` (it shouldn't use this much and the remainder will be refunded).
4. Click `Advanced: Add Data` and use `0xdc26824f` for the `Data` parameter.
5. Send the transaction!

### Using a local node:

If you have a node running locally:

```
curl --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"to":"0x2dcbe558103caa847d5580604272321284cc312a","gas":"0x1E8480","from": "<your address>","data":"0xdc26824f"}],"id":1}'  -H "Content-Type: application/json" -X POST localhost:8545
```

## Declaring a winner

After the 72 hour submission period, I will call the `issueWinner()` function, which will send all funds to the winner(s) of the bracket pool. I will subsequently announce the winner and the winnings on Reddit.

Good luck!
