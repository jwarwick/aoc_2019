defmodule Day10 do
  @moduledoc """
  AoC 2019, Day 10 - Monitoring Station
  """

  defmodule SpaceMap do
    defstruct text: "", asteroids: %{}, rows: 1, cols: 1

    def print(map), do: IO.puts "#{map.text}"

    def print_neighbors(map) do
      for c <- 0..map.cols-1 do
        for r <- 0..map.rows-1 do
          IO.write("#{Map.get(map.asteroids, {r, c}, '.')}")
        end
        IO.write("\n")
      end
    end

  end

  alias Day10.SpaceMap

  @doc """
  How many asteroids can be detected from the best position?
  """
  def part1 do
    Util.priv_file(:day10, "day10_input.txt")
    |> File.read!()
    |> parse()
    |> find_neighbors()
    |> best()
  end

  @doc """
  Return the number visible at the best position
  """
  def best(map) do
    Enum.max(Map.values(map.asteroids))
  end

  @doc """
  Compute the visible neighbors for all asteroids
  """
  def find_neighbors(map) do
    keys = Map.keys(map.asteroids)
    new_neighbors = Enum.reduce(keys, %{}, fn (k, acc) -> Map.put(acc, k, neighbor_count(k, keys)) end)
    %SpaceMap{map | asteroids: new_neighbors}
  end

  def neighbor_count(k, all), do: neighbor_count(k, all, [])

  def neighbor_count(_k, [], acc), do: Enum.uniq(acc) |> Enum.count()
  def neighbor_count(k, [k | rest], acc), do: neighbor_count(k, rest, acc)
  def neighbor_count(k = {c, kr}, [{c, hr} | rest], acc) when hr < kr, do: neighbor_count(k, rest, ["N" | acc])
  def neighbor_count(k = {c, _kr}, [{c, _hr} | rest], acc), do: neighbor_count(k, rest, ["S" | acc])
  def neighbor_count(k = {kc, kr}, [{hc, hr} | rest], acc) do
    slope = (hr - kr)/(hc - kc)
    neighbor_count(k, rest, [{hr<kr, hc<kc, slope} | acc])
  end

  @doc """
  Parse an asteroid map
  """
  def parse(str) do
    data =
      String.split(str, "\n", trim: true)
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&Enum.with_index/1)

    asteroids = Enum.with_index(data)
                |> Enum.map(&filter_row/1)
                |> List.flatten()
                |> Enum.into(%{}, fn x -> {x, 0} end)

    %SpaceMap{text: str, asteroids: asteroids, rows: Enum.count(data), cols: hd(data) |> Enum.count()}
  end

  defp filter_row({l, row}) do
    Enum.reverse(l)
    |> Enum.reduce([],
                fn ({val, col}, acc) ->
                  if val == ?# do
                    [{col, row} | acc]
                  else
                    acc
                  end
                end)
  end
end
