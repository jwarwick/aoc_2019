defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  @ex1 """
  ....#
  #..#.
  #..##
  ..#..
  #....
  """
  
  test "ex1" do
    assert Day24.first_repeated_bio(@ex1) == 2129920
  end

  test "part1" do
    assert Day24.part1() == 32511025
  end

  test "ex2" do
    assert Day24.recursive_bug_count(@ex1, 10) == 99
  end

  test "part2" do
    assert Day24.part2() == 1932
  end
end
