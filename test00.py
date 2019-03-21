#!/usr/bin/python3

# in python this program produces output : -66 
# in perl this program produces output : 18446744073709551550
# in binary this is 1111111111111111111111111111111111111111111111111111111110111110
# and the last 8 bits are 10111110 --> -66 in twos compliment

# the two outputs are different because in perl, the program prints the 32 bit binary
# equivalent instead of the 2's compliment.

a = 65
print(~a)
