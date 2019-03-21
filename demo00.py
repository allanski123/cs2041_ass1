#!/usr/bin/python3

# start off with a simple demo..
# prints naughts and pattern
# tests multiple while loops, if, elsif, else statements
# print(), sys.stdout.write(), int()

import sys

sys.stdout.write("First Demo Script\n")
num = int("5")

i = 0
while i < num: 
    j = 0
    while j < num:
        if j % 2 == 0 && i % 2 == 0:
            print("O", end='')
        elif j % 2 != 0 && i % 2 != 0:
            print("O", end='')
        else:
            print("X", end='')
        j += 1
    i += 1
    print()
