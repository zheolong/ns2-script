#This program is used to calculate the packet loss rate for CBR program
 
BEGIN {
# Initialization. Set two variables. fsDrops: packets drop. numFs: packets sent
   fsDrops = 0;
   numFs = 0;
   {ORS=""} #让输出结果后面没有换行符号
}
{
   action = $1;
   time = $2;
   from = $3;
   to = $4;
   type = $5;
   pktsize = $6;
   flow_id = $8;
   src = $9;
   dst = $10;
   seq_no = $11;
   packet_id = $12;
        if (from==0 && to==1 && action == "+")
                numFs++;
        #if (flow_id==2 && action == "d")
        #        fsDrops++;
        if (action == "r")
                fsDrops++;
}
END {
        #printf("number of packets sent:%d lost:%d\n", numFs, fsDrops);
        printf(fsDrops/(numFs+fsDrops));
}
