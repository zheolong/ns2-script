#!/usr/bin/gnuplot
output_base_dir='/root/AQM/master-paper/figure/chapter6/'
#set terminal postscript eps enhanced color 
#set output output_base_dir.'goodput-all-add-rem.eps'
# 输出pdf（可以使用中文）
set terminal pdfcairo noenhanced solid lw 2 font "Time New Roman,10.5"
set output output_base_dir.'goodput-all-add-rem.pdf'

data_file1 = '../grpid/autotest_result.txt'
data_file2 = '../mypid/autotest_result.txt'
data_file3 = '../pi/autotest_result.txt'
data_file4 = '../rem/autotest_result.txt'
data_file5 = '../avq/autotest_result.txt'
data_file6 = '../red/autotest_result.txt'

set xlabel "连接数(个)"
set ylabel "吞吐量(kbps)"
#set xrange [0:10020]
#set yrange [0.07:0.08]

plot data_file1 using 1:2 t "GRPID" with linespoints lt 3 ps 0.7 lc 1,\
	 data_file2 using 1:2 t "PID" with linespoints lt 4 ps 0.7 lc 2,\
	 data_file3 using 1:2 t "PI" with linespoints lt 19 ps 0.7 lc 3,\
	 data_file4 using 1:2 t "REM" with linespoints lt 21 ps 0.7 lc 4,\
	 data_file5 using 1:2 t "AVQ" with linespoints lt 10 ps 0.7 lc 5,\
	 data_file6 using 1:2 t "RED" with linespoints lt 12 ps 0.7 lc 7

unset multiplot

set output
set terminal wxt

reset
#pause -1
