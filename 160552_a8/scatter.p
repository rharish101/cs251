set term epslatex
set datafile separator ","
set logscale xy
set xlabel "No. of Elements"
set ylabel "Time Taken" offset 2, 0
stats "threads_1.csv" nooutput
set xrange [STATS_min_x*0.5:STATS_max_x*2]
threads = "`cat threads.txt`"
do for [i=1:words(threads)] {
    set output "threads_".word(threads, i).".eps"
    plot "threads_".word(threads, i).".csv" title "No. of Threads: ".word(threads, i)
}
