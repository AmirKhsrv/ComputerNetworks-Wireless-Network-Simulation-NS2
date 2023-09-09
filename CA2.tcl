# ======================================================================
# Check Arguments Correctness
# ======================================================================

if { $argc != 3 } {
	puts "arguments should contain band_width packet_size error_rate "
	exit 0
}

# ======================================================================
# Define Base options
# ======================================================================

set opt(chan)	Channel/WirelessChannel 	;# channel type
set opt(prop)	Propagation/TwoRayGround	;# radio-propagation model
set opt(netif)	Phy/WirelessPhy				;# network interface type
set opt(mac)	Mac/802_11					;# MAC type
set opt(ifq)	Queue/DropTail/PriQueue		;# interface queue type
set opt(ll)		LL							;# antenna model
set opt(ant)    Antenna/OmniAntenna			;# max packet in ifq
set opt(ifqlen)	50	      					;# max packet in ifq
set opt(tr)		sim_trace.tr    				;# trace file
set opt(nam)            sim_network_anim.nam   		;# nam trace file
set opt(adhocRouting)   AODV				;# routing protocol
set opt(nn)             9             		;# how many nodes are simulated
set opt(stop)		100.0					;# simulation time

# Topology x & y
set opt(x)		800   						;# X dimension of the topography
set opt(y)		800   						;# Y dimension of the topography

# set wireless channel, radio-model and topography objects
set wtopo	[new Topography]
$wtopo load_flatgrid $opt(x) $opt(y)

# Arguments of tcl
set opt(bandWidth) [lindex $argv 0]
set opt(packetSize) [lindex $argv 1]			
set errorRate [lindex $argv 2]

set opt(winSize) 20


# ======================================================================
# Base Instances
# ======================================================================


# Create God

set god_ [create-god $opt(nn)]


# create simulator instance

set ns		[new Simulator]


# create trace object for ns and nam

set tracefd	[open $opt(tr) w]
set namtrace    [open $opt(nam) w]

$ns trace-all $tracefd
$ns eventtrace-all
$ns namtrace-all-wireless $namtrace $opt(x) $opt(y)

# ======================================================================
# Base Functions
# ======================================================================


# Define Error Model

proc UniformErrorModel {} {     
	global errorRate
	set err [new ErrorModel]
	$err unit packet
	$err set rate_ $errorRate
	$err ranvar [new RandomVariable/Uniform]
	return $err
}


# Define Finish Procedure

proc finish {} {
	global ns tracefd namtrace opt
	
	$ns nam-end-wireless $opt(stop)
	$ns flush-trace
	close $tracefd
	close $namtrace
}


# ======================================================================
# Node Configuration
# ======================================================================




# global node setting (defines how node should be created)

$ns node-config 	-adhocRouting $opt(adhocRouting) \
					-llType $opt(ll) \
					-macType $opt(mac) \
					-ifqType $opt(ifq) \
					-ifqLen $opt(ifqlen) \
					-antType $opt(ant) \
					-propType $opt(prop) \
					-phyType $opt(netif) \
					-channelType $opt(chan) \
					-topoInstance $wtopo \
					-agentTrace ON \
					-routerTrace ON \
					-macTrace OFF \
					-movementTrace OFF \
					-incomingErrProc UniformErrorModel \
					-OutgoingErrProc UniformErrorModel

# set network bandwidth
$opt(mac) set basicRate_ 0
$opt(mac) set dataRate_ 0
$opt(mac) set bandwidth_ $opt(bandWidth)Mb


#  Create the specified number of nodes 

for {set i 0} {$i < $opt(nn) } {incr i} {
	set node_($i) [$ns node]	
	$node_($i) random-motion 0
}


#	define postions and labels of nodes

$node_(0) label "A" 
$node_(0) set X_ [expr 200.0]
$node_(0) set Y_ [expr 600.0]
$node_(0) set Z_ 0.0

$node_(1) label "B"
$node_(1) set X_ [expr 75.0]
$node_(1) set Y_ [expr 400.0]
$node_(1) set Z_ 0.0

$node_(2) label "C"
$node_(2) set X_ [expr 400.0]
$node_(2) set Y_ [expr 500.0]
$node_(2) set Z_ 0.0

$node_(3) label "D"
$node_(3) set X_ [expr 200.0]
$node_(3) set Y_ [expr 200.0]
$node_(3) set Z_ 0.0

$node_(4) label "E" 
$node_(4) set X_ [expr 400.0]
$node_(4) set Y_ [expr 300.0]
$node_(4) set Z_ 0.0

$node_(5) label "F"  
$node_(5) set X_ [expr 570.0]
$node_(5) set Y_ [expr 270.0]
$node_(5) set Z_ 0.0

$node_(6) label "G" 
$node_(6) set X_ [expr 570.0]
$node_(6) set Y_ [expr 570.0]
$node_(6) set Z_ 0.0

$node_(7) label "H"
$node_(7) set X_ [expr 750.0]
$node_(7) set Y_ [expr 600.0]
$node_(7) set Z_ 0.0

$node_(8) label "L"
$node_(8) set X_ [expr 750.0]
$node_(8) set Y_ [expr 200.0]
$node_(8) set Z_ 0.0


# ======================================================================
# Traffic Simulation
# ======================================================================



# A sends data to H at time 2.0 and stops at 96.0

set tcp_(0) [$ns create-connection  TCP $node_(0) TCPSink $node_(7) 0]
$tcp_(0) set window_ $opt(winSize)
$tcp_(0) set packetSize_ $opt(packetSize)
set ftp_(0) [$tcp_(0) attach-source FTP]
$ns at 2 "$ftp_(0) start"
$ns at 96 "$ftp_(0) stop"

# A sends data to L at time 2.0 and stops at 96.0

set tcp_(1) [$ns create-connection  TCP $node_(0) TCPSink $node_(8) 0]
$tcp_(1) set window_  $opt(winSize)
$tcp_(1) set packetSize_ $opt(packetSize)
set ftp_(1) [$tcp_(1) attach-source FTP]
$ns at 2 "$ftp_(1) start"
$ns at 96 "$ftp_(1) stop"

# D sends data to H at time 2.0 and stops at 96.0

set tcp_(2) [$ns create-connection  TCP $node_(3) TCPSink $node_(7) 0]
$tcp_(2) set window_ $opt(winSize)
$tcp_(2) set packetSize_ $opt(packetSize)
set ftp_(2) [$tcp_(2) attach-source FTP]
$ns at 2 "$ftp_(2) start"
$ns at 96 "$ftp_(2) stop"

# D sends data to L at time 2.0 and stops at 96.0

set tcp_(3) [$ns create-connection  TCP $node_(3) TCPSink $node_(8) 0]
$tcp_(3) set window_ $opt(winSize)
$tcp_(3) set packetSize_ $opt(packetSize)
set ftp_(3) [$tcp_(3) attach-source FTP]
$ns at 2 "$ftp_(3) start"
$ns at 96 "$ftp_(3) stop"



# ======================================================================
# Other
# ======================================================================


# Define node initial position in nam

for {set i 0} {$i < $opt(nn)} {incr i} {
    $ns initial_node_pos $node_($i) 20
}


# Tell nodes when the simulation ends

for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns at $opt(stop) "$node_($i) reset";
}



$ns at $opt(stop) "finish"
$ns at $opt(stop) "puts \"DONE\" ; $ns halt"


puts "Starting ..."
$ns run
