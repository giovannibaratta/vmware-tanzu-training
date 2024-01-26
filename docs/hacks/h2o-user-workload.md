## Fix DHCP on user-workload

If DHCP assigned in the user-workload is not assigning IPs in the expected range, we can use a L2 bridging segment with a DHCP. The workaround might implement a networking solution might be completely wrong (but it works).
* Create a segment in NSX
* Create a VLAN transport zone
* Create a distributed port group with VLAN trunking
* Deploy an edge transport node connected to the new transport zone and the overlay transport zone. The edge transport node should have a switch with an uplink to the distributed port group.
* Set the bridge profile to the segment, the segment should **NOT** be connected to a router
* Add dhcp, the gateway of the segment should be the same in the user-workload.