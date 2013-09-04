#!/usr/bin/gnuplot
set terminal postscript eps enhanced color 
output_base_dir='/root/AQM/master-paper/figure/chapter6/'
set output output_base_dir.'loss-rate-all.eps'

data_file1 = '../grpid/autotest_result.txt'
data_file2 = '../pid/autotest_result.txt'
data_file3 = '../pi/autotest_result.txt'
data_file4 = '../rem/autotest_result.txt'
data_file5 = '../avq/autotest_result.txt'
data_file6 = '../red/autotest_result.txt'

#set xrange [0:10020]
#set yrange [0:600]

plot data_file1 using 1:3 t "grpid" with linespoints lt 3 lc 1,\
	 data_file2 using 1:3 t "pid" with linespoints lt 3 lc 2,\
	 data_file3 using 1:3 t "pi" with linespoints lt 3 lc 3,\
	 data_file4 using 1:3 t "rem" with lines lt 3 lc 4,\
	 data_file5 using 1:3 t "avq" with linespoints lt 3 lc 5,\
	 data_file6 using 1:3 t "red" with linespoints lt 3 lc 5

unset multiplot

set output
set terminal wxt

reset

#pause -1
