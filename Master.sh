
#launch all copies
for((i=1;i<23;i++)); do
nohup ./Slave.sh $i ./Files/InVeh.MQ20.samflags99-163.rmchr.tab.bed ./Files/CVeh1.MQ20.samflags99-163.rmchr.tab.bed &
done
#wait for all copies to complete
#code failure can hang this loop forever, FYI
nfs=0
while [ $nfs -lt 22 ] ; do
sleep 60
nfs=`for w in chr*.ce ; do echo $w;done | wc |awk '{print $1}'`
done


