defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "part1" do
    assert 3_895_705 == Day02.part1()
  end

  test "sample programs" do
    run_prog("1,0,0,0,99", "2,0,0,0,99")
    run_prog("2,3,0,3,99", "2,3,0,6,99")
    run_prog("2,4,4,5,99,0", "2,4,4,5,99,9801")
    run_prog("1,1,1,4,99,5,6,0,99", "30,1,1,4,2,5,6,0,99")
  end

  test "first sample" do
    prog = "1,9,10,3,2,3,11,0,99,30,40,50"
    i = Util.parse_intcode(prog)
    result = Day02.run(i)
    assert result[0] == 3500
  end

  defp run_prog(input, output) do
    i = Util.parse_intcode(input)
    o = Util.parse_intcode(output)
    result = Day02.run(i)
    assert result == o
  end
end
