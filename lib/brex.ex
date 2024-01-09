defmodule Brex do
  @moduledoc """
  Documentation for `Brex`.
  """

  @doc """
  Aggregate measurements file

  ## Examples

      iex> Brex.aggregate("/measurements.txt")
      [
        "Ankara" => %{
          count: 2420864,
          max: 61.2,
          min: -35.5,
          sum: 29062101.30000199
        },
        "Lagos" => %{
          count: 2424826,
          max: 75.4,
          min: -23.9,
          sum: 64968854.600000165
        },
        "Madrid" => %{count: 2421767, max: 63.0, min: -36.6, sum: 36320123.4000006},
        "New Orleans" => %{count: 2422440, max: 69.2, min: -28.7, sum: 50132458.49999849},
        ...

  """
  def aggregate(fname) do
    fname
    |> File.stream!(read_ahead: 10_000)
    |> Flow.from_enumerable(stages: System.schedulers_online(), max_demand: 10_000, min_demand: 1_000)
    |> Flow.map(fn raw ->
      [city, tempstr] = String.split(raw, ";")
      {city, tempstr |> String.trim_trailing() |> String.to_float()}
    end)
    |> Flow.partition(key: {:elem, 0}, stages: System.schedulers_online())
    |> Flow.reduce(
      fn -> %{} end,
      fn {city, measured}, cities ->
        Map.update(
          cities,
          city,
          %{min: measured, max: measured, count: 1, sum: measured},
          fn %{min: mn, max: mx, count: c, sum: s} ->
            mn = if measured < mn, do: measured, else: mn
            mx = if measured > mx, do: measured, else: mx
            %{min: mn, max: mx, count: c + 1, sum: s + measured}
          end
        )
      end
    )
    |> Flow.on_trigger(fn cities ->
      {[cities], cities}
    end)
    |> Enum.to_list()
  end
end
