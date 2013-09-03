#script illustrating  RED usage
#Senders are TCP-SACK senders, and receivers are TCP-SACK sinks

set ns [new Simulator]

# turn on ns and nam tracing
set f [open out.tr w]
$ns trace-all $f
$ns namtrace-all [open out.nam w]



#------------------------------------------------------------------
set start_time 1.0              ;#开始时间
set finish_time 100             ;#结束时间


#set the no of TCP flows here
set nodenum 60                  ;#60个发送结点，60个接受结点

# create the nodes

#First create TCP senders and receivers

for {set i 0} {$i < $nodenum} {incr i} {
    
    set s($i) [$ns node]
    set r($i) [$ns node]           ;#建立结点
}

#Then create the 2 back-bone routers
set n1 [$ns node]
set n2 [$ns node]  

# create the links 
#betwwen the senders and n1, receivers and n2
for {set i 0} {$i < $nodenum} {incr i} {

    $ns duplex-link $s($i) $n1 10Mb 20ms DropTail
    $ns duplex-link $r($i) $n2 10Mb 20ms DropTail           ;#发送和接收结点与瓶颈结点连接时的设置

}

#Bottle neck link between between n1 and n2
$ns simplex-link $n1 $n2 10Mbps 60ms RED             ;#链路瓶颈的设置及处理算法，RED既是模糊自适应RED算法
$ns simplex-link $n2 $n1 10Mbps 60ms RED    

#Configure RED queue parameters here

set redq [[$ns link $n1 $n2] queue]
set tchan_ [open all.q w]
$redq trace curq_
$redq attach $tchan_

#$redq set thresh_ 100
#$redq set maxthresh_ 300
$redq set thresh_ 0
$redq set maxthresh_ 100
$redq set q_weight_ 0.1
$redq set linterm_ 10
$redq set bytes_ false 
$redq set queue_in_bytes_ false 
$redq set mean_pktsize_ 500
$redq set adaptive_ 0
$redq set gentle_ false 

#set the queue-limit between n1 and n2
$ns queue-limit $n1 $n2 100                     ;#瓶颈链路缓冲区大小 50个数据包

#set up queue monitor, sample every 0.5 seconds
set qfile [open "test-red-qsize.out" w]
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
