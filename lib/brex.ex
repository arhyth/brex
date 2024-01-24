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
    |> Stream.transform("", &into_valid_chunks/2)
    |> Flow.from_enumerable(stages: 4, max_demand: 4, min_demand: 3)
    |> Flow.flat_map(&Brex.Parser.parse/1)
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
        Enum.reduce(cities, all, fn {ct, stat}, accumulated ->
          %{min: mn, max: mx, count: c, sum: s} = stat
          Map.update(
            accumulated,
            ct,
            %{min: mn, max: mx, count: c, sum: s},
            fn %{min: amn, max: amx, count: ac, sum: as} ->
              amn = if mn < amn, do: mn, else: amn
              amx = if mx > amx, do: mx, else: amx
              %{min: amn, max: amx, count: ac + c, sum: as + s}
            end
          )
        end)
    end)
  end

  def into_valid_chunks("" = suchempty, leftover), do: {[leftover], suchempty}
  def into_valid_chunks(chunk, leftover) do
    {valid, newleftover} = first_line(chunk)
    emit = <<leftover::binary, valid::binary>>
    {[emit], newleftover}
  end

  def first_line(bitstring) do
    first_line("", bitstring)
  end

  defp first_line(line, <<10, leftover::binary>>), do: {<<line::binary, 10>>, leftover}
  defp first_line(line, <<b::size(8), leftover::binary>>), do: first_line(<<line::binary, b>>, leftover)
end
