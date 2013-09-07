#!/usr/bin/gnuplot
set terminal postscript eps enhanced color 
output_base_dir='/root/AQM/master-paper/figure/chapter6/'
set output output_base_dir.'multi-link-delay-link-all.eps'

data_file1 = '../grpid/autotest_result.txt'
data_file2 = '../red/autotest_result.txt'
data_file3 = '../pi/autotest_result.txt'
data_file4 = '../rem/autotest_result.txt'
data_file5 = '../avq/autotest_result.txt'

set xtics font ",10"
set ytics font ",10"
#set xrange [0:10020]
#set yrange [0:600]

plot data_file1 using 1:4 t "grpid" with linespoints lc 1 lw 5,\
	 data_file2 using 1:4 t "red" with linespoints lc 2 lw 5,\
	 data_file3 using 1:4 t "pi" with linespoints lc 3 lw 5,\
	 data_file4 using 1:4 t "rem" with lines lc 4 lw 5,\
	 data_file5 using 1:4 t "avq" with linespoints lc 5 lw 5

unset multiplot

set output
set terminal wxt

reset

#pause -1
