defmodule Day22 do
  @moduledoc """
  AoC 2019, Day 22 - Slam Shuffle
  """

  @doc """
  Shuffle deck from instructions, return position of card 2019
  """
  def part1_orig do
    input_file()
    |> load()
    |> shuffle()
    |> Enum.find_index(&(&1 == 2019))
  end

  @doc """
  Shuffle deck from instructions, return position of card 2019
  """
  def part1 do
    input_file()
    |> load()
    |> shuffle_funs()
    |> apply([2019])
  end

  # @big_deck_cnt 119315717514047
  # @shuffle_cnt  101741582076661
  @doc """
  Shuffle the extended deck, multiple times. What card is in position 2020?
  """
  def part2 do
    :nope
  end

  @factory_deck Enum.into(0..10_006, [])

  def input_file do
    Util.priv_file(:day22, "day22_input.txt")
    |> File.read!()
  end

  def load(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(&parse/1)
  end

  def normalize(val, deck_len) when val < 0 do
    deck_len - normalize(-val, deck_len)
  end

  def normalize(val, deck_len), do: rem(val, deck_len)

  def shuffle_funs(steps, deck \\ @factory_deck) do
    deck_len = Enum.count(deck)
    {a, b} = Enum.reduce(steps, {1, 0}, &(lin_fun(&1, &2, deck_len)))

    fn x -> normalize(a*x + b, deck_len) end
  end
  
  def lin_fun({:new_stack, nil}, {a, b}, len), do: {normalize(-a, len), normalize(-b - 1, len)}
  def lin_fun({:cut, val}, {a, b}, len), do: {a, normalize(b-val, len)}
  def lin_fun({:increment, val}, {a, b}, len), do: {normalize(a*val, len), normalize(b*val, len)}

  def parse(<<"deal into new stack">>), do: {:new_stack, nil}
  def parse(<<"cut ", cnt::binary>>), do: {:cut, String.to_integer(cnt)}
  def parse(<<"deal with increment ", cnt::binary>>), do: {:increment, String.to_integer(cnt)}

  def shuffle(steps, deck \\ @factory_deck)

  def shuffle([], deck), do: deck

  def shuffle([{:new_stack, _} | rest], deck) do
    shuffle(rest, Enum.reverse(deck))
  end

  def shuffle([{:cut, cnt} | rest], deck) do
    f = Enum.take(deck, cnt)
    b = Enum.drop(deck, cnt)
    new_list = if cnt < 0, do: [f | b], else: [b | f]
    shuffle(rest, List.flatten(new_list))
  end

  def shuffle([{:increment, cnt} | rest], deck) do
    m = mod_shuffle(tl(deck), Enum.count(deck), 0, cnt, %{0 => hd(deck)})
    result = Enum.reduce(Enum.sort(Map.keys(m)), [], &([Map.get(m, &1) | &2]))
             |> Enum.reverse()
    shuffle(rest, result)
  end

  defp mod_shuffle([], _size, _curr, _cnt, map), do: map
  defp mod_shuffle([v | rest], size, curr, cnt, map) do
    loc = Integer.mod((curr + cnt), size)
    mod_shuffle(rest, size, loc, cnt, Map.put(map, loc, v))
  end
end
