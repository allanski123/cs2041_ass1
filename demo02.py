#!/usr/bin/python3

# tests arrays -> pop() with args, append()
# tests dict keys method and iterating through them
# tests printing with % formatting
# for loops with range (1 and 2 args), end='', sorted() etc.

i = 0
arr = []
dict = {}

for j in range(10):
    arr.append(9 - j)

new_arr = ["key1", "key2", "key3"]
for i in new_arr:
    dict[i] = 5

print("Original Array is:", end=' ')
for i in arr:
    print(i, end=' ')

print("\n")
for i in range(0, 10):
    print("Popping last element: ", arr.pop(9 - i))
    print("Array length is now: ", len(arr))
    print()

for i in sorted(dict.keys()):
    print("The key is: %d" % i)
    print("The value is: %d" % dict[i])
    print()
