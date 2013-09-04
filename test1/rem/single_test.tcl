#script illustrating  REM usage
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
set nodenum [lindex $argv 0]               ;#60�����ͽ�㣬60�����ܽ��

# create the nodes
#Then create the 2 back-bone routers
set n1 [$ns node]
set n2 [$ns node]  

#First create TCP senders and receivers

for {set i 0} {$i < $nodenum} {incr i} {
    
    set s($i) [$ns node]
    set r($i) [$ns node]           ;#�������
}


# create the links 
#betwwen the senders and n1, receivers and n2
for {set i 0} {$i < $nodenum} {incr i} {

    $ns duplex-link $s($i) $n1 10Mb 20ms DropTail
    $ns duplex-link $r($i) $n2 10Mb 20ms DropTail           ;#���ͺͽ��ս����ƿ���������ʱ������

}

#Bottle neck link between between n1 and n2
$ns simplex-link $n1 $n2 10Mbps 60ms REM             ;#��·ƿ�������ü������㷨��REM����ģ������ӦREM�㷨
$ns simplex-link $n2 $n1 10Mbps 60ms REM    

#Configure REM queue parameters here
set remq [[$ns link $n1 $n2] queue]
set tchan_ [open all.q w]
$remq trace curq_
$remq attach $tchan_
$remq set gamma_ 0.001
$remq set phi_ 1.001
$remq set inw_ 1
$remq set mean_pktsize_ 500
$remq set pupdtime_ 0.002
$remq set pbo_ 20.0
$remq set prob_ 0.0
$remq set curq_ 0.0
$remq set pmark_ 0.0
$remq set markpkts_ false
$remq set qib_ false
#set the queue-limit between n1 and n2
$ns queue-limit $n1 $n2 600                     ;#ƿ����·��������С 50�����ݰ�

#set up queue monitor, sample every 0.5 seconds
set qfile [open "test-rem-qsize.out" w]
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
