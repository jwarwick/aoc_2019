defmodule Intcode do
  @moduledoc """
  AoC 2019 Intcode emulator
  """
  alias Intcode.State

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
  Write to a program memory location
  """
  def poke(prog, addr, val) do
    Map.put(prog, addr, val)
  end

  @doc """
  Execute an intcode program
  """
  def run(prog, input \\ [], input_fn \\ nil, output_fn \\ &default_output/1) do
    s = %State{prog: prog, input: input, input_fn: input_fn, output_fn: output_fn}
    step(s)
  end

  @doc """
  Execute an intcode program with noun, verb inputs
  """
  def run_noun_verb(prog, noun, verb) do
    Map.merge(prog, %{1 => noun, 2 => verb})
    |> run()
  end

  defp step(s = %State{}) do
    case State.eval(s) do
      {:halt, %State{prog: prog}} -> prog
      {:ok, new_state} -> step(new_state)
    end
  end

  defp default_output(v), do: IO.inspect(v)
end
