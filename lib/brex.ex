defmodule Brex do
  @moduledoc """
  1brc in Elixir
  """

  @doc """
  Aggregate measurements file
  """
  def aggregate(fname) do
    fname
    |> File.stream!([], 4 * 4096)
    |> Stream.transform("", fn chunk, leftover ->
      case String.chunk(chunk, :valid) do
        [invalid, valid, invalid_too] ->
          {[<<leftover::binary, invalid::binary, valid::binary>>], invalid_too}
        [valid, invalid] ->
          {[<<leftover::binary, valid::binary>>], invalid}
        [_same_chunk] ->
          Brex.Parser.into_valid_chunks(chunk, leftover)
        end
    end)
    |> Flow.from_enumerable(stages: 4, max_demand: 2, min_demand: 1)
    |> Flow.flat_map(&Brex.Parser.parse/1)
    |> Flow.partition(key: {:elem, 0}, stages: 100)
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
    |> Enum.reduce(%{}, fn cities, all ->
      Map.merge(all, cities)
    end)
  end
end
