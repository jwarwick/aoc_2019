defmodule Intcode do
  @moduledoc """
  AoC 2019 Intcode emulator
  """

  alias Intcode.Instruction

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
    String.replace(str, ~r/\s/, "")
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {val, idx}, acc -> Map.put(acc, idx, val) end)
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

    case Instruction.evaluate(op, pc, prog, input) do
      {:halt, new_prog, _new_input, _new_pc} -> new_prog
      {:ok, new_prog, new_input, new_pc} -> step(new_pc, new_prog, new_input)
    end
  end
end
