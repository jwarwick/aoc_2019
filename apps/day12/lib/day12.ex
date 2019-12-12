defmodule Day12 do
  @moduledoc """
  AoC 2019, Day 12 - The N-body Problem
  """

  @input [{-2, 9, -5}, {16, 19, 9}, {0, 3, 6}, {11, 0, 11}]
  @part1_steps 1000

  @doc """
  Compute total energy in the system
  """
  def part1 do
    simulate(@input, @part1_steps)
    |> total_energy()
  end

  @doc """
  Find the period of the system
  """
  def part2 do
    period(@input)
  end

  @doc """
  Compute the total energy of a system
  """
  def total_energy({system, _acc}) do
    Enum.reduce(system, 0, fn ({v, p}, acc) -> acc + (energy(v) * energy(p)) end)
  end

  defp energy({x, y, z}), do: abs(x) + abs(y) + abs(z)

  @doc """
  Simulate system for a number of steps
  """
  def simulate(pos, steps) do
    start = Enum.zip(pos, Stream.cycle([{0, 0, 0}]))
    sim2(start, steps, [start])
  end

  defp sim2(pos, 0, acc), do: {pos, Enum.reverse(acc)}
  defp sim2(pos, steps, acc) do
    new_pos = Enum.map(pos, &(gravity(&1, pos, &1)))
              |> Enum.map(&(velocity(&1)))
    sim2(new_pos, steps-1, [new_pos | acc])
  end

  defp velocity({{x, y, z}, v={vx, vy, vz}}), do: {{x+vx, y+vy, z+vz}, v}

  defp gravity(_curr, [], acc), do: acc
  defp gravity(curr={{cx, cy, cz}, _vel}, [{{px, py, pz}, _vel2} | rest], {pos, {nx, ny, nz}}) do
    gravity(curr, rest, {pos, {nx + delta(cx, px), ny + delta(cy, py), nz + delta(cz, pz)}})
  end

  defp delta(c, p) when c < p, do: 1
  defp delta(c, p) when c > p, do: -1
  defp delta(_, _), do: 0

  def period(pos, steps \\ 500000) do
    {_r, acc} = simulate(pos, steps)
    x = axis_repeat(0, acc)
    y = axis_repeat(1, acc)
    z = axis_repeat(2, acc)
    Math.lcm(x, Math.lcm(y, z))
  end

  def axis_repeat(idx, acc) do
    [first | rest] = axis(idx, acc)
    1 + Enum.find_index(rest, &(&1 == first))
  end

  def axis(idx, acc) do
    Enum.map(acc, &(get_nth(&1, idx)))
  end

  defp get_nth(acc, n) do
    Enum.map(acc, fn {p, v} -> {elem(p, n), elem(v, n)} end)
  end

end
