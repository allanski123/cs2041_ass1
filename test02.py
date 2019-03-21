#!/usr/bin/python3

# python output: test4
# the spec does a simple translation changing sys.stdout.write() to print()
# hence we can easily forget that sys.stdout.write() returns the length
# of the printed string when assigned to a variable or printed.

import sys
print(sys.stdout.write("test"))

# or
# num = sys.stdout.write("test")
# print(num)
# output -> test4
