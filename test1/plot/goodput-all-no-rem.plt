#!/usr/bin/gnuplot
set terminal postscript eps enhanced color 
output_base_dir='/root/AQM/master-paper/figure/chapter6/'
set output output_base_dir.'goodput-all-no-rem.eps'

data_file1 = '../grpid/autotest_result.txt'
data_file2 = '../mypid/autotest_result.txt'
data_file3 = '../pi/autotest_result.txt'
data_file4 = '../rem/autotest_result.txt'
data_file5 = '../avq/autotest_result.txt'
data_file6 = '../red/autotest_result.txt'

#set xrange [0:10020]
#set yrange [0:600]

plot data_file1 using 1:2 t "grpid" with linespoints lt 3 lc 3,\
	 data_file2 using 1:2 t "pid" with linespoints lt 3 lc 1,\
	 data_file3 using 1:2 t "pi" with linespoints lt 3 lc 2,\
	 data_file5 using 1:2 t "avq" with linespoints lt 3 lc 5,\
	 data_file6 using 1:2 t "red" with linespoints lt 3 lc 6

#data_file4 using 1:2 t "rem" with lines lt 3 lc 4,\
unset multiplot

set output
set terminal wxt

reset

#pause -1
