defmodule Mix.Tasks.Aggregate do
  @shortdoc "Aggregate city/station temp measurements"
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {ts, _} = :timer.tc(Brex, :aggregate, [args], :second)
    IO.puts("Finished aggregation in #{ts} seconds")
  end
end
