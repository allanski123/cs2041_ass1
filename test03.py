#!/usr/bin/python3

# can be a difficult translation because it is
# tedious to determine the type of value stored 
# in the array

# will sort in alphabetical order if we simply replace
# sorted() with sort()
print(sorted(['wow', 'ok', 'test']))

# will not be sorted if we simply replace sorted() with sort()
# requires sort {$a <=> $b} ()
print(sorted([1, 5, 3]))

# contains both strings and numbers
# hence does not require {$a <=> $b}
print(sorted(["1", "5", "3", 1, 5, 3]))
