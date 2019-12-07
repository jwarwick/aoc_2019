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
  Find largest output signal that can be sent to thrusters in feedback mode
  """
  def part2 do
    Util.priv_file(:day07, "day7_input.txt")
    |> Intcode.load()
    |> max_feedback_thrust(5..9)
  end

  @doc """
  Find the max thrust
  """
  def max_thrust(prog, phases) do
    max_for_type(prog, phases, &compute_thrust/2)
  end

  @doc """
  Find the max thrust in the feedback loop configuration
  """
  def max_feedback_thrust(prog, phases) do
    max_for_type(prog, phases, &compute_feedback_thrust/2)
  end

  defp max_for_type(prog, phases, f) do
    Enum.into(phases, [])
    |> permutations()
    |> Enum.map(&f.(prog, &1))
    |> Enum.max()
  end

  @doc """
  Compute the output signal sent to the thrusters for a given phase setting
  """
  def compute_thrust(prog, phases) do
    [a_pid | _pids] = spawn_amps(prog, phases)
    send(a_pid, 0)

    receive do
      x -> x
    end
  end

  @doc """
  Compute the output signal sent to the thrusters in feedback mode
  """
  def compute_feedback_thrust(prog, phases) do
    [a_pid | _pids] = spawn_amps(prog, phases)
    send(a_pid, 0)
    await(a_pid)
  end

  defp await(pid) do
    receive do
      x ->
        if Process.alive?(pid) do
          send(pid, x)
          await(pid)
        else
          x
        end
    end
  end

  defp spawn_amps(prog, phases) do
    Enum.reverse(phases)
    |> Enum.reduce(
      [self()],
      fn p, others = [next_pid | _rest] ->
        pid =
          Process.spawn(
            Intcode,
            :run,
            [
              prog,
              [p],
              fn ->
                receive do
                  x -> x
                end
              end,
              &send(next_pid, &1)
            ],
            []
          )

        [pid | others]
      end
    )
  end

  defp permutations([]), do: [[]]

  defp permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])
end
