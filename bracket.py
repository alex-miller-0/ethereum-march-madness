from teams import TEAMS
from matchups import MATCHUPS
import pickle

def makeBracket():
    quarters = list()
    final_four = list()
    championship = 0
    for region in ["South", "West", "East", "Midwest"]:
       q = pickQuarter(region, TEAMS, MATCHUPS)
       quarters.append(q)

    # Final 4 - Game 1
    ff_south = TEAMS["South"][str(quarters[0][13])]
    ff_west = TEAMS["West"][str(quarters[1][13])]
    ff1_winner = makeFFPick(ff_south, ff_west, quarters[0][13], quarters[1][13])
    if ff1_winner == ff_south:
        final_four.append([0, quarters[0][13]])
    else:
        final_four.append([1, quarters[1][13]])
    # Final 4 - Game 2
    ff_east = TEAMS["East"][str(quarters[2][13])]
    ff_midwest = TEAMS["Midwest"][str(quarters[3][13])]
    ff2_winner = makeFFPick(ff_east, ff_midwest, quarters[2][13], quarters[3][13])
    if ff1_winner == ff_south:
        final_four.append([2, quarters[2][13]])
    else:
        final_four.append([3, quarters[3][13]])
    # Championship
    _regionA = final_four[0][0]
    _regionB = final_four[1][0]
    regionA = "South"
    if _regionA == 1:
        regionA = "West"
    regionB = "East"
    if _regionB == 3:
        regionB == "Midwest"
    champ_A = TEAMS[regionA][str(final_four[0][1])]
    champ_B = TEAMS[regionB][str(final_four[1][1])]
    winner = makeFFPick(champ_A, champ_B, final_four[0][1], final_four[1][1])
    if winner == champ_A:
        championship = [_regionA, final_four[0][1]]
    else:
        championship = [_regionB, final_four[1][1]]
    # Save picks for later
    savePickle((quarters, final_four, championship), "picks")

    return (quarters, final_four, championship)

def pickQuarter(region, teams, matchups):
    picks = list()
    # Round of 64
    for i in [1, 8, 5, 4, 6, 3, 7, 2]:
        j = matchups[str(i)]
        a = teams[region][str(i)]
        b = teams[region][str(j)]
        picks.append(makePick(region, a, b, i, j))
    # Round of 32
    for k in range(1, 5):
        i = picks[k*2 - 2]
        j = picks[k*2 - 1]
        a = teams[region][str(i)]
        b = teams[region][str(j)]
        picks.append(makePick(region, a, b, i, j))
    # Sweet 16 - Game 1
    i = picks[len(picks) - 4]
    j = picks[len(picks) - 3]
    a = teams[region][str(i)]
    b = teams[region][str(j)]
    picks.append(makePick(region, a, b, i, j))
    # Sweet 16 - Game 2
    i = picks[len(picks) - 2]
    j = picks[len(picks) - 1]
    a = teams[region][str(i)]
    b = teams[region][str(j)]
    picks.append(makePick(region, a, b, i, j))
    return picks

def makePick(region, a, b, i, j):
    pick = 0
    while (pick not in [str(i), str(j)]):
        pick = raw_input("%s: %s (%s) vs %s (%s) - pick seed of winner: "%(region, a, i, b, j))
    return pick

def makeFFPick(a, b, i, j):
    pick = 0
    while (pick not in ["a", "b"]):
        pick = raw_input("Final Four: [a] %s (%s) vs [b] %s (%s) - pick a or b: "%(a, i, b, j))
    if pick == "a":
        return a
    return b

'''
Save a pickle file with a dictionary
@param {dict} d       - dictionary with your data
@param {string} name  - name of the file you want to save (will be suffixed
                        with .pkl and will be a hidden file)
'''
def savePickle(d, name):
    with open('.%s.pkl'%name, 'wb') as handle:
        pickle.dump(d, handle, protocol=pickle.HIGHEST_PROTOCOL)
