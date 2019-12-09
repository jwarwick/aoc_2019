defmodule Intcode.Instruction do
  @moduledoc """
  Instructions used by the Intcode interpreter
  """
  alias Intcode.State

  @doc """
  Evaluate a single instruction
  """
  def evaluate(instruction, s = %State{}) do
    parse(instruction)
    |> eval(s)
  end

  defp parse(instruction), do: Integer.digits(instruction) |> parse_opcode()

  defp parse_opcode([x]), do: {op_code(x), []}
  defp parse_opcode([0, x]), do: {op_code(x), []}

  defp parse_opcode(digits) do
    op =
      Enum.take(digits, -2)
      |> Integer.undigits()
      |> op_code()

    modes =
      Enum.take(digits, Enum.count(digits) - 2)
      |> Enum.reverse()
      |> Enum.map(&mode/1)

    {op, modes}
  end

  # Add, Opcode 1
  defp eval({:add, modes}, s = %State{pc: pc, prog: prog}) do
    a = get_arg(1, pc, prog, modes, s)
    b = get_arg(2, pc, prog, modes, s)
    out = prog[pc + 3]
    {:ok, State.update(s, %{prog: Map.put(prog, out, a + b), pc: pc + 4})}
  end

  # Multiply, Opcode 2
  defp eval({:multiply, modes}, s = %State{pc: pc, prog: prog}) do
    a = get_arg(1, pc, prog, modes, s)
    b = get_arg(2, pc, prog, modes, s)
    out = prog[pc + 3]
    {:ok, State.update(s, %{prog: Map.put(prog, out, a * b), pc: pc + 4})}
  end

  # Input, Opcode 3
  defp eval({:input, _modes}, s = %State{pc: pc, prog: prog, input: [head | tail]}) do
    out = prog[pc + 1]
    {:ok, State.update(s, %{prog: Map.put(prog, out, head), input: tail, pc: pc + 2})}
  end

  defp eval({:input, _modes}, s = %State{pc: pc, prog: prog, input_fn: f}) do
    out = prog[pc + 1]
    {:ok, State.update(s, %{prog: Map.put(prog, out, f.()), pc: pc + 2})}
  end

  defp eval({:input, _modes}, s = %State{pc: pc, input_fn: nil}) do
    IO.puts("Error: Input opcode used without any input specified @ pc #{pc}")
    {:halt, s}
  end

  # Output, Opcode 4
  defp eval({:output, modes}, s = %State{pc: pc, prog: prog, output_fn: f}) do
    a = get_arg(1, pc, prog, modes, s)
    f.(a)
    {:ok, State.update(s, %{pc: pc + 2})}
  end

  # Jump if True, Opcode 5
  defp eval({:jump_if_true, modes}, s = %State{pc: pc, prog: prog}) do
    a = get_arg(1, pc, prog, modes, s)
    b = get_arg(2, pc, prog, modes, s)

    new_pc = if a != 0, do: b, else: pc + 3
    {:ok, State.update(s, %{pc: new_pc})}
  end

  # Jump if False, Opcode 6
  defp eval({:jump_if_false, modes}, s = %State{pc: pc, prog: prog}) do
    a = get_arg(1, pc, prog, modes, s)
    b = get_arg(2, pc, prog, modes, s)

    new_pc = if a == 0, do: b, else: pc + 3
    {:ok, State.update(s, %{pc: new_pc})}
  end

  # Less Than, Opcode 7
  defp eval({:less_than, modes}, s = %State{pc: pc, prog: prog}) do
    a = get_arg(1, pc, prog, modes, s)
    b = get_arg(2, pc, prog, modes, s)
    out = prog[pc + 3]

    val = if a < b, do: 1, else: 0
    {:ok, State.update(s, %{prog: Map.put(prog, out, val), pc: pc + 4})}
  end

  # Equals, Opcode 8
  defp eval({:equals, modes}, s = %State{pc: pc, prog: prog}) do
    a = get_arg(1, pc, prog, modes, s)
    b = get_arg(2, pc, prog, modes, s)
    out = prog[pc + 3]

    val = if a == b, do: 1, else: 0
    {:ok, State.update(s, %{prog: Map.put(prog, out, val), pc: pc + 4})}
  end

  # Adjust Relative Base, Opcode 9
  defp eval({:adjust_base, modes}, s = %State{pc: pc, prog: prog, relative_base: base}) do
    a = get_arg(1, pc, prog, modes, s)
    {:ok, State.update(s, %{relative_base: base + a, pc: pc + 2})}
  end

  # Halt, Opcode 99
  defp eval({:halt, _modes}, s = %State{pc: pc}) do
    {:halt, State.update(s, %{pc: pc + 1})}
  end

  # Unknown opcode
  defp eval({op, _modes}, s = %State{pc: pc}) do
    IO.puts("Error: Unknown opcode #{inspect(op)} @ #{pc}")
    {:halt, s}
  end

  # 1-indexed arguments, eg. first argument = 1
  defp get_arg(arg, pc, prog, modes, %State{relative_base: base}) do
    case Enum.at(modes, arg - 1, :position) do
      :immediate -> Map.get(prog, pc + arg, 0)
      :position -> Map.get(prog, Map.get(prog, pc + arg, 0), 0)
      :relative -> Map.get(prog, Map.get(prog, pc + arg, 0) + base, 0)
    end
  end

  defp mode(0), do: :position
  defp mode(1), do: :immediate
  defp mode(2), do: :relative

  @op_codes  [
    {1, :add},
    {2, :multiply},
    {3, :input},
    {4, :output},
    {5, :jump_if_true},
    {6, :jump_if_false},
    {7, :less_than},
    {8, :equals},
    {9, :adjust_base},
    {99, :halt}]
  for {n, i} <- @op_codes do
    defp op_code(unquote(n)), do: unquote(i)
  end
end
