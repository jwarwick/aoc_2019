defmodule Intcode.Instruction do
  @moduledoc """
  Instructions used by the Intcode interpreter
  """

  # Halt, Opcode 99
  @doc """
  Evaluate a single instruction
  """
  def evaluate(instruction, pc, prog, input) do
    parse(instruction)
    |> eval(pc, prog, input)
  end

  defp parse(instruction), do: Integer.digits(instruction) |> parse_opcode()

  defp parse_opcode([9, 9]), do: {op_code(99), []}
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

  defp mode(0), do: :position
  defp mode(1), do: :immediate

  # Halt, Opcode 99
  defp eval({:halt, _modes}, pc, prog, input) do
    {:halt, prog, input, pc + 1}
  end

  # Add, Opcode 1
  defp eval({:add, modes}, pc, prog, input) do
    a = get_arg(1, pc, prog, modes)
    b = get_arg(2, pc, prog, modes)
    out = prog[pc + 3]
    {:ok, Map.put(prog, out, a + b), input, pc + 4}
  end

  # Multiply, Opcode 2
  defp eval({:multiply, modes}, pc, prog, input) do
    a = get_arg(1, pc, prog, modes)
    b = get_arg(2, pc, prog, modes)
    out = prog[pc + 3]
    {:ok, Map.put(prog, out, a * b), input, pc + 4}
  end

  # Input, Opcode 3
  defp eval({:input, _modes}, pc, prog, [head | tail]) do
    out = prog[pc + 1]
    {:ok, Map.put(prog, out, head), tail, pc + 2}
  end

  defp eval({:input, _modes}, pc, prog, input) do
    IO.puts("Error: Input opcode used without any input specified @ pc #{pc}")
    {:halt, prog, input, pc + 2}
  end

  # Output, Opcode 4
  defp eval({:output, modes}, pc, prog, input) do
    a = get_arg(1, pc, prog, modes)
    IO.inspect(a)
    {:ok, prog, input, pc + 2}
  end

  # Jump if True, Opcode 5
  defp eval({:jump_if_true, modes}, pc, prog, input) do
    a = get_arg(1, pc, prog, modes)
    b = get_arg(2, pc, prog, modes)

    new_pc =
      if a != 0 do
        b
      else
        pc + 3
      end

    {:ok, prog, input, new_pc}
  end

  # Jump if False, Opcode 6
  defp eval({:jump_if_false, modes}, pc, prog, input) do
    a = get_arg(1, pc, prog, modes)
    b = get_arg(2, pc, prog, modes)

    new_pc =
      if a == 0 do
        b
      else
        pc + 3
      end

    {:ok, prog, input, new_pc}
  end

  # Less Than, Opcode 7
  defp eval({:less_than, modes}, pc, prog, input) do
    a = get_arg(1, pc, prog, modes)
    b = get_arg(2, pc, prog, modes)
    out = prog[pc + 3]

    val =
      if a < b do
        1
      else
        0
      end

    {:ok, Map.put(prog, out, val), input, pc + 4}
  end

  # Equals, Opcode 7
  defp eval({:equals, modes}, pc, prog, input) do
    a = get_arg(1, pc, prog, modes)
    b = get_arg(2, pc, prog, modes)
    out = prog[pc + 3]

    val =
      if a == b do
        1
      else
        0
      end

    {:ok, Map.put(prog, out, val), input, pc + 4}
  end

  # Unknown opcode
  defp eval({op, _modes}, pc, prog, input) do
    IO.puts("Error: Unknown opcode #{inspect(op)} @ #{pc}")
    {:halt, prog, input, pc + 4}
  end

  # 1-indexed arguments, eg. first argument = 1
  defp get_arg(arg, pc, prog, modes) do
    case Enum.at(modes, arg - 1, :position) do
      :immediate -> prog[pc + arg]
      :position -> prog[prog[pc + arg]]
    end
  end

  @op_codes %{
    1 => :add,
    2 => :multiply,
    3 => :input,
    4 => :output,
    5 => :jump_if_true,
    6 => :jump_if_false,
    7 => :less_than,
    8 => :equals,
    99 => :halt
  }
  defp op_code(x), do: @op_codes[x]
end
