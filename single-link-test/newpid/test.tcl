#script illustrating  PID2 usage
#Senders are TCP-SACK senders, and receivers are TCP-SACK sinks

set ns [new Simulator]

# turn on ns and nam tracing
set f [open out.tr w]
$ns trace-all $f
$ns namtrace-all [open out.nam w]

#set the no of TCP flows here
set nodenum 60                  ;#60�����ͽ�㣬60�����ܽ��

set start_time 1.0              ;#��ʼʱ��
set finish_time 160             ;#����ʱ��

# create the nodes

#First create TCP senders and receivers

for {set i 0} {$i < $nodenum} {incr i} {
    
    set s($i) [$ns node]
    set r($i) [$ns node]           ;#�������
}

#Then create the 2 back-bone routers
set n1 [$ns node]
set n2 [$ns node]  

# create the links 
#betwwen the senders and n1, receivers and n2
for {set i 0} {$i < $nodenum} {incr i} {

    $ns duplex-link $s($i) $n1 100Mb 20ms DropTail
    $ns duplex-link $r($i) $n2 100Mb 20ms DropTail           ;#���ͺͽ��ս����ƿ���������ʱ������

}

#Bottle neck link between between n1 and n2
$ns simplex-link $n1 $n2 10Mbps 60ms PID2             ;#��·ƿ�������ü������㷨��PID2����ģ������ӦPID2�㷨
$ns simplex-link $n2 $n1 10Mbps 60ms DropTail    

#Configure PID2 queue parameters here
set pid2q [[$ns link $n1 $n2] queue]
set tchan_ [open all.q w]
$pid2q trace curq_
$pid2q attach $tchan_
$pid2q set w_ 170
$pid2q set qref_ 150                                ;#�������г���
#$pid2q set a_ 0.00001390
#$pid2q set b_ 0.00002226
#$pid2q set c_ 0.00000873

#set the queue-limit between n1 and n2
$ns queue-limit $n1 $n2 300                     ;#ƿ����·��������С 50�����ݰ�

#set up queue monitor, sample every 0.5 seconds
set qfile [open "test-pid2-qsize.out" w]
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
