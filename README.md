# March Madness (on Ethereum)

Welcome to March, my favorite month! I love this month because here in America we host the best sports tournament in the world - the [NCAA Basketball Tournament](https://en.wikipedia.org/wiki/NCAA_Division_I_Men's_Basketball_Tournament) (a.k.a. March Madness).

64 college basketball teams from all across America go head-to-head in a single-elimination fight to the top. Well, technically there are 68 teams, but I'll get into that later.

The week before the tournament starts, it is customary here in America to fill out brackets with your predictions of who will win each game. It's a lot of picks (59 games) and the probability of guessing every game correctly is almost zero (there are upsets every year). Within a pool, the person who picks the most winners is crowned the champion. There are many strategies ranging from picking your favorite teams to always picking the highest seed (usually a bad idea in big pools) to consulting a [probability distribution](http://bracketodds.cs.illinois.edu/2015%20Omega.pdf). Which is the best strategy? Who knows.

As a huge [Arizona basketball](http://www.arizonawildcats.com/schedule.aspx?schedule=368) fan I thought it would be fun to put my Ethereum skills to the test and deploy a bracket pool to the Ethereum network.

If you would like to participate (**buy in is 0.5ETH**), read on!

Since this happens pretty quickly, I don't have time to put out a fully functioning website, so I'm going to force you to use Python.

### Tournament background

The tournament starts promptly at 12:00 PM EST on Thursday, March 16 (unix = 1489683600) and concludes with the championship game at 9:00 PM EST on Monday, April 3 (ending roughly unix = 1491282000).

You may fill out your bracket any time before the start date and may submit your bracket for review roughly 15 minutes after the championship ends.

### How it works

You will fill out a bracket (See: Fill out a bracket) and submit this to the blockchain along with the buy-in cost of 0.5 ETH. You must submit your bracket **before** the tournament commences (i.e. before 1489683600). You may only submit one bracket per Ethereum address.

Points are allocated as follows:
* 1 point for each correctly chosen team in round of 64, 32, and sweet 16
* 2 points for each correctly chosen team in the final four
* 4 points for the correctly chosen champion

*NOTE: Each game is scored independently of others, so as long as you pick the winning team, it doesn't matter if you incorrectly picked their opponent.*

Once the tournament ends, you have **72 hours** to submit your score for review (ending at 1491530400). The highest score wins. If there is a tie, the pool is distributed evenly across winners.

I will be responsible for submitting the **oracle bracket** (that is, the winners of the tournament). I will submit it once the championship ends, at which point you can start comparing your bracket. Yes yes I know, you need to trust me to be an arbiter of the truth. If you're uncomfortable with that, you are welcome to re-deploy this contract and start your own pool.

*NOTE: I have built an escape hatch so if something goes wrong, I will notify everyone with instructions on how to withdraw your 0.5 ETH. Sorry in advance if that happens.*

### Fees

There are no fees. 100% of the pool goes to the winner[s].

### Getting started

Open up your command line, navigate to a new directory, and type the following:

`git clone https://github.com/alex-miller-0/ethereum-march-madness.git`

### Fill out a bracket

It's probably a good idea to fill out a bracket visually first. You can find one [here](http://www.ncaa.com/news/basketball-men/bracket-beat/march-madness-printable-ncaa-tournament-bracket) or [here](http://www.cbssports.com/college-basketball/ncaa-tournament/brackets/games/). You will only need this for reference later.

I guess I should address the issue of there being 68 teams. For some reason, the tournament has the 4 weakest teams each play one game ahead of the tournament to vie for a 16 seed (the worst seed). The following day, the two winning teams must face the top 2 teams in the tournament (both 1 seeds). Historically, no 16 seed has ever beaten a 1 seed, so I'm going to neglect these extra 4 teams and mark them simply as 16 seeds (i.e. whoever wins a spot in the round of 64). *Hint: you might want to pick the 1 seed for these matchups.*

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
2. In the `Amount to send` field, put **0.5ETH**.
3. In the `gasLimit` put `1000000` (it shouldn't use this much and the remainder will be refunded).
4. Click `Advanced: Add Data` and paste the `data` parameter from before.
5. Send the transaction!

You have now created your bracket!

### Checking your score

Once the tournament starts, you can check your score by opening up this directory again and running:

```
python checkScore.py <your address>
```

### Submitting your score

If you think your score is high, you will need to submit a new transaction to claim it. Use the following as your data parameter:

```
dc26824f
```

(fun fact: this is the first 4 bytes of the [keccak_256](https://emn178.github.io/online-tools/keccak_256.html) hash of the function you are calling, which is `scoreBracket()`)

Submit a transaction like you did before (e.g. using MEW). Put a gasLimit of `2000000` this time (again, this is probably higher than you need).
