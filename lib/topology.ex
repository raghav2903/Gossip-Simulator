defmodule Topology do
    
    def createTopology(numNodes, topology, nodePID) do
        case topology do
            "full" -> fullTopology(numNodes, nodePID)
            "line" -> lineTopology(numNodes, nodePID)
            "2D" -> twoDTopology(numNodes, nodePID)
            "imp2D" -> imp_twoDTopology(numNodes, nodePID)
        end
    end

    def fullTopology(numNodes, nodePID) do
        Enum.map(1..numNodes,
        fn i ->
            GenServer.cast(Map.get(nodePID, i), {:neighbours, []})
        end)
    end

    def lineTopology(numNodes, nodePID) do
        Enum.map(1..numNodes, 
        fn i -> 
            case Integer.mod(i, numNodes) do
                1 -> GenServer.cast(Map.get(nodePID, i), {:neighbours, [Map.get(nodePID, i+1)]})
                0 -> GenServer.cast(Map.get(nodePID, i), {:neighbours, [Map.get(nodePID, i-1)]})
                _ -> GenServer.cast(Map.get(nodePID, i), {:neighbours, [Map.get(nodePID, i-1), Map.get(nodePID, i+1)]})
            end
        end)
    end

    def twoDTopology(numNodes, nodePID) do
        i = numNodes |> :math.sqrt() |> Float.ceil() |> round()
        Enum.map(1..numNodes,
            fn j ->
                list = []
                case mod(j, i) do
                    1 -> 
                        if j - i > 0 do
                            list = list ++ [Map.get(nodePID, j - i)]
                        end
                        list = list ++ [Map.get(nodePID, j + 1)]
                        if j + i <= numNodes do
                            list = list ++ [Map.get(nodePID, j + i)]
                        end
                    0 -> 
                        if j - i > 0 do
                            list = list ++ [Map.get(nodePID, j - i)]
                        end
                        list = list ++ [Map.get(nodePID, j - 1)]
                        if j + i <= numNodes do
                            list = list ++ [Map.get(nodePID, j + i)]
                        end
                    _ ->
                        if j - i > 0 do
                            list = list ++ [Map.get(nodePID, j - i)]
                        end
                        list = list ++ [Map.get(nodePID, j - 1)]
                        list = list ++ [Map.get(nodePID, j + 1)]
                        if j + i <= numNodes do
                            list = list ++ [Map.get(nodePID, j + i)]
                        end
                end
                GenServer.cast(Map.get(nodePID, j), {:neighbours, list})
            end    
        ) 
    end

    def imp_twoDTopology(numNodes, nodePID) do
        i = numNodes |> :math.sqrt() |> Float.ceil() |> round()
        Enum.map(1..numNodes,
            fn j ->
                temp = nodePID
                temp = Map.drop(temp, [j])  #2nd argument must be iterable
                list = []
                case mod(j, i) do
                    1 -> 
                        if j - i > 0 do
                            list = list ++ [Map.get(nodePID, j - i)]
                            temp = Map.drop(temp, [j - i])
                        end
                        list = list ++ [Map.get(nodePID, j + 1)]
                        temp = Map.drop(temp, [j + 1])
                        if j + i <= numNodes do
                            list = list ++ [Map.get(nodePID, j + i)]
                            temp = Map.drop(temp, [j + i])
                        end
                    0 -> 
                        if j - i > 0 do
                            list = list ++ [Map.get(nodePID, j - i)]
                            temp = Map.drop(temp, [j - i])
                        end
                        list = list ++ [Map.get(nodePID, j - 1)]
                        temp = Map.drop(temp, [j - 1])
                        if j + i <= numNodes do
                            list = list ++ [Map.get(nodePID, j + i)]
                            temp = Map.drop(temp, [j + i])
                        end
                    _ ->
                        if j - i > 0 do
                            list = list ++ [Map.get(nodePID, j - i)]
                            temp = Map.drop(temp, [j - i])
                        end
                        list = list ++ [Map.get(nodePID, j - 1)]
                        list = list ++ [Map.get(nodePID, j + 1)]
                        temp = Map.drop(temp, [j - 1, j + 1])
                        if j + i <= numNodes do
                            list = list ++ [Map.get(nodePID, j + i)]
                            temp = Map.drop(temp, [j + i])
                        end
                end
                list = List.insert_at(list, -1, Enum.random(Map.values(temp)))
                GenServer.cast(Map.get(nodePID, j), {:neighbours, list})
            end    
        ) 
    end    

    defp mod(a, b) when a >= b do
        rem(a,b)
    end

    defp mod(a, b) do
        a
    end    
    
end