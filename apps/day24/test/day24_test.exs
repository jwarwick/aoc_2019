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
end
