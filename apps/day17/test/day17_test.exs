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

  def build_map([], map, _loc, _bot, _dir), do: map

  def build_map([<<c>> | rest], map, loc, bot, dir) do
    {new_map, new_loc, new_bot, new_dir} = Bot.update_state(c, map, loc, bot, dir)
    build_map(rest, new_map, new_loc, new_bot, new_dir)
  end

  test "alignment params" do
    map = build_map(String.graphemes(@ex1), %{}, {0, 0}, nil, nil)
    assert Bot.compute_params(map) == 76
  end

  test "part1" do
    assert Day17.part1() == 3936
  end

  test "part2" do
    assert Day17.part2() == 785733
  end
end
