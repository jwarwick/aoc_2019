defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  @ex1 [{-1, 0, 2}, {2, -10, -7}, {4, -8, 8}, {3, 5, -1}]

  test "example1" do
    assert Day12.simulate(@ex1, 1) == 
      [{{2, -1, 1}, {3,-1,-1}},
       {{3, -7, -4}, {1, 3, 3}},
       {{1, -7, 5}, {-3, 1, -3}},
       {{2, 2, 0}, {-1, -3, 1}}]

    assert Day12.simulate(@ex1, 10) ==
      [{{2, 1, -3}, {-3, -2, 1}},
       {{1, -8, 0}, {-1, 1, 3}},
       {{3, -6, 1}, {3, 2, -3}},
       {{2, 0, 4}, {1, -1, -1}}]

    assert Day12.simulate(@ex1, 10) |> Day12.total_energy() == 179
  end

  @ex2 [{-8, -10, 0}, {5, 5, 10}, {2, -7, 3}, {9, -8, -3}]
  test "example2" do
    assert Day12.simulate(@ex2, 100) |> Day12.total_energy() == 1940
  end
end
