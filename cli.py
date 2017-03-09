# A command line interface for interacting with the march madness bracket!
from bracket import makeBracket
from contract import getStartTx, getBracketTx
def main():
    (q, final_four, championship) = makeBracket()
    start_tx = getStartTx()
    bracket_tx = getBracketTx(q[0], q[1], q[2], q[3], final_four, championship)
    print bracket_tx



if __name__ == "__main__":
    main()
