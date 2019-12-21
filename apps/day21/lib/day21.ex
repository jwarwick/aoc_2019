defmodule Day21 do
  @moduledoc """
  AoC 2019, Day 21 - Springdroid Adventure
  """

  @script """
  NOT C T
  AND D T
  OR T J
  NOT A T
  OR T J
  """

  @doc """
  Determine amount of hull damage
  """
  def part1 do
    hull_damage(@script, "WALK")
  end

  @script2 """
  NOT T T
  AND D T
  AND H T
  OR T J
  OR A T
  AND B T
  AND C T
  AND D T
  NOT T T
  AND T J
  NOT A T
  OR T J
  """

  @doc """
  Determine amount of hull damage using extended sensors
  """
  def part2 do
    hull_damage(@script2, "RUN")
  end

  def permutations(sensors \\ "ABCDEFGHI") do
    for ins <- ["NOT", "AND", "OR"], x <- String.graphemes(sensors <> "TJ"), y <- ["T", "J"] do
      "#{ins} #{x} #{y}\n"
    end
  end

  def hull_damage(script, cmd) do
    prog = Util.priv_file(:day21, "day21_input.txt")
           |> Intcode.load()
    Intcode.run(prog, String.to_charlist(script <> cmd <> "\n"), nil, &ascii_output/1)
    receive do
      v -> v
    after
      0 -> :error
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
