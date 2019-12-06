defmodule Day06 do
  @moduledoc """
  AoC 2019, Day 6 - Universal Orbit Map
  """

  @doc """
  Total number of direct and indirect orbits
  """
  def part1 do
    load_graph()
    |> orbit_checksum()
  end

  defp load_graph do
    Util.priv_file(:day06, "day6_input.txt")
    |> File.read!()
    |> parse_graph()
  end

  @doc """
  Parse a graph string
  """
  def parse_graph(s) do
    String.split(s, "\n", trim: true)
    |> Enum.map(&(String.split(&1, ")", trim: true)))
    |> Enum.reduce(Graph.new(), &add_edge/2)
  end

  defp add_edge([a, b], graph) do
    Graph.add_edge(graph, b, a)
  end

  @doc """
  Compute the Orbit Count Checksum
  """
  def orbit_checksum(g) do
    Enum.reduce(Graph.vertices(g), 0, fn (v, acc) -> acc + depth(g, v) end)
  end

  defp depth(_g, "COM"), do: 0
  defp depth(g, v) do
    Graph.get_shortest_path(g, v, "COM")
    |> Enum.count()
    |> Kernel.-(1)
  end
end
