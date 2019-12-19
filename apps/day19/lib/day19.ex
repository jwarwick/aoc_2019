defmodule Day19 do
  @moduledoc """
  AoC 2019, Day 19 - Tractor Beam
  """

  @doc """
  Number of points affected by the tractor beam
  """
  def part1 do
    Util.priv_file(:day19, "day19_input.txt")
    |> count_points(49, 49)
  end

  def count_points(path, max_x, max_y) do
    program = File.read!(path)
              |> Intcode.parse()
    for x <- 0..max_x, y <- 0..max_y do
      Task.async(fn -> check_point(program, x, y) end)
    end
    |> Enum.map(&(Task.await(&1)))
    |> Enum.sum()
  end

  def check_point(program, x, y) do
    Intcode.run(program, [x, y], nil, &(send(self(), &1)))
    receive do
      val -> IO.inspect({x, y, val})
        val
    end
  end
end
