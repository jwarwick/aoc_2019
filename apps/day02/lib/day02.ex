defmodule Day02 do
  @moduledoc """
  AoC 2019, Day 2
  """

  @doc """
  Compute return value for Part 1 intcode program
  """
  def part1 do
    result =
      Util.priv_file(:day02, "day2_input.txt")
      |> Util.read_intcode()
      |> run(12, 2)

    result[0]
  end

  @doc """
  Compute noun, verb value for Part 2 incode program
  """
  def part2 do
    target = 19_690_720

    prog =
      Util.priv_file(:day02, "day2_input.txt")
      |> Util.read_intcode()

    steps = prog |> Map.keys() |> Enum.count()

    for noun <- 0..(steps - 1) do
      for verb <- 0..(steps - 1) do
        result = run(prog, noun, verb)

        if target == result[0] do
          IO.puts("Found match. Noun=#{noun}, Verb=#{verb}")
          ans = 100 * noun + verb
          IO.puts("Answer: #{ans}")
        end
      end
    end

    IO.puts("Done")
  end

  @doc """
  Execute an intcode program
  """
  def run(prog) do
    step(0, prog)
  end

  @doc """
  Execute an intcode program with noun, verb inputs
  """
  def run(prog, noun, verb) do
    Map.merge(prog, %{1 => noun, 2 => verb})
    |> run()
  end

  defp step(pc, prog) do
    op = Map.get(prog, pc)

    case eval(op, pc, prog) do
      {:halt, state} -> state
      {:ok, state} -> step(pc + 4, state)
    end
  end

  # Halt, Opcode 99
  defp eval(99, _pc, prog) do
    {:halt, prog}
  end

  # Add, Opcode 1
  defp eval(1, pc, prog) do
    {a, b, out} = get_args(pc, prog)
    # IO.puts "Add #{a} + #{b} into #{out}"
    {:ok, Map.put(prog, out, a + b)}
  end

  # Multiply, Opcode 2
  defp eval(2, pc, prog) do
    {a, b, out} = get_args(pc, prog)
    # IO.puts "Mult #{a} * #{b} into #{out}"
    {:ok, Map.put(prog, out, a * b)}
  end

  # Unknown opcode
  defp eval(op, pc, prog) do
    IO.puts("Unknown opcode: #{op} at location #{pc}")
    {:halt, prog}
  end

  defp get_args(pc, prog) do
    {prog[prog[pc + 1]], prog[prog[pc + 2]], prog[pc + 3]}
  end
end
