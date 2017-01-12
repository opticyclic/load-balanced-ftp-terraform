#!/bin/bash
COUNTER=2002
while [  $COUNTER -lt 3000 ]; do
   echo Creating port $COUNTER
   aws elb create-load-balancer-listeners --load-balancer-name ftp-elb --listeners "Protocol=TCP,LoadBalancerPort=$COUNTER,InstanceProtocol=TCP,InstancePort=$COUNTER"

   let COUNTER=COUNTER+1 
done

