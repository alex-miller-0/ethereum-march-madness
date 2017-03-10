# Functions to form a raw, unsigned transaction payload.
import sha3

def getBracketTx(south, west, east, midwest, final_four, championship):
    header = sha3.keccak_256('setBracket(uint8[14],uint8[14],uint8[14],uint8[14],uint8[4],uint8[2])')
    data = header.hexdigest()[:8]
    print south
    print west
    print east
    print midwest
    for region in [south, west, east, midwest]:
        for pick in region:
            h = hex(int(pick))[2]
            data += str(h).zfill(64)
            # data += str(pick).zfill(64)
    for i in range(2):
        for j in range(2):
            h = hex(int(final_four[i][j]))[2]
            data += str(h).zfill(64)
            # data += str(final_four[i][j]).zfill(64)
    data += str(hex(int(championship[0]))[2]).zfill(64)
    data += str(hex(int(championship[1]))[2]).zfill(64)
    # data += str(championship[0]).zfill(64)
    # data += str(championship[1]).zfill(64)
    return '0x' + data

def getCheckTx(addr):
    header = sha3.keccak_256('getCurrentScore(address)')
    data = header.hexdigest()[:8]
    data += addr
    return '0x' + data
