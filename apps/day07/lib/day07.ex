defmodule Day07 do
  @moduledoc """
  AoC 2017, Day 7 - Amplification Circuit
  """

  @doc """
  Find largest output signal that can be sent to thrusters
  """
  def part1 do
    Util.priv_file(:day07, "day7_input.txt")
    |> Intcode.load()
    |> max_thrust(0..4)
  end

  @doc """
  Find the max thrust
  """
  def max_thrust(prog, phases) do
    Enum.into(phases, [])
    |> permutations()
    |> Enum.map(&(compute_thrust(prog, &1)))
    |> Enum.max()
  end

  @doc """
  Compute the output signal sent to the thrusters for a given phase setting
  """
  def compute_thrust(prog, [first | rest]) do
    rev_phase = Enum.reverse(rest)
    b_pid = Enum.reduce(rev_phase, self(),
                                        fn (p, next_pid) -> 
                                          Process.spawn(Intcode, :run,
                                                        [prog, [p],
                                                         fn () -> receive do x->x end end,
                                                         &(send(next_pid, &1))],
                                                         [])
                                        end)
    Process.spawn(Intcode, :run,
                  [prog, [first, 0],
                   nil,
                   &(send(b_pid, &1))],
                   [])
    receive do
      x -> x
    end
  end

  defp permutations([]), do: [[]]
  defp permutations(list), do: for elem <- list, rest <- permutations(list--[elem]), do: [elem|rest]
end
