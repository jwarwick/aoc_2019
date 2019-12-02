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
      |> Map.merge(%{1 => 12, 2 => 2})
      |> run()

    result[0]
  end

  @doc """
  Execute an intcode program
  """
  def run(prog) do
    step(0, prog)
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
    {:ok, Map.put(prog, out, a + b)}
  end

  # Multiply, Opcode 2
  defp eval(2, pc, prog) do
    {a, b, out} = get_args(pc, prog)
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
