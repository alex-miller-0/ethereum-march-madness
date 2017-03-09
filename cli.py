# A command line interface for interacting with the march madness bracket!
from bracket import makeBracket
from contract import getBracketTx
from glob import glob
import pickle

def main():
    print '\n\nWelcome to March Madness 2017 - Ethereum edition\n=======================================\n'
    pickles = glob('.*.pkl')
    if '.picks.pkl' in pickles:
        go = raw_input('Looks like you have a complete bracket saved. Do you want to use that? (1=yes 0=no) ')
        if go == 0:
            (q, final_four, championship) = makeBracket()
        else:
            (q, final_four, championship) = loadPickle('picks')
    else:
        (q, final_four, championship) = makeBracket()

    bracket_tx = getBracketTx(q[0], q[1], q[2], q[3], final_four, championship)
    print "\n--------------------\nCool. You've made your picks. Now we need to put it on the blockchain."
    print '\n\nSetup your bracket:\n--------------------'
    print 'Please copy the following string and send a raw transaction with it as the data parameter:'
    print '### YOU MUST SEND 0.5ETH WITH THIS TRANSACTION ###\n\n%s\n\n'%bracket_tx




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
