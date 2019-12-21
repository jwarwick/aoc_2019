defmodule Day21 do
  @moduledoc """
  AoC 2019, Day 21 - Springdroid Adventure
  """

  @doc """
  Determine amount of hull damage
  """
  def part1 do
    Util.priv_file(:day21, "day21_input.txt")
    |> hull_damage()
  end

  @script """
  NOT C T
  AND D T
  OR T J
  NOT A T
  OR T J
  """
  def hull_damage(path) do
    prog = Intcode.load(path)
    Intcode.run(prog, String.to_charlist(@script <> "WALK\n"), nil, &ascii_output/1)
    receive do
      v -> v
    after
      250 -> :error
    end
  end

  defp ascii_output(c) do
    if c > 255 do
      send(self(), c)
    else
      IO.write(<<c>>)
    end
  end
end
