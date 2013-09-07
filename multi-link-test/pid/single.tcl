#script illustrating  Vq usage
#Senders are TCP-SACK senders, and receivers are TCP-SACK sinks
#ע�⣬���ű�ִ�еĵ�һ��������Դ�˺�Ŀ�Ķ˽ڵ������,
#�ڶ�������Ϊʱ�䣬
#���ű�������ִ�е�����Ϊns test.tcl <number> <time>

set ns [new Simulator]

# turn on ns and nam tracing
set f [open out.tr w]
$ns trace-all $f
$ns namtrace-all [open out.nam w]

#------------------------------------------------------------------
set start_time 1.0              ;#��ʼʱ��
set finish_time [lindex $argv 1]            ;#����ʱ��


#set the no of TCP flows here
#$argvΪ����Ĳ��������ڵ���
set nodenum [lindex $argv 0]
set router_num 6 
set subnode_num [expr ([lindex $argv 0] / 5)] 

# create the nodes
#Then create the 6 back-bone routers
for {set i 0} {$i < $router_num} {incr i} {
	set n($i) [$ns node]
}

#First create TCP senders and receivers

for {set i 0} {$i < [expr ( $nodenum + 2 * $subnode_num)]} {incr i} {
    set s($i) [$ns node]
    set r($i) [$ns node]           ;#�������
}

# create the links 
for {set i 0} {$i < $nodenum} {incr i} {
    $ns duplex-link $s($i) $n(0) 10Mb 20ms DropTail
    $ns duplex-link $r($i) $n(5) 10Mb 20ms DropTail           ;#���ͺͽ��ս����ƿ���������ʱ������
}

for {set i $nodenum} {$i < [expr ( $nodenum + $subnode_num)]} {incr i} {
    $ns duplex-link $s($i) $n(1) 10Mb 20ms DropTail
    $ns duplex-link $r($i) $n(2) 10Mb 20ms DropTail           ;#���ͺͽ��ս����ƿ���������ʱ������
}

for {set i [expr ( $nodenum + $subnode_num)] } {$i < [expr ( $nodenum + 2 * $subnode_num)]} {incr i} {
    $ns duplex-link $s($i) $n(3) 10Mb 20ms DropTail
    $ns duplex-link $r($i) $n(4) 10Mb 20ms DropTail           ;#���ͺͽ��ս����ƿ���������ʱ������
}

#Bottle neck link between between n1 and n2
for {set i 0} {$i < [expr ($router_num - 1)]} {incr i} {
	$ns simplex-link $n($i) $n([expr ($i + 1)]) 10Mbps 60ms PID2 
	$ns simplex-link $n([expr ($i + 1)]) $n($i) 10Mbps 60ms PID2    
}


set pid2q [[$ns link $n(1) $n(2)] queue]
set tchan_ [open all.q w]
$pid2q trace curq_
$pid2q attach $tchan_

#Configure Vq queue parameters here
for {set i 0} {$i < [expr ($router_num - 1)]} {incr i} {
	set pid2q [[$ns link $n($i) $n([expr ($i + 1)])] queue]
$pid2q set mean_pktsize_ 500
$pid2q set w_ 1170
$pid2q set qref_ 300                              ;#�������г���
$pid2q set kp_k_ 0.01
$pid2q set kp_i_ 0.01
$pid2q set kp_d_ 0.01
$pid2q set eta_p_ 0.07
$pid2q set eta_i_ 0.02
$pid2q set eta_d_ 0.07
$pid2q set n_ 1
$pid2q set m_ 5
$pid2q set alhpa_ 0.1
$pid2q set eta_ 0.06
$pid2q set bytes_ false 
$pid2q set queue_in_bytes_ false 
}

#set the queue-limit between n1 and n2
for {set i 1} {$i < [expr ($router_num - 1)]} {incr i} {
	$ns queue-limit $n($i) $n([expr ($i + 1)]) 600                     ;#ƿ����·��������С 50�����ݰ�
}

#set up queue monitor, sample every 0.5 seconds
set qfile [open "test-vq-qsize.out" w]
set qm [$ns monitor-queue $n(1) $n(2) $qfile 0.5]
[$ns link $n(1) $n(2)] queue-sample-timeout

#create the random number generator
set rng [new RNG]

# create TCP agents
for {set i 0} {$i < [expr ( $nodenum + 2 * $subnode_num)]} {incr i} {
    set tcp($i) [new Agent/TCP/Sack1]
    $tcp($i) set fid_ [expr ($i + 1)]
    set sink($i) [new Agent/TCPSink/Sack1/DelAck]
    $ns attach-agent $s($i) $tcp($i)
    $ns attach-agent $r($i) $sink($i)
    $ns connect $tcp($i) $sink($i)
    set ftp($i) [new Application/FTP]
    $ftp($i) attach-agent $tcp($i)
    #set p($i) [new Application/Traffic/Pareto]
    #$p($i) set packetSize_ 1000
    #$p($i) set burst_time_ 200ms
    #$p($i) set idle_time_ 200ms
    #$p($i) set shape_ 1.5
    #$p($i) set rate_ 10000K
    #$p($i) attach-agent $tcp($i)
    set start_time [$rng uniform 0 1]
    $ns at $start_time "$ftp($i) start"
    #$ns at $start_time "$p($i) start"
}

$ns at $finish_time "finish"

proc finish {} {
    global ns sink nodenum  qfile
    $ns flush-trace
    close $qfile
    #puts "running nam..."
    exec nam out.nam &
    #    exec xgraph *.tr -geometry 800x400 &
    exit 0
}

$ns run
