defmodule Intcode.State do
  @moduledoc """
  Internal state of a running Intcode program
  """
  alias Intcode.Instruction
  alias Intcode.State

  defstruct [
    pc: 0,
    prog: %{},
    input: [],
    input_fn: nil,
    output_fn: nil
  ]

  @doc """
  Evaluate the current expression
  """
  def eval(s = %State{}) do
    op = Map.get(s.prog, s.pc)
    Instruction.evaluate(op, s)
  end

  @doc """
  Update program memory and program counter
  """
  def update(s=%State{}, map) do
    Map.merge(s, map)
  end

end
