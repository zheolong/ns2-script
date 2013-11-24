#场景描述：
#无线网络中，两个节点  node_(0) 和 node_(1), TCP＋FTP, 并且设置了节点的移动
#===========================================================================
# 无线节点的参数设置
#===========================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             2                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              500                        ;# X dimension of the topography
set val(y)              500                        ;# Y dimension of the topography
#============================================================================




# 创建Simulator对象，用于模拟过程的事件调度
set ns [new Simulator]
#设置相关记录文件
set tracefd [open example2.tr w]
$ns trace-all $tracefd
set namtracefd [open example2.nam w]
# 注意： 与有线场景的命令有差别哦！
$ns namtrace-all-wireless $namtracefd $val(x) $val(y)




# 设置模拟结束时的操作， 将记录写入文件，并关闭文件， 最后启动 NAM 进行动画显示
proc finish {} {
global ns tracefd namtracefd
$ns flush-trace


 close $tracefd
close $namtracefd


exec nam example2.nam &
exit 0    
}


# 建立一个Topography对象，该对象保证移动节点会在拓扑边界范围内运动
set topo [new Topography]
# 500 X 500的边界
$topo load_flatgrid $val(x) $val(y)


# God对象主要用来对路由协议做性能评价，
# 它存储了： 节点的总数、各个节点间最短路径表等信息， 这些信息通常在模拟开始之前就计算好了！
# 节点的MAC对象会调用God对象， （初学者没必要关心！）
create-god $val(nn)


$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace OFF  




# 创建两个节点，存储在数组 Node中，    
for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns node] 
$node_($i) random-motion 0  ;# disable random motion
}
#设置节点的物理位置，一般第三位Z_=0.0， 模拟过程实际上是在二维平面上的场景
$node_(0) set X_ 5.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 390.0
$node_(1) set Y_ 385.0
$node_(1) set Z_ 0.0




#设置节点的移动， setdest 20.0 18.0 1.0:  向（20.0,18.0）位置以 1.0m/s的速度移动！
$ns at 1.0 "$node_(0) setdest 20.0 18.0 1.0"
$ns at 5.0 "$node_(1) setdest 25.0 20.0 15.0"
$ns at 100.0 "$node_(1) setdest 490.0 480.0 15.0"




# 创建TCP，及TCP对应的TCPSink，并连接起来，最后在TCP连接上添加FTP应用
set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp




#设置FTP数据流的开始时间
$ns at 1.0 "$ftp start" 
#模拟结束前调用各节点的reset函数， 无线场景中，一般照写就可！
for {set i 0} {$i < $val(nn) } {incr i} {
$ns at 150.0 "$node_($i) reset";
}
$ns at 150.0 "finish"


$ns run
