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
  Compute the total energy of a system
  """
  def total_energy(system) do
    Enum.reduce(system, 0, fn ({v, p}, acc) -> acc + (energy(v) * energy(p)) end)
  end

  defp energy({x, y, z}), do: abs(x) + abs(y) + abs(z)

  @doc """
  Simulate system for a number of steps
  """
  def simulate(pos, steps) do
    Enum.zip(pos, Stream.cycle([{0, 0, 0}]))
    |> sim2(steps)
  end

  defp sim2(pos, 0), do: pos
  defp sim2(pos, steps) do
    Enum.map(pos, &(gravity(&1, pos, &1)))
    |> Enum.map(&(velocity(&1)))
    |> sim2(steps-1)
  end

  defp velocity({{x, y, z}, v={vx, vy, vz}}), do: {{x+vx, y+vy, z+vz}, v}

  defp gravity(_curr, [], acc), do: acc
  defp gravity(curr={{cx, cy, cz}, _vel}, [{{px, py, pz}, _vel2} | rest], {pos, {nx, ny, nz}}) do
    gravity(curr, rest, {pos, {nx + delta(cx, px), ny + delta(cy, py), nz + delta(cz, pz)}})
  end

  defp delta(c, p) when c < p, do: 1
  defp delta(c, p) when c > p, do: -1
  defp delta(_, _), do: 0

end
