#script illustrating  GRPID usage
#Senders are TCP-SACK senders, and receivers are TCP-SACK sinks
#注意，本脚本执行的第一个参数是源端和目的端节点的数量,
#第二个参数为时间，
#本脚本带参数执行的命令为ns test.tcl <number> <time>

set ns [new Simulator]

# turn on ns and nam tracing
set f [open out.tr w]
$ns trace-all $f
$ns namtrace-all [open out.nam w]

#------------------------------------------------------------------
set start_time 1.0              ;#开始时间
set finish_time [lindex $argv 1]            ;#结束时间

set halved_time 80              ;#流量减半时间
set retrive_time 160             ;#流量恢复时间

#set the no of TCP flows here
#$argv为传入的参数，即节点数
set nodenum [lindex $argv 0]               ;#60个发送结点，60个接受结点

# create the nodes
#Then create the 2 back-bone routers
set n1 [$ns node]
set n2 [$ns node]  

#First create TCP senders and receivers

for {set i 0} {$i < $nodenum} {incr i} {
    
    set s($i) [$ns node]
    set r($i) [$ns node]           ;#建立结点
}


# create the links 
#betwwen the senders and n1, receivers and n2
for {set i 0} {$i < $nodenum} {incr i} {

    $ns duplex-link $s($i) $n1 10Mb 20ms DropTail
    $ns duplex-link $r($i) $n2 10Mb 20ms DropTail           ;#发送和接收结点与瓶颈结点连接时的设置

}

#Bottle neck link between between n1 and n2
$ns simplex-link $n1 $n2 10Mbps 60ms GRPID             ;#链路瓶颈的设置及处理算法，GRPID既是模糊自适应GRPID算法
$ns simplex-link $n2 $n1 10Mbps 60ms GRPID    

#Configure GRPID queue parameters here
set grpidq [[$ns link $n1 $n2] queue]
set tchan_ [open all.q w]
$grpidq trace curq_
$grpidq attach $tchan_
$grpidq set mean_pktsize_ 500
$grpidq set w_ 1170
$grpidq set qref_ 300                              ;#期望队列长度
$grpidq set kp_k_ 0.01
$grpidq set kp_i_ 0.01
$grpidq set kp_d_ 0.01
$grpidq set eta_p_ 0.07
$grpidq set eta_i_ 0.02
$grpidq set eta_d_ 0.07
$grpidq set n_ 1
$grpidq set m_ 5
$grpidq set alhpa_ 0.1
$grpidq set eta_ 0.06
$grpidq set bytes_ false 
$grpidq set queue_in_bytes_ false 

#set the queue-limit between n1 and n2
$ns queue-limit $n1 $n2 600                     ;#瓶颈链路缓冲区大小 50个数据包

#set up queue monitor, sample every 0.5 seconds
set qfile [open "test-grpid-qsize.out" w]
set qm [$ns monitor-queue $n1 $n2 $qfile 0.5]
[$ns link $n1 $n2] queue-sample-timeout

#create the random number generator
set rng [new RNG]


# create TCP agents
for {set i 0} {$i < $nodenum} {incr i} {

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

	if { $i < [expr ($nodenum * 2.0/5.0)] } {
		
		$ns at $halved_time "$ftp($i) stop"
		$ns at $retrive_time "$ftp($i) start"

	}
}
#------------------------------------------------------------------

#------------------------------------------------------------------
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
