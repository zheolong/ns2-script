#!/usr/bin/gnuplot
output_base_dir='/root/AQM/master-paper/figure/chapter6/'
#set terminal postscript eps enhanced color 
#set output output_base_dir.'queuelen-response.eps'
# 输出pdf（可以使用中文）
set terminal pdfcairo noenhanced solid lw 2 font "Time New Roman,10.5"
set output output_base_dir.'queuelen-response.pdf'

data_file1 = '../grpid/all.q'
data_file2 = '../mypid/all.q'
data_file3 = '../pi/all.q'
#data_file4 = '../rem/all.q'
#data_file5 = '../avq/all.q'
#data_file6 = '../red/all.q'

#set xrange [0:10020]
set yrange [100:400]

set xlabel "时间(秒)"
set ylabel "数据包(个)"

#三行两列
#set size 2,3
#set origin 0,0
#set multiplot
set multiplot layout 3,1

#绘制图1
#set size 2,3
#set origin 0,0
plot data_file1 using 2:3 t "GRPID" with lines lc 3
#绘制图2
#set size 2,1
#set origin 1,1
plot data_file2 using 2:3 t "PID" with lines lc 1 
#绘制图3
#set size 1,2
#set origin 0,0
plot data_file3 using 2:3 t "PI" with lines lc 2
#绘制图4
#set size 1,2
#set origin 0,0
#plot data_file4 using 2:3 t "REM" with lines lc 4 
#绘制图5
#set size 1,2
#set origin 0,0
#plot data_file5 using 2:3 t "AVQ" with lines lc 5 
#绘制图6
#set size 1,2
#set origin 0,0
#plot data_file6 using 2:3 t "RED" with lines lc 8

unset multiplot

set output
set terminal wxt

reset

#pause -1
