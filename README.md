Date: October 5th, 2015

Group Members:

1. Suhas Kumar Bharadwaj, UFID: 16120229
2. Raghav Ravishankar, UFID: 19995874

Usage:
	
	 "escript numNodes { full | 3D | line | imp3D } { gossip | push-sum }"

Working:

	1. 	Convergence of Gossip algorithm for all topologies.
	2. 	Convergence of Push-Sum algorithm for all topologies.
	
Please refer to the attached PDF file for a thorough report that covers the working of this project in detail.

Largest Network Used:
	1. For Gossip algorithm:
		a) Full network topology: 10000 nodes 
		b) 3D network topology: 10000 nodes
		c) Imperfect 3D topology: 10000 nodes
		d) Line topology: 10000 nodes

	2. For Push-Sum algorithm:
		a) Full network topology: 10000 nodes
		b) 3D network topology: 10000 nodes
		c) Imperfect 3D topology: 10000 nodes
		d) Line topology: 1000 nodes
		
Sample Outputs:
	
	escript 1000 full gossip
	
	Column1: Number of nodes
	Column2: The toplogy that is executed
	Column3: The algorithm that is to be run

