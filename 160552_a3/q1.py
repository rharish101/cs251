#!/usr/bin/env python
from __future__ import print_function
if hasattr(__builtins__, 'raw_input'):
    input = raw_input
import argparse

# Base conversion
def base_conv(string, base):
    output = 0
    base_pow = 1    # Stores powers of the base
    negative = 1    # 1 if no. is +ve, -1 if -ve
    if string[0] == '-':
        negative = -1
        string = string[1:]
    arr = string.split(".")
    length = len(arr[0])

    for i in range(length, 0, -1):
        char = ord(string[i - 1])
        if char in list(range(ord("0"), ord("9") + 1)):
            digit = char - ord("0")
        elif char in list(range(ord("A"), ord("Z") + 1)):
            digit = char - ord("A") + 10
        else:
            return None

        if digit >= base:
            return None
        output += base_pow * digit
        base_pow *= base

    if len(arr) > 1:    # If there are digits after the decimal point
        base_pow = 1 / base
        for i in range(0, len(arr[1])):
            char = ord(string[length + i + 1])
            if char in list(range(ord("0"), ord("9") + 1)):
                digit = char - ord("0")
            elif char in list(range(ord("A"), ord("Z") + 1)):
                digit = char - ord("A") + 10
            else:
                return None

            if digit >= base:
                return None
            output += base_pow * digit
            base_pow /= base

    return negative * output

# Adding commandline argument for custom input
parser = argparse.ArgumentParser(description="160552's solution for Q1 of "\
                                             "CS251A Assignment 3")
parser.add_argument('num', nargs='?', metavar='num', type=str,
                    help='number to be converted')
parser.add_argument('base', nargs='?', metavar='base', type=int,
                    help='base of the number')
args = parser.parse_args()
if args.num:
    string = args.num.strip()
else:
    string = input("Enter number: ").strip()
if args.base:
    base = args.base
else:
    base = int(input("Enter base: "))

# Convert base and print
answer = base_conv(string, base)
if answer is None:
    print("Invalid Input")
else:
    print(answer)
