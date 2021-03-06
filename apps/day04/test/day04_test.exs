defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "monotonic" do
    assert Day04.monotonic?(111_111) == true
    assert Day04.monotonic?(223_450) == false
    assert Day04.monotonic?(123_789) == true
  end

  test "repeat" do
    assert Day04.has_repeat?(111_111) == true
    assert Day04.has_repeat?(223_450) == true
    assert Day04.has_repeat?(123_789) == false
  end

  test "vaild" do
    assert Day04.valid?(111_111) == true
    assert Day04.valid?(223_450) == false
    assert Day04.valid?(123_789) == false
  end

  test "part1" do
    assert Day04.part1() == 1929
  end

  test "larger run" do
    assert Day04.standalone_repeat?(112_233) == true
    assert Day04.standalone_repeat?(123_444) == false
    assert Day04.standalone_repeat?(111_122) == true
    assert Day04.standalone_repeat?(122_233) == true
    assert Day04.standalone_repeat?(222_234) == false
  end
end
