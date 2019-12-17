defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  @ex1 """
  ..#..........
  ..#..........
  #######...###
  #.#...#...#.#
  #############
  ..#...#...#..
  ..#####...^..
  """

  def build_map([], map, _loc), do: map

  def build_map([<<c>> | rest], map, loc) do
    {new_map, new_loc} = Bot.update_state(c, map, loc)
    build_map(rest, new_map, new_loc)
  end

  test "alignment params" do
    map = build_map(String.graphemes(@ex1), %{}, {0, 0})
    Bot.print(map)
    assert Bot.compute_params(map) == 76
  end

  test "part1" do
    assert Day17.part1() == 3936
  end
end
