with open('/tmp/test-log.txt') as f:
    [print(line) for line in f.readlines()]