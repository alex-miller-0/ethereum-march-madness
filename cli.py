# A command line interface for interacting with the march madness bracket!
from bracket import makeBracket
from contract import getStartTx, getBracketTx
from glob import glob
import pickle

def main():
    pickles = glob('.*.pkl')
    if '.picks.pkl' in pickles:
        go = raw_input('Looks like you have a complete bracket saved. Do you want to delete that and make a new one? (1=yes 0=no) ')
        if go == 1:
            (q, final_four, championship) = makeBracket()
        else:
            (q, final_four, championship) = loadPickle('picks')
    else:
        (q, final_four, championship) = makeBracket()

    start_tx = getStartTx()
    print '\n\n1. Start your bracket:\n--------------------'
    print 'Please copy the following string and send a raw transaction with it as the data parameter:\n\n%s'%start_tx
    x = raw_input('\n\nWhen the transaction above has been mined, press enter to continue.')
    bracket_tx = getBracketTx(q[0], q[1], q[2], q[3], final_four, championship)
    print '\n\n2. Set your picks:\n--------------------'
    print 'Please copy the following string and send a raw transaction with it as the data parameter:\n\n%s\n\n'%bracket_tx




'''
Load a dictionary from a pickle file
@param {string} name   - filename of .pkl hidden file
@returns {dict}        - dictionary with your data
'''
def loadPickle(name):
    with open('.%s.pkl'%name, 'rb') as handle:
        b = pickle.load(handle)
        return b

if __name__ == "__main__":
    main()
