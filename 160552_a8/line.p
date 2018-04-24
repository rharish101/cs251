set term epslatex
set output "threads_avg.eps"
set datafile separator ","
set logscale xy
set xlabel "No. of Elements"
set ylabel "Time Taken" offset 2, 0
set title "Average Time Taken"
stats "threads_1_avg.csv" nooutput
set xrange [STATS_min_x*0.5:STATS_max_x*2]
threads = "`cat threads.txt`"
plot for [i=1:words(threads)] 'threads_'.word(threads, i).'_avg.csv' title 'Threads: '.word(threads, i) with lines
