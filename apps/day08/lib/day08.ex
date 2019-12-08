defmodule Day08 do
  @moduledoc """
  AoC 2019, Day 8 - Space Image Format
  """

  @width 25
  @height 6

  @doc """
  Compute the image checksum
  """
  def part1 do
    parse()
    |> checksum()
  end

  @doc """
  Parse the input
  """
  def parse() do
    Util.priv_file(:day08, "day8_input.txt")
    |> File.read!()
    |> string_to_layers(@width, @height)
  end

  @doc """
  Turn an input image into the layer structure
  """
  def string_to_layers(str, width, height) do
    String.trim(str)
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
    |> Enum.chunk_every(width * height)
  end

  @doc """
  Compute an image checksum
  """
  def checksum(layers) do
    l =
      layers
      |> Enum.sort_by(&Enum.count(&1, fn x -> x == 0 end))
      |> hd()

    ones = Enum.count(l, &(&1 == 1))
    twos = Enum.count(l, &(&1 == 2))
    ones * twos
  end
end
