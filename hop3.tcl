set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

set file1 [open out.tr w]
$ns trace-all $file1

set file2 [open out.nam w]
$ns namtrace-all $file2

proc finish {} {
 global ns file1 file2
 $ns flush-trace
 close $file1
 close $file2
 exec nam out.nam &
 exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

$ns at 0.1 "$n1 label \"CBR\""
$ns at 1.0 "$n0 label \"FTP\""

$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 0.3Mb 100ms DropTail
$ns duplex-link $n1 $n2 0.3Mb 100ms DropTail
$ns duplex-link $n0 $n4 0.5Mb 40ms DropTail
$ns duplex-link $n2 $n3 0.5Mb 30ms DropTail

$ns duplex-link-op $n2 $n3 orient right-down  
$ns duplex-link-op $n1 $n2 orient right-down  
$ns duplex-link-op $n0 $n3 orient right-down  
$ns duplex-link-op $n0 $n1 orient right-up  
$ns duplex-link-op $n0 $n4 orient left-down


$ns queue-limit $n2 $n3 10

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set window_ 8000
$tcp set packetSize_ 552

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

set udp [new Agent/UDP]
$ns attach-agent $n2 $udp
set null [new Agent/Null]
$ns attach-agent $n4 $null
$ns connect $udp $null
$udp set fid_ 2

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 0.01mb
$cbr set random_ false
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 624.0 "$ftp stop"
$ns at 624.5 "$cbr stop"

set file [open cwnd_rtt.tr w]
$tcp attach $file
$tcp trace cwnd_
$tcp trace rtt_
$ns at 625.0 "finish"
$ns run
