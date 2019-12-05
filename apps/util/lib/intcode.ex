defmodule Intcode do
  @moduledoc """
  AoC 2019 Intcode emulator
  """

  @doc """
  Read an IntCode file
  """
  @spec load(Path.t()) :: map()
  def load(file) do
    {:ok, contents} = File.read(file)
    parse(contents)
  end

  @doc """
  Parse an IntCode string
  """
  @spec parse(String.t()) :: map()
  def parse(str) do
    String.trim(str)
    |>String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn ({val, idx}, acc) -> Map.put(acc, idx, val) end)
  end

  @doc """
  Execute an intcode program
  """
  def run(prog, input \\ []) do
    step(0, prog, input)
  end

  @doc """
  Execute an intcode program with noun, verb inputs
  """
  def run(prog, noun, verb) do
    Map.merge(prog, %{1 => noun, 2 => verb})
    |> run()
  end

  defp step(pc, prog, input) do
    op = Map.get(prog, pc)

    case eval(op, pc, prog, input) do
      {:halt, state, _new_input} -> state
      {:ok, state, new_input} -> step(pc + op_size(op), state, new_input)
    end
  end

  # Halt, Opcode 99
  defp eval(99, _pc, prog, input) do
    {:halt, prog, input}
  end

  # Add, Opcode 1
  defp eval(1, pc, prog, input) do
    {a, b, out} = get_args(pc, prog)
    # IO.puts "Add #{a} + #{b} into #{out}"
    {:ok, Map.put(prog, out, a + b), input}
  end

  # Multiply, Opcode 2
  defp eval(2, pc, prog, input) do
    {a, b, out} = get_args(pc, prog)
    # IO.puts "Mult #{a} * #{b} into #{out}"
    {:ok, Map.put(prog, out, a * b), input}
  end

  # Input, Opcode 3
  defp eval(3, pc, prog, [head|tail]) do
    loc = prog[pc+1]
    {:ok, Map.put(prog, loc, head), tail}
  end
  defp eval(3, pc, prog, input) do
    IO.puts("Error: Input opcode used without any input specified @ pc #{pc}")
    {:halt, prog, input}
  end

  # Output, Opcode 4
  defp eval(4, pc, prog, input) do
    IO.inspect(prog[prog[pc+1]])
    {:ok, prog, input}
  end

  # Unknown opcode
  defp eval(op, pc, prog, input) do
    IO.puts("Error: Unknown opcode #{inspect op} @ #{pc}")
    {:halt, prog, input}
  end

  defp get_args(pc, prog) do
    {prog[prog[pc + 1]], prog[prog[pc + 2]], prog[pc + 3]}
  end

  @op_sizes %{0=>4, 1=>4, 2=>4, 3=>2, 4=>2, 99=>1}
  defp op_size(x), do: @op_sizes[x]
  
  # for o <- [{0, 4}, {1, 4}, {2, 4}, {3, 2}, {4, 2}, {99, 1}] do
  #   {op, size} = o
  #   IO.inspect o
  #   quote do
  #     def op_size(unquote(op)), do: unquote(size)
  #   end
  # end
end
