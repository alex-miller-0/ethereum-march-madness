# Functions to form a raw, unsigned transaction payload.
import sha3

def getBracketTx(south, west, east, midwest, final_four, championship):
    header = sha3.keccak_256('setBracket(uint8[15],uint8[15],uint8[15],uint8[15],uint8[4],uint8[2])')
    data = header.hexdigest()[:8]
    for region in [south, west, east, midwest]:
        for pick in region:
            data += str(pick).zfill(8)
    for i in range(2):
        for j in range(2):
            data += str(final_four[i][j]).zfill(8)
    data += str(championship[0]).zfill(8)
    data += str(championship[1]).zfill(8)
    return data

def getCheckTx(addr):
    header = sha3.keccak_256('getCurrentScore(address)')
    data = header.hexdigest()[:8]
    data += addr
    return data
