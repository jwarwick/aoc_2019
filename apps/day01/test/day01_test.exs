defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "required fuel" do
    assert Day01.required_fuel(12) == 2
    assert Day01.required_fuel(14) == 2
    assert Day01.required_fuel(1969) == 654
    assert Day01.required_fuel(100756) == 33583
  end

  test "summed fuel" do
    assert Day01.summed_fuel(14) == 2
    assert Day01.summed_fuel(1969) == 966
    assert Day01.summed_fuel(100756) == 50346
  end
end
