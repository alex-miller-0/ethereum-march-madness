# Functions to form a raw, unsigned transaction payload.
import sha3

def getStartTx(region, picks):
    start_bracket = sha3.keccak_256('startBracket()')
    return start_bracket

def getBracketTx(south, west, east, midwest, final_four, championship):
    quarter = sha3.keccak_256('setBracket(uint8[15],uint8[15],uint8[15],uint8[15],uint8[4],uint8[2])')
    data = quarter + region.zfill(8)
    for region in [south, west, east, midwest]:
        for pick in region:
            data += pick.zfill(8)
    for i in range(2):
        for j in range(2):
            data += final_four[i][j].zfill(8)
    data += championship[0].zfill(8)
    data += championship[1].zfill(8)
    return data
