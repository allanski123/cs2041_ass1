#!/usr/bin/python3

# easy bubble sort implementation
# takes in numbers (1 on each line) and sorts them
# e.g. 
#   5
#   9
#   1
#   2

# output -> 1
#           2
#           5
#           9  

import sys

list = sys.stdin.readlines()
print("List before sorting")
for i in list:
    print(i, end='')

sorted_list = sorted(list)

for i in range(len(list)):
    for j in range(len(list) -i - 1):
        if list[j] > list[j + 1]:
            temp = list[j]
            list[j] = list[j + 1]
            list[j + 1] = temp

if list == sorted_list:
    print("Successful bubble sort")
    print("Sorted list is:")
    for i in sorted_list:
        print(i, end='')
else:
    print("Failed bubble sort")
