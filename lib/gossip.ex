defmodule Gossip do
    use GenServer
    @startVal 0
    @endVal 5
    @done 0
    @randomTries 5

    def init({:ok, actorNO, masterPID, total}) do
        {:ok, [@startVal, @endVal, masterPID, @done, total]}      #[initial gossip count, max gossip count, masterPID, done flag, numNodes]
    end

    #add PID of neighbours to list
    def handle_cast({:neighbours, pidList}, list) do
        list = List.insert_at(list, -1, pidList)
        {:noreply, list}
    end

    def handle_cast({:rumour, rumour}, list) do
        if Enum.at(list, 3) == 0 do
            #update gossip count
            list = List.update_at(list, 0, &(&1 + 1))
            
            #check if endVal has been reached
            gossipCount = List.first(list)
            maxCount = Enum.at(list, 1)
            neighbourList = List.last(list)
            if gossipCount == maxCount do
                #Update master about completion
                masterPID = Enum.at(list, 2)
                GenServer.cast(masterPID, {:done})
                list = List.update_at(list, 3, &(&1 + 1))
            end
            #transmit gossip to random neighbour
            length = length(neighbourList)
            case length do
                0 -> 
                    numNodes = Enum.at(list, 4) 
                    if numNodes > 2 do
                        iterations = Enum.random(2..5)
                        Enum.map(1..iterations, fn i -> 
                                                num = Enum.random(1..numNodes)
                                                GenServer.cast(:"actor#{num}", {:rumour, 1}) 
                                            end)
                    else
                        num = Enum.random(1..numNodes)
                        GenServer.cast(:"actor#{num}", {:rumour, 1}) 
                    end
                1 ->
                    GenServer.cast(List.first(neighbourList), {:rumour, 1}) 
                2 ->
                    GenServer.cast(List.first(neighbourList), {:rumour, 1})
                    GenServer.cast(List.last(neighbourList), {:rumour, 1})
                _ ->
                    iterations = Enum.random(3..length)
                    Enum.map(1..iterations, fn i -> GenServer.cast(Enum.random(neighbourList), {:rumour, 1}) end)
            end
        end
        {:noreply, list}
    end

end