defmodule Day16 do
  @moduledoc """
  AoC 2019, Day 16 - Flawed Frequency Transmission
  """

  @doc """
  After 100 phases of FFT, what are the first eight digits in the final output list?
  """
  def part1 do
    Util.priv_file(:day16, "day16_input.txt")
    |> File.read!()
    |> String.trim()
    |> fft(100)
    |> String.slice(0..7)
  end

  @doc """
  Compute the FFT of the given string for phase_cnt cycles
  """
  def fft(str, phase_cnt) do
    digits =
      String.graphemes(str)
      |> Enum.map(&String.to_integer/1)

    phase(digits, phase_cnt)
  end

  @base_pattern [0, 1, 0, -1]
  def pattern(digit) do
    Stream.flat_map(@base_pattern, &make_stream(&1, digit + 1))
    |> Stream.cycle()
    |> Stream.drop(1)
  end

  defp make_stream(val, cnt) do
    List.duplicate(val, cnt)
  end

  def phase(digits, 0) do
    Enum.reduce(digits, "", fn d, acc -> acc <> Integer.to_string(d) end)
  end

  def phase(digits, cnt) do
    Enum.with_index(digits)
    |> Enum.map(fn {_val, idx} -> output_element(idx, digits) end)
    |> phase(cnt - 1)
  end

  def output_element(idx, digits) do
    p = pattern(idx)

    Enum.zip(digits, p)
    |> Enum.map(fn {d, p} -> d * p end)
    |> Enum.sum()
    |> abs()
    |> Integer.digits()
    |> Enum.take(-1)
    |> hd()
  end
end
