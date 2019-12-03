defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "parse input" do
    input = "R8,U5,L5,D3\nU7,R6,D4,L4\n"
    expected = {[{"R",8}, {"U",5}, {"L",5}, {"D", 3}],
      [{"U",7}, {"R",6}, {"D",4}, {"L",4}]}
    assert Day03.parse_input(input) == expected
  end

  test "wire points" do
    assert Day03.wire_points([{"R",2}]) == MapSet.new([{0, 0}, {1, 0}, {2, 0}])
    assert Day03.wire_points([{"L",2}]) == MapSet.new([{0, 0}, {-1, 0}, {-2, 0}])
    assert Day03.wire_points([{"U",2}]) == MapSet.new([{0, 0}, {0, 1}, {0, 2}])
    assert Day03.wire_points([{"D",2}]) == MapSet.new([{0, 0}, {0, -1}, {0, -2}])
  end

  test "closest intersection" do
    input = "R8,U5,L5,D3\nU7,R6,D4,L4\n"
    result = Day03.parse_input(input)
    assert Day03.intersection_distance(result) == 6

    input = "R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83"
    result = Day03.parse_input(input)
    assert Day03.intersection_distance(result) == 159

    input = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    result = Day03.parse_input(input)
    assert Day03.intersection_distance(result) == 135
  end
end
