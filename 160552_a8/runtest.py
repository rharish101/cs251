#!/usr/bin/env python2
# coding: utf-8
from __future__ import print_function
import subprocess

params_file = open("params.txt", 'r')
params = params_file.read().split()
params_file.close()
threads_file = open("threads.txt", 'r')
threads = threads_file.read().split()
threads_file.close()

logs = open("log.txt", 'w')
print("Generating logs...")
count = 0
for num_threads in threads:
    for elements in params:
        for num in range(100):
            proc = subprocess.Popen(["./app", elements, num_threads],
                                    stdout=subprocess.PIPE)
            logs.write(" ".join(["Threads:", num_threads, "Elements:",
                                 elements, proc.stdout.read()]))
            count += 1
            print("\r{0} tests done out of {1}".format(count,
                len(threads) * len(params) * 100), end="")
print("")
logs.close()
