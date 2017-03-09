import sys

def main(addr):
    print addr


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print 'Please include your address, e.g. python getScore.py 0x...A'
    main(sys.argv[2])
