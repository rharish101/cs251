#!/usr/bin/env python2
log_file = open("log.txt", "r")
text = log_file.read()
log_file.close()
threads_file = open("threads.txt", 'r')
threads = threads_file.read().split()
threads_file.close()

files_normal = {}
files_avg = {}
file_speedup = open("threads_spd.csv", "w")
avg_values = {}
var_values = {}
for num_threads in threads:
    files_normal[num_threads] = open("threads_" + num_threads + ".csv", "w")
    files_avg[num_threads] = open("threads_" + num_threads + "_avg.csv", "w")
    avg_values[num_threads] = {}
    var_values[num_threads] = {}
    
for line in text.split("\n")[:-1]:
    data = line.split()
    files_normal[data[1]].write(data[3] + "," + data[7] + "\n")
    if data[3] in avg_values[data[1]]:
        avg_values[data[1]][data[3]] += int(data[7])
    else:
        avg_values[data[1]][data[3]] = int(data[7])

for line in text.split("\n")[:-1]:
    data = line.split()
    if data[3] in var_values[data[1]]:
        var_values[data[1]][data[3]] += (avg_values['1'][data[3]] *\
            ((1 / (float(data[7]) * 100)) - \
            (1.0 / avg_values[data[1]][data[3]]))) ** 2
    else:
        var_values[data[1]][data[3]] = (avg_values['1'][data[3]] *\
            ((1 / (float(data[7]) * 100)) - \
            (1.0 / avg_values[data[1]][data[3]]))) ** 2

for elements in sorted(avg_values[threads[0]]):
    file_speedup.write(elements)
    for num_threads in threads[1:]:
        file_speedup.write("," + str(float(avg_values['1'][elements]) /\
                                     avg_values[num_threads][elements]))
        file_speedup.write("," + str(var_values[num_threads][elements] /\
                                         100.0))
    file_speedup.write("\n")
file_speedup.close()

for num_threads in threads:
    files_normal[num_threads].close()
    for elements in sorted(avg_values[num_threads]):
        files_avg[num_threads].write(",".join([elements,
            str(avg_values[num_threads][elements] / 100.0)]) + "\n")
    files_avg[num_threads].close()
