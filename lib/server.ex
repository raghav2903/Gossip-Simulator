defmodule Server do
    use GenServer
    @finishedNodes 0

    def init(numNodes, topology, algorithm) do
        #Round upto nearest square number for 2D grid implementations
        if topology == "2D" or topology == "imp2D" do
            numNodes = numNodes |> :math.sqrt() |> Float.ceil() |> round() 
            numNodes = numNodes * numNodes
        end

        #Master to track the completion of nodes
        {:ok, masterPID} = GenServer.start_link(__MODULE__, {:ok, self(), numNodes, topology}, [])
        #Create map of node number and pid of created node based on the algorithm type
        case algorithm do
            "gossip" -> nodePID = setupNodes(numNodes, %{}, Gossip, masterPID, numNodes)
            "push-sum" -> nodePID = setupNodes(numNodes, %{}, PushSum, masterPID, numNodes)
        end

        startTime = :os.system_time(:microsecond)
        #Update nodes about their neighbours
        Topology.createTopology(numNodes, topology, nodePID)
        values = Map.values(nodePID)
        pid = Enum.random(Map.values(nodePID))
    
        #Send rumour to one of the nodes
        case algorithm do
            "gossip" -> GenServer.cast(pid, {:rumour, 1})
            "push-sum" -> GenServer.cast(pid, {:start})
        end

        #Wait for convergence
        receive do
            {:stop, finishedNodes} ->
                            endTime = :os.system_time(:microsecond)
                            IO.inspect endTime - startTime 
        end
    end

    def setupNodes(numNodes, nodePID, module, masterPID, total) when numNodes <= 1 do
        {:ok, pid} = GenServer.start_link(module, {:ok, numNodes, masterPID, total}, name: :"actor#{numNodes}")
        nodePID = Map.put(nodePID, numNodes, pid)
    end
    
    def setupNodes(numNodes, nodePID, module, masterPID, total) do
        {:ok, pid} = GenServer.start_link(module, {:ok, numNodes, masterPID, total}, name: :"actor#{numNodes}")
        nodePID = Map.put(nodePID, numNodes, pid)        
        setupNodes(numNodes - 1, nodePID, module, masterPID, total)
    end
    
    def init({:ok, serverPID, numNodes, topology}) do
        {:ok, [serverPID, numNodes, topology, @finishedNodes]}
    end

    def handle_cast({:done}, list) do
        list = List.update_at(list, -1, &(&1 + 1))
        numNodes = Enum.at(list, 1)
        finishedNodes = List.last(list)

        #Update server if convergence has been reached
        if (finishedNodes / 1) > (numNodes * 0.6) do
            serverPID = List.first(list)
            send serverPID, {:stop, finishedNodes} 
        end
        {:noreply, list}
    end
end