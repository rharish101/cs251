set term epslatex

set datafile separator ","
threads = "`cat threads.txt`"

set xlabel "No. of Elements"
set ylabel "Speedup"

set title "Thread-wise Speedup"
set style fill solid border rgb "black"
set style data histogram
set output "threads_spd.eps"
stats "threads_spd.csv" using 1:2 nooutput
set xrange [:(STATS_records - 0.5)*1.8]
plot for [i=2:words(threads)] 'threads_spd.csv' using 2*(i - 1):xtic(1) title "Threads: ".word(threads, i)

set title "Thread-wise Speedup with Errors"
set style histogram errorbars
set style data histogram
set output "threads_spd_err.eps"
plot for [i=2:words(threads)] 'threads_spd.csv' using 2*(i - 1):2*(i - 1)+1:xtic(1) title "Threads: ".word(threads, i)
