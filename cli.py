# A command line interface for interacting with the march madness bracket!
from teams import TEAMS
from matchups import MATCHUPS

def main():
    quarters = list()
    final_four = list()
    championship = 0
    for region in ["South", "West", "East", "Midwest"]:
        q = pickQuarter(region, TEAMS, MATCHUPS)
        quarters.append(q)
    # Final 4 - Game 1
    ff_south = TEAMS[quarters[0][13]]
    ff_west = TEAMS[quarters[1][13]]
    final_four.append(makePick("Final Four", a, b, quarters[0][13], quarters[1][13]))
    # Final 4 - Game 2
    ff_east = TEAMS[quarters[0][13]]
    ff_midwest = TEAMS[quarters[1][13]]
    final_four.append(makePick("Final Four", a, b, quarters[2][13], quarters[3][13]))
    # Championship
    champ_A = TEAMS[final_four[0]]
    champ_B = TEAMS[final_four[1]]
    championship = makePick("Championship", a, b, final_four[0], final_four[1])


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


def makePick(region, a, b, i, j):
    pick = 0
    while (pick not in [str(i), str(j)]):
        pick = raw_input("%s: %s (%s) vs %s (%s) - pick seed of winner: "%(region, a, i, b, j))
    return pick

if __name__ == "__main__":
    main()
