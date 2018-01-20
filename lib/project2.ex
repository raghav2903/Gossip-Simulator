defmodule Project2 do
    
    def main(args) do
        #Read command line arguements
        {_,argList,_} = OptionParser.parse(args)
        [numNodes | [topology | [algorithm | _]]] = argList
        Server.init(String.to_integer(numNodes), topology, algorithm)
    end

end