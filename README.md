# ethereum-march-madness

Welcome to my favorite month (March). I love this month because here in America we have the best sports tournament in the world - the NCAA Basketball Tournament (a.k.a. March Madness).

64 college basketball teams from all across America go head-to-head in a single-elimination fight to the top. Well, technically there are 68 teams, but I'll get into that later.

The week before the tournament starts, it is customary here in America to fill out brackets with your predictions of who will win each game. It's a lot of picks (59 games) and the probability of guessing every game correctly is almost zero (there are upsets every year). Within a pool, the person who picks the most winners is crowned the champion. There are many strategies ranging from picking your favorite teams to always picking the highest seed (hint: don't do this) to consulting a [probability distribution](http://bracketodds.cs.illinois.edu/2015%20Omega.pdf). Which is the best strategy? Who knows.

As a huge [Arizona basketball](http://www.arizonawildcats.com/schedule.aspx?schedule=368) fan I thought it would be fun to put my Ethereum skills to the test and deploy a bracket pool to the Ethereum network.

If you would like to participate (**buy in is 0.5ETH**), read on!

Since this happens pretty quickly, I don't have time to put out a fully functioning website, so I'm going to force you to use Python.

### Clone this repo

Open up your command line, navigate to a new directory, and type the following:

`git clone https://github.com/alex-miller-0/ethereum-march-madness.git`

### Fill out a bracket

It's probably a good idea to fill out a bracket visually first. You can find one [here](http://www.ncaa.com/news/basketball-men/bracket-beat/march-madness-printable-ncaa-tournament-bracket) or [here](http://www.cbssports.com/college-basketball/ncaa-tournament/brackets/games/). You will only need this for reference later.

### Transcribe your picks into this command line tool

To boot up the tool:

`python cli.py`

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

That hex string at the bottom is what you will need to copy and paste into your Ethereum wallet in the `data` field. (Note, you will need to include **500000000000000000 wei** (0.5 ETH) as the `value` param).

### Sending your Ethereum transaction with MEW

If you're using My Ether Wallet:

1. Copy the `data` parameter provided to you in the previous step and go to `Send Ether & Tokens`.
2. In the `Amount to send` field, put 0.5ETH.
3. In the `gasLimit` put `1000000` (it shouldn't use this much and the remainder will be refunded).
4. Click `Advanced: Add Data` and paste the `data` parameter from before.
5. Send the transaction!

You have now created your bracket!

### Checking your score

Once the tournament starts, you can check your score by opening up this directory again and running:

`python checkScore.py <your address>`

### Submitting your score

If you think your score is high, you will need to submit a new transaction to claim it. Use the following as your data parameter:

```
dc26824f
```

(fun fact: this is the first 4 bytes of the [keccak_256](https://emn178.github.io/online-tools/keccak_256.html) hash of the function you are calling, which is `scoreBracket()`)

Submit a transaction like you did before. Put a gasLimit of `2000000` this time (again, this is probably higher than you need).
