defmodule IntcodeTest do
  use ExUnit.Case
  import Intcode
  doctest Intcode

  test "load intcode" do
    result = load("test/files/intcode.txt")
    assert result == %{0 => 1, 1 => 0, 2 => 0, 3 => 3, 4 => 1}
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

  test "modes" do
    run_prog("1002,4,3,4,33", "1002,4,3,4,99")
    run_prog("1101,100,-1,4,0", "1101,100,-1,4,99")
  end

  test "output" do
    p = parse("3,9,8,9,10,9,4,9,99,-1,8")
    s = self()
    run(p, [1], nil, &(send(s, {:output, &1})))
    assert_receive({:output, 0})

    p = parse("3,3,1107,-1,8,3,4,3,99")
    run(p, [1], nil, &(send(s, {:output, &1})))
    assert_receive({:output, 1})
  end

  test "input" do
    p = parse("3,9,8,9,10,9,4,9,99,-1,8")
    s = self()
    run(p, [], fn ()-> 1 end, &(send(s, {:output, &1})))
    assert_receive({:output, 0})

    p = parse("3,3,1107,-1,8,3,4,3,99")
    run(p, [], fn () -> 1 end, &(send(s, {:output, &1})))
    assert_receive({:output, 1})
  end

  test "relative mode" do
    s = self()

    str = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
    nums = String.split(str, ",") |> Enum.map(&String.to_integer/1)
    p = parse(str)
    run(p, [], nil, &(send(s, {:output, &1})))
    for v <- nums do
      assert_receive({:output, ^v})
    end

    p = parse("104,1125899906842624,99")
    run(p, [], nil, &(send(s, {:output, &1})))
    assert_receive({:output, 1125899906842624})

    p = parse("1102,34915192,34915192,7,4,7,99,0")
    run(p, [], nil, &(send(s, {:output, &1})))
    receive do
      {:output, num} -> assert 16 == Enum.count(Integer.digits(num))
    end

    p = parse("109,2000,103,1985,109,19,204,-34,99")
    # value at address 1985 will be output, which we read as input
    run(p, [17], nil, &(send(s, {:output, &1})))
    assert_receive({:output, 17})
  end

  defp run_prog(input, output) do
    i = parse(input)
    o = parse(output)
    result = run(i)
    assert result == o
  end
end
