#!/usr/bin/python3

# My method to determine the type of a variable
# uses different hashes to store values.
# e.g. all numbers go to %numbers
#      all strings go to %strings
#      all arrays go to %arrays
#      all dicts go to %dicts

# the code below is a problem for me, because 
# it will place "a" into the numbers hash.
# when it is reassigned to an array, it will 
# also be put in the arrays hash.
# therefore my code will not know how to tell whether the 
# variable "a" is a number or an array.

a = 5
a = ['test', 'script', 'five']
print(a)


# my translations -> print($@a)
# required -> print(@a)
