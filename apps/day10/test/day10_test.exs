defmodule Day10Test do
  use ExUnit.Case
  doctest Day10
  # alias Day10.SpaceMap

  @ex1 """
  .#..#
  .....
  #####
  ....#
  ...##
  """
  test "example1" do
    s = Day10.parse(@ex1) |> Day10.find_neighbors()
    a = s.asteroids
    assert Enum.count(Map.keys(a)) == 10

    assert a[{3, 4}] == 8
    assert a[{4, 2}] == 5
    assert a[{2, 2}] == 7

    assert 8 == Day10.best(s)
  end

  @ex2 """
  ......#.#.
  #..#.#....
  ..#######.
  .#.#.###..
  .#..#.....
  ..#....#.#
  #..#....#.
  .##.#..###
  ##...#..#.
  .#....####
  """
  test "example2" do
    s = Day10.parse(@ex2) |> Day10.find_neighbors()
    a = s.asteroids
    assert a[{5, 8}] == 33
    assert 33 = Day10.best(s)
  end

  @ex5 """
  .#..##.###...#######
  ##.############..##.
  .#.######.########.#
  .###.#######.####.#.
  #####.##.#.##.###.##
  ..#####..#.#########
  ####################
  #.####....###.#.#.##
  ##.#################
  #####.##.###..####..
  ..######..##.#######
  ####.##.####...##..#
  .#####..#.######.###
  ##...#.##########...
  #.##########.#######
  .####.#.###.###.#.##
  ....##.##.###..#####
  .#.#.###########.###
  #.#.#.#####.####.###
  ###.##.####.##.#..##
  """

  test "example5" do
    s = Day10.parse(@ex5) |> Day10.find_neighbors()
    a = s.asteroids
    assert a[{11, 13}] == 210
    assert 210 = Day10.best(s)
  end
end
