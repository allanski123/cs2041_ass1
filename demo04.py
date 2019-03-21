#!/usr/bin/python3

import sys

# a bit of everything (sub 0 - 4) 

### sub 0 ###
print("Welcome to demo 5")

### sub 1 ###
# arithmetic operators
a = 15
b = 4

print(a + b)
print(a - b)
print(a * b)
print(a / b)
print(a // b)
print(a % b)
print(a ** b)

# assignment
c = 10
d = c 
e = d 
print(e)

### sub 2 ###
# single line if statements
if a == 15 and b == 4: print("logical operators")
if a > b: print("comparison operators")

# bitwise operators
print(a & b)
print(a | b)
print(a << b)

# break and continue + single line while loops
i = 0 
while i < 10: break
while i < 10: i += 1; continue

### sub 3 ###
# multi-line nested while/if statements
while i < 10: 
    j = 0
    while j < 10:
        if j == 2:
            print(j)
        elif j == 5:
            print(i)
        j += 1
    i += 1

# range() for 1 or 2 args + multi-line for loops
for i in range(10):
    print(i)
    print("testing")
    for j in range(2, 10):
        print(j)

# sys.stdout.write() && sys.stdin.readline() && int()
sys.stdout.write("long test")
print(int(sys.stdin.readline()))

### sub 4 ###

# lists (perl arrays)
arr = []
arr.append("hello")
arr.append(" world")
print(arr[0], arr[1])
arr.pop(1)
arr.pop()
print(len(arr) )

# len applied to string
print(len("hello"))

# dicts including keys
dict = {"key1" : 10, "key2" : 20}
dict_key = dict.keys()
print(dict_key)

# sorted
for i in sorted(dict.keys()):
    print(i)

# print formatting %
print("%s" % "finally finished testing!")
