#============ delay-link.awk =========
BEGIN {
  fromNode=0; toNode=1;
  num_samples = 0;
  total_delay = 0;
  {ORS=""} #让输出结果后面没有换行符号
}
#/^\+/&&$3==fromNode&&$4==toNode {
/^\+/{
    t_arr[$12] = $2;
};
#/^r/&&$3==fromNode&&$4==toNode {
/^r/{
    if (t_arr[$12] > 0) {
      num_samples++;
      delay = $2 - t_arr[$12];
    total_delay += delay;
    };
};
END{
  avg_delay = total_delay/num_samples;
#  print "Average queuing transmission delay is " avg_delay  " seconds";
#  print "Measurement details:"; 
#  print "  - Start when packets enter the node " fromNode;
#  print "  - Until the packets arrive the node " toNode;   
  print avg_delay;
};
