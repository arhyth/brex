defmodule Mix.Tasks.Aggregate do
  @shortdoc "Aggregate city/station temp measurements"
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {ts, aggr} = :timer.tc(Brex, :aggregate, [args], :second)
    IO.write("{")
    Enum.each(aggr, fn {city, measure} ->
      avg = :erlang.float_to_binary(measure[:sum]/measure[:count]/10, [decimals: 1])
      min = :erlang.float_to_binary(measure[:min]/10, [decimals: 1])
      max = :erlang.float_to_binary(measure[:max]/10, [decimals: 1])
      IO.write("#{city}=#{min}/#{avg}/#{max},")
    end)
    IO.write("}")
    IO.puts("Finished aggregation in #{ts} seconds")
  end
end
