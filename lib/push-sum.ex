defmodule PushSum do
    use GenServer
    @w 1
    @ratioCount 0
    @threshold 0.0000000001

    def init({:ok, actorNO, masterPID, total}) do
        list = [actorNO/1, @w/1, actorNO/1, @ratioCount, masterPID, total, 0]   #[s, w, s/w, count of no change in s/w, masterPID, total number of nodes, done flag]
        {:ok, list}   
    end

    #add PID of neighbours to list
    def handle_cast({:neighbours, pidList}, list) do
        list = List.insert_at(list, -1, pidList)
        {:noreply, list}
    end

    #Server asks node to start push-sum
    def handle_cast({:start}, list) do
        s = List.first(list)
        w = Enum.at(list, 1)
        neighbourList = List.last(list)
        if length(neighbourList) == 0 do
            number = Enum.random(1..Enum.at(list, 5))
            GenServer.cast(:"actor#{number}", {:pushsum, s/2, w/2})
        else
            GenServer.cast(Enum.random(neighbourList), {:pushsum, s/2, w/2})
        end
        list = List.update_at(list, 0, &(&1/2))
        list = List.update_at(list, 1, &(&1/2))
        {:noreply, list}
    end

    #Handle push-sum msg
    def handle_cast({:pushsum, s, w}, list) do
        if Enum.at(list, 6) == 0 do        
            list = List.update_at(list, 0, &(&1 + s))
            list = List.update_at(list, 1, &(&1 + w))

            s = List.first(list)
            w = Enum.at(list, 1)
            oldRatio = Enum.at(list, 2)
            newRatio = s/w
            diff = oldRatio - newRatio
            list = List.replace_at(list, 2, newRatio)
            neighbourList = List.last(list)
            length = length(neighbourList)

            if(diff > @threshold) do
                case length do
                    0 -> 
                        numNodes = Enum.at(list, 5) 
                        if numNodes > 2 do
                            iterations = Enum.random(2..5)
                            Enum.map(1..iterations, fn i -> 
                                                    num = Enum.random(1..numNodes)
                                                    GenServer.cast(:"actor#{num}", {:pushsum, s/2, w/2})
                                                end)
                        else
                            num = Enum.random(1..numNodes)
                            GenServer.cast(:"actor#{num}", {:pushsum, s/2, w/2}) 
                        end
                    1 ->
                        GenServer.cast(List.first(neighbourList), {:pushsum, s/2, w/2}) 
                    2 ->
                        GenServer.cast(Enum.random(neighbourList), {:pushsum, s/2, w/2})
                    _ ->
                        iterations = Enum.random(1..3)
                        Enum.map(1..iterations, fn i -> GenServer.cast(Enum.random(neighbourList), {:pushsum, s/2, w/2}) end)
                end
                list = List.update_at(list, 0, &(&1/2))
                list = List.update_at(list, 1, &(&1/2))
                count = Enum.at(list, 3)
                if count > 0 do
                    list = List.update_at(list, 3, &(&1 - count))
                end
            else
                list = List.update_at(list, 3, &(&1 + 1))
                count = Enum.at(list, 3)
                if(count == 3) do
                    masterPID = Enum.at(list, 4)
                    GenServer.cast(masterPID, {:done})
                    list = List.update_at(list, 6, &(&1 + 1))
                else
                    case length do
                        0 -> 
                            numNodes = Enum.at(list, 5) 
                            if numNodes > 2 do
                                iterations = Enum.random(1..3)
                                Enum.map(1..iterations, fn i -> 
                                                        num = Enum.random(1..numNodes)
                                                        GenServer.cast(:"actor#{num}", {:pushsum, s/2, w/2})
                                                    end)
                            else
                                num = Enum.random(1..numNodes)
                                GenServer.cast(:"actor#{num}", {:pushsum, s/2, w/2}) 
                            end
                        1 ->
                            GenServer.cast(List.first(neighbourList), {:pushsum, s/2, w/2}) 
                        2 ->
                            GenServer.cast(Enum.random(neighbourList), {:pushsum, s/2, w/2})
                        _ ->
                            iterations = Enum.random(3..length)
                            Enum.map(1..iterations, fn i -> GenServer.cast(Enum.random(neighbourList), {:pushsum, s/2, w/2}) end)
                    end
                    list = List.update_at(list, 0, &(&1/2))
                    list = List.update_at(list, 1, &(&1/2))
                end
            end
        else
            s = List.first(list)
            w = Enum.at(list, 1)
            neighbourList = List.last(list)
            length = length(neighbourList)
            case length do
                0 -> 
                    numNodes = Enum.at(list, 5) 
                    if numNodes > 2 do
                        iterations = Enum.random(2..5)
                        Enum.map(1..iterations, fn i -> 
                                                num = Enum.random(1..numNodes)
                                                GenServer.cast(:"actor#{num}", {:pushsum, s/2, w/2})
                                            end)
                    else
                        num = Enum.random(1..numNodes)
                        GenServer.cast(:"actor#{num}", {:pushsum, s/2, w/2}) 
                    end
                1 ->
                    GenServer.cast(List.first(neighbourList), {:pushsum, s/2, w/2}) 
                2 ->
                   GenServer.cast(Enum.random(neighbourList), {:pushsum, s/2, w/2})
                _ ->
                    iterations = Enum.random(1..3)
                    Enum.map(1..iterations, fn i -> GenServer.cast(Enum.random(neighbourList), {:pushsum, s/2, w/2}) end)
            end
        end

        {:noreply, list}
    end

end