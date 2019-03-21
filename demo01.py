#!/usr/bin/python3

# tests user input -> sys.stdin.readline()
# tests arrays, range with 1 arg, range with variable
# single line if statement, append(), continue
# array indexing

import sys

print("Enter a number between 100 and 200")
user_num = int(sys.stdin.readline())

i = 0
even_arr = []

for i in range(user_num):
    if i % 2 == 0: even_arr.append(i); i += 1
    if i % 2 != 0: i += 1; continue

print("The length of even_arr is ", len(even_arr))
for i in range(user_num/2):
    print(even_arr[i], " is even")
