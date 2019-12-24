defmodule Day24 do
  @moduledoc """
  AoC 2019, Day 24 - Planet of Discord
  """

  @doc """
  Calculate biodiversity rating for input
  """
  def part1 do
    Util.priv_file(:day24, "day24_input.txt")
    |> File.read!()
    |> first_repeated_bio()
  end

  def first_repeated_bio(str) do
    parse(str)
    |> step(MapSet.new())
  end

  defp step(map, seen) do
    bio = biodiversity(map)
    if MapSet.member?(seen, bio) do
      bio
    else
      step(next_map(map), MapSet.put(seen, bio))
    end
  end

  defp next_map(map) do
    Enum.into([], map)
    |> Enum.map(&(update_node(&1, map)))
    |> Enum.into(%{})
  end

  defp update_node({loc, val}, map) do
    cnt = neighbors(loc)
          |> Enum.map(fn pt -> Map.get(map, pt, :empty) end)
          |> Enum.reduce(0, fn (v, acc) -> if :empty == v, do: acc, else: acc+1 end)
    new_val = cond do
      val == :bug && cnt != 1 -> :empty
      val == :empty && (cnt == 1 || cnt == 2) -> :bug
      true -> val
    end
    {loc, new_val}
  end

  defp biodiversity(map) do
    Map.keys(map)
    |> Enum.sort_by(&sort_keys/1)
    |> Enum.with_index()
    |> Enum.reduce(0, &(bio_node(map, &1, &2)))
  end

  defp bio_node(map, {loc, idx}, acc) do
    v = Map.get(map, loc, :empty)
    if v == :empty do
      acc
    else
      acc + :math.pow(2, idx)
    end
  end

  defp sort_keys({x, y}), do: {y, x}

  defp parse(str) do
    String.split(str, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(&parse_row/1)
    |> List.flatten()
    |> Enum.into(%{})
  end

  defp parse_row({str, row}) do
    String.graphemes(str)
    |> Enum.map(fn c -> if c == ".", do: :empty, else: :bug end)
    |> Enum.with_index()
    |> Enum.map(fn {v, c} -> {{c, row}, v} end)
  end

  defp neighbors({x, y}), do: [{x+1, y}, {x-1, y}, {x, y+1}, {x, y-1}]
end
