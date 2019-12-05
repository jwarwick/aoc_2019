defmodule IntcodeTest do
  use ExUnit.Case
  import Intcode
  doctest Intcode

  test "load intcode" do
    result = load("test/files/intcode.txt")
    assert result == %{ 0=>1, 1=>0, 2=>0, 3=>3, 4=>1}
  end

  test "sample programs" do
    run_prog("1,0,0,0,99", "2,0,0,0,99")
    run_prog("2,3,0,3,99", "2,3,0,6,99")
    run_prog("2,4,4,5,99,0", "2,4,4,5,99,9801")
    run_prog("1,1,1,4,99,5,6,0,99", "30,1,1,4,2,5,6,0,99")
  end

  test "first sample" do
    prog = "1,9,10,3,2,3,11,0,99,30,40,50"
    i = parse(prog)
    result = run(i)
    assert result[0] == 3500
  end

  defp run_prog(input, output) do
    i = parse(input)
    o = parse(output)
    result = run(i)
    assert result == o
  end
end
