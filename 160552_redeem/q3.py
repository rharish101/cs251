#!/usr/bin/env python
from __future__ import print_function
if hasattr(__builtins__, "raw_input"):
    input = raw_input
import math

arr = list(map(int, input("Enter input array: ").replace("[", "").replace("]",
    "").split(",")))
arr.sort()
no_digits = len(str(arr[-1]))

def bst_printer(start, end):
    length = end - start + 1
    if length < 1:
        return

    center_index = start + int(math.ceil(length / 2) - 1)
    for i in range(start, center_index):
        for j in range(no_digits):
            print(" ", end="")
    print("{0:^{1}}".format(arr[center_index], no_digits), end="")
    arr[center_index] = None
    for i in range(center_index, end):
        for j in range(no_digits):
            print(" ", end="")

depth = math.floor(math.log2(len(arr))) + 1
for height in range(int(depth)):
    start = 0
    for i in range(len(arr)):
        if arr[i] is None:
            bst_printer(start, i - 1)
            for j in range(no_digits):
                print(" ", end="")
            start = i + 1
    bst_printer(start, i)
    print()
