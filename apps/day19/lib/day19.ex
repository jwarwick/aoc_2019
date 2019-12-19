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

  @doc """
  Find the closest 100x100 area within the beam
  """
  def part2 do
    {{{_start_col, row}, {_end_col, row}},
      {end_start_col, end_row}, {_end_end_col, end_row}} = 
        Util.priv_file(:day19, "day19_input.txt")
        |> Intcode.load()
        |> find_fit()
    y = row
    x = end_start_col
    (x * 10_000) + y
  end

  @doc """
  Binary search to find a space to fit in
  """
  def find_fit(prog) do
    min_row = 100
    max_row = 5000
    {{_start_col, start_row}, {_end_col, start_row}} = bin_search_row(prog, min_row, max_row)
    check_block(prog, start_row)
  end

  defp check_block(prog, row) do
    end_row = row+99
    beam_col = find_beam(prog, row)
    {{start_col, row}, {end_col, row}} = get_row_range(prog, row, beam_col)

    end_beam_col = find_beam(prog, end_row)
    {{end_start_col, end_row}, {end_end_col, end_row}} = get_row_range(prog, end_row, end_beam_col)

    if (end_col - end_start_col) == 99 do
      {{{start_col, row}, {end_col, row}}, {end_start_col, end_row}, {end_end_col, end_row}}
    else
      check_block(prog, row+1)
    end
  end

  defp find_beam(prog, row, col \\ 0, cnt \\ 0)
  defp find_beam(_prog, _row, _col, cnt) when cnt > 5000, do: :failed_to_find_beam
  defp find_beam(prog, row, col, cnt) do
    val = check_point(prog, col, row)
    if 1 == val do
      col
    else
      find_beam(prog, row, col+50, cnt+1)
    end
  end

  defp bin_search_row(prog, min, max, min_col \\ 50, max_col \\ 5_000) do
    row = Integer.floor_div(max-min, 2) + min
    if row < min do
      :row_below_min
    end
    beam_col = find_beam(prog, row)
    {{start_col, ^row}, {end_col, ^row}} = get_row_range(prog, row, beam_col)
    width = end_col - start_col
    cond do
      width == 100 -> {{start_col, row}, {end_col, row}}
      width < 100 -> bin_search_row(prog, row, max, start_col, max_col)
      width > 100 -> bin_search_row(prog, min, row, min_col, start_col + 400)
    end
  end

  defp get_row_range(prog, row, beam_col) do
    {start_col, ^row} = find_col_start(prog, row, 1, beam_col)
    {end_col, ^row} = find_col_end(prog, row, beam_col, 10_000)
    {{start_col, row}, {end_col, row}}
  end

  defp find_col_start(prog, row, min, max, cnt \\ 0)
  defp find_col_start(prog, row, _min, _max, cnt) when cnt > 5000 do
    IO.puts "Overshot area, resetting..."
    find_col_start(prog, row, 1, 2_500, 0)
  end
  defp find_col_start(prog, row, min, max, cnt) do
    col = Integer.floor_div(max-min, 2)+min
    case get_pair(prog, row, col) do
      {1, 1} -> find_col_start(prog, row, min, col, cnt+1)
      {1, 0} -> find_col_start(prog, row, Integer.floor_div(min, 2), col, cnt+1)
      {0, 0} -> find_col_start(prog, row, col, max, cnt+1)
      {0, 1} -> {col+1, row}
    end
  end

  defp find_col_end(prog, row, min, max) do
    col = Integer.floor_div(max-min, 2)+min
    case get_pair(prog, row, col) do
      {1, 1} -> find_col_end(prog, row, col, max)
      {1, 0} -> {col, row}
      {0, 0} -> find_col_end(prog, row, min, col)
      {0, 1} -> find_col_end(prog, row, col, 2*max)
    end
  end

  defp get_pair(prog, row, col) do
    result1 = check_point(prog, col, row)
    result2 = check_point(prog, col+1, row)
    {result1, result2}
  end

  def count_points(path, max_x, max_y) do
    program = Intcode.load(path)
    for x <- 0..max_x, y <- 0..max_y do
      Task.async(fn -> check_point(program, x, y) end)
    end
    |> Enum.map(&(Task.await(&1)))
    |> Enum.sum()
  end

  def check_point(program, x, y) do
    Intcode.run(program, [x, y], nil, &(send(self(), &1)))
    receive do
      val -> val
    end
  end
end
