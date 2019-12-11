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

  test "part1" do
    assert 247 == Day10.part1()
  end

  test "vaporize" do
    s = Day10.parse(@ex5) 
    assert 802 == Day10.vaporize_checksum(s, 200)
  end

  # with additional South asteroids
  @part2ex """
  .#....#####...#..
  ##...##.#####..##
  ##...#...#.#####.
  ..#.....X...###..
  ..#.#...#.#....##
  """
  test "laser sample" do
    order = [801, 900, 901, 1000, 902, 1101, 1201, 1102, 1501,
             1202, 1302, 1402, 1502, 1203, 1604, 1504, 1004, 804, 404,
             204, 203, 2, 102, 1, 101, 502, 100, 501,
             601, 600, 700, 800, 1001, 1400, 1601, 1303, 1403
    ]
    for i <- 1..Enum.count(order) do
      assert {i, Enum.at(order, i-1)} == {i, test_vape(i)}
    end
  end

  def test_vape(cnt) do
    Day10.parse(@part2ex)
    |> Day10.vaporize_checksum({8,3}, cnt)
  end

end
