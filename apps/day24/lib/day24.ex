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

  @doc """
  Count number of bugs in recursive grid after 200 minutes
  """
  def part2 do
    Util.priv_file(:day24, "day24_input.txt")
    |> File.read!()
    |> recursive_bug_count(200)
  end

  def recursive_bug_count(str, steps) do
    parse(str)
    |> Enum.into([])
    |> Enum.map(fn {{x, y}, val} -> {{x, y, 0}, val} end)
    |> Enum.into(%{})
    |> recursive_step(steps)
    |> Map.values()
    |> Enum.filter(fn v -> v == :bug end)
    |> Enum.count()
  end

  def recursive_step(map, 0), do: map
  def recursive_step(map, step) do
    new_map = add_next_levels(map)
    Enum.into([], new_map)
    |> Enum.map(&(update_node(&1, map)))
    |> Enum.into(%{})
    |> recursive_step(step-1)
  end

  defp add_next_levels(map) do
    {{_, _, z_min}, {_, _, z_max}} = Enum.min_max_by(Map.keys(map), fn {_x, _y, z} -> z end)
    for z <- [z_min-1, z_max+1], x <- 0..4, y <- 0..4 do
      {{x, y, z}, :empty}
    end
    |> Enum.into(%{})
    |> Map.merge(map)
  end

  defp neighbors({x, y}), do: [{x+1, y}, {x-1, y}, {x, y+1}, {x, y-1}]
  defp neighbors({2, 2, _z}), do: []
  defp neighbors({0, 0, z}) do
    [{1, 0, z}, {0, 1, z}, {2, 1, z+1}, {1, 2, z+1}]
  end
  defp neighbors({4, 0, z}) do
    [{3, 0, z}, {4, 1, z}, {2, 1, z+1}, {3, 2, z+1}]
  end
  defp neighbors({0, 4, z}) do
    [{0, 3, z}, {1, 4, z}, {1, 2, z+1}, {2, 3, z+1}]
  end
  defp neighbors({4, 4, z}) do
    [{3, 4, z}, {4, 3, z}, {3, 2, z+1}, {2, 3, z+1}]
  end
  defp neighbors({0, y, z}) do
    [{0, y-1, z}, {1, y, z}, {0, y+1, z}, {1, 2, z+1}]
  end
  defp neighbors({4, y, z}) do
    [{4, y-1, z}, {3, y, z}, {4, y+1, z}, {3, 2, z+1}]
  end
  defp neighbors({x, 0, z}) do
    [{x-1, 0, z}, {x+1, 0, z}, {x, 1, z}, {2, 1, z+1}]
  end
  defp neighbors({x, 4, z}) do
    [{x-1, 4, z}, {x+1, 4, z}, {x, 3, z}, {2, 3, z+1}]
  end
  defp neighbors({2, 1, z}) do
    this = [{2, 0, z}, {1, 1, z}, {3, 1, z}]
    down = for x <- 0..4 do
      {x, 0, z-1}
    end
    List.flatten([this | down])
  end
  defp neighbors({1, 2, z}) do
    this = [{1, 1, z}, {0, 2, z}, {1, 3, z}]
    right = for y <- 0..4 do
      {0, y, z-1}
    end
    List.flatten([this | right])
  end
  defp neighbors({3, 2, z}) do
    this = [{3, 1, z}, {3, 3, z}, {4, 2, z}]
    left = for y <- 0..4 do
      {4, y, z-1}
    end
    List.flatten([this | left])
  end
  defp neighbors({2, 3, z}) do
    this = [{1, 3, z}, {3, 3, z}, {2, 4, z}]
    up = for x <- 0..4 do
      {x, 4, z-1}
    end
    List.flatten([this | up])
  end
  defp neighbors({x, y, z}), do: [{x+1, y, z}, {x-1, y, z}, {x, y+1, z}, {x, y-1, z}]

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

end
