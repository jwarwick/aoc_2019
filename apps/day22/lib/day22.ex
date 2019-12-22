defmodule Day22 do
  @moduledoc """
  AoC 2019, Day 22 - Slam Shuffle
  """

  @doc """
  Shuffle deck from instructions, return position of card 2019
  """
  def part1 do
    Util.priv_file(:day22, "day22_input.txt")
    |> File.read!()
    |> shuffle()
    |> Enum.find_index(&(&1 == 2019))
  end

  @factory_deck Enum.into(0..10_006, [])

  @doc """
  Shuffle per instructions
  """
  def shuffle(str, deck \\ @factory_deck) do
    steps = String.split(str, "\n", trim: true)
    shuffle_step(steps, deck)
  end

  def shuffle_step([], deck), do: deck

  def shuffle_step([<<"deal into new stack">> | rest], deck) do
    shuffle_step(rest, Enum.reverse(deck))
  end

  def shuffle_step([<<"cut ", cnt::binary>> | rest], deck) do
    cnt = String.to_integer(cnt)
    f = Enum.take(deck, cnt)
    b = Enum.drop(deck, cnt)
    new_list = if cnt < 0, do: [f | b], else: [b | f]
    shuffle_step(rest, List.flatten(new_list))
  end

  def shuffle_step([<<"deal with increment ", cnt::binary>> | rest], deck) do
    cnt = String.to_integer(cnt)
    m = mod_shuffle(tl(deck), Enum.count(deck), 0, cnt, %{0 => hd(deck)})
    result = Enum.reduce(Enum.sort(Map.keys(m)), [], &([Map.get(m, &1) | &2]))
             |> Enum.reverse()
    shuffle_step(rest, result)
  end

  defp mod_shuffle([], _size, _curr, _cnt, map), do: map
  defp mod_shuffle([v | rest], size, curr, cnt, map) do
    loc = Integer.mod((curr + cnt), size)
    mod_shuffle(rest, size, loc, cnt, Map.put(map, loc, v))
  end
end
