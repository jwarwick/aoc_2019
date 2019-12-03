defmodule Day03 do
  @moduledoc """
  AoC 2019, Day 3 - Crossed Wires
  """

  @doc """
  Find the distance to the closes intersection point
  """
  def part1 do
    eval(&intersection_distance/1)
  end

  @doc """
  Find the distance to the shortest path intersection
  """
  def part2 do
    eval(&intersection_shortest/1)
  end

  defp eval(f) do
    Util.priv_file(:day03, "day3_input.txt")
    |> File.read!()
    |> parse_input()
    |> f.()
  end

  @doc """
  Parse a string containing two wiress
  """
  def parse_input(s) do
    [s1, s2] = String.split(s, "\n", trim: true)
    w1 = parse_wire(s1)
    w2 = parse_wire(s2)
    {w1, w2}
  end

  defp parse_wire(w) do
    String.split(w, ",", trim: true)
    |> Enum.map(&parse_point/1)
  end

  defp parse_point(p) do
    {a, b} = String.split_at(p, 1)
    {a, String.to_integer(b)}
  end

  @doc """
  Compute the ordered list of points that makes up a wire
  """
  def wire_points(w) do
    wire_points({0,0}, w, [])
  end

  defp wire_points(_loc, [], acc), do: List.flatten(Enum.reverse(acc))
  defp wire_points(loc, [inst|rest], acc) do
    pts = segment_points(loc, inst) 
    new_loc = update_loc(loc, inst)
    wire_points(new_loc, rest, [pts | acc])
  end

  defp segment_points(loc, inst={_dir, dist}) do
    point_acc(dist+1, loc, dir_mod(inst), [])
  end

  defp dir_mod({"U", _d}), do: {0, 1}
  defp dir_mod({"D", _d}), do: {0, -1}
  defp dir_mod({"L", _d}), do: {-1, 0}
  defp dir_mod({"R", _d}), do: {1, 0}

  defp point_acc(0, _loc, _mods, acc), do: tl(Enum.reverse(acc))
  defp point_acc(cnt, {x, y}, mods = {xmod, ymod}, acc) do
    point_acc(cnt-1, {x+xmod, y+ymod}, mods, [{x,y} | acc])
  end

  defp update_loc({x, y}, {"U", dist}), do: {x, y+dist}
  defp update_loc({x, y}, {"D", dist}), do: {x, y-dist}
  defp update_loc({x, y}, {"L", dist}), do: {x-dist, y}
  defp update_loc({x, y}, {"R", dist}), do: {x+dist, y}

  @doc """
  Find distance to the closest point of intersection of two wires
  """
  def intersection_distance({w1, w2}) do
    p1 = MapSet.new(wire_points(w1))
    p2 = MapSet.new(wire_points(w2))
    MapSet.intersection(p1, p2)
    |> Enum.map(&manhattan/1)
    |> Enum.sort()
    |> hd()
  end

  defp manhattan({x,y}), do: abs(x) + abs(y)

  @doc """
  Find length of the shortest path to an intersection of two wires
  """
  def intersection_shortest({w1, w2}) do
    l1 = wire_points(w1)
    l2 = wire_points(w2)
    p1 = MapSet.new(wire_points(w1))
    p2 = MapSet.new(wire_points(w2))
    MapSet.intersection(p1, p2)
    |> Enum.map(fn loc -> combined_length(loc, l1, l2) end)
    |> Enum.sort()
    |> hd()
  end

  defp combined_length(loc, w1, w2) do
    path_length(loc, w1, 0) + path_length(loc, w2, 0)
  end

  defp path_length({x, y}, [{x, y} | _rest], acc) do
    acc + 1
  end
  defp path_length(loc, [_hd | rest], acc) do
    path_length(loc, rest, acc+1)
  end

end
