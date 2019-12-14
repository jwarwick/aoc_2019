defmodule Day14 do
  @moduledoc """
  AoC 2019, Day 14 - Space Stoichiometry
  """

  defmodule State do
    defstruct ore_used: 0, steps: [], need: %{}, stock: %{}
  end

  @doc """
  Amount of ORE required by the nanofactory to produce 1 FUEL
  """
  def part1 do
    Util.priv_file(:day14, "day14_input.txt")
    |> File.read!()
    |> min_ore()
  end

  @doc """
  Compute the max fuel that can be produced with 1 trillion ore
  """
  def part2 do
    Util.priv_file(:day14, "day14_input.txt")
    |> File.read!()
    |> max_fuel()
  end

  @doc """
  Compute maximum fuel that can be produced with 1 trillion ore
  """
  def max_fuel(str) do
    rules = parse_str(str)
    binary_search(rules, run(rules, 1), run(rules, 50_000_000_000))
  end

  defp run(rules, target) do
    result =
      generate(
        rules,
        rules,
        %State{need: %{FUEL: target}, stock: %{ORE: 100_000_000_000_000_000_000}},
        %State{ore_used: 300_000_000_000_0000}
      )

    ore = Map.get(result, :ore_used)
    {target, ore}
  end

  @cargo_ore 1_000_000_000_000

  def binary_search(_rules, {low_fuel, _low_ore}, {high_fuel, _high_ore})
      when low_fuel >= high_fuel do
    low_fuel
  end

  def binary_search(rules, low = {low_fuel, _low_ore}, high = {high_fuel, _high_ore}) do
    target = low_fuel + Integer.floor_div(high_fuel - low_fuel, 2)

    if low_fuel == target do
      low_fuel
    else
      new = {_actual, ore} = run(rules, target)

      cond do
        ore == @cargo_ore -> target
        ore < @cargo_ore -> binary_search(rules, new, high)
        ore > @cargo_ore -> binary_search(rules, low, new)
      end
    end
  end

  @doc """
  Compute the minimum required ore to produce 1 fuel from the given machine
  """
  def min_ore(str) do
    rules = parse_str(str)

    generate(rules, rules, %State{need: %{FUEL: 1}, stock: %{ORE: 100_000_000_000_000}}, %State{
      ore_used: 300_000_000
    })
    |> Map.get(:ore_used)
  end

  defp parse_str(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(&String.replace(&1, ["=", ">", ","], ""))
    |> Enum.map(&String.split/1)
    |> Enum.map(&Enum.chunk_every(&1, 2))
    |> Enum.map(&Enum.map(&1, fn [n, s] -> {String.to_integer(n), String.to_atom(s)} end))
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(fn [h | rest] -> {rest, h} end)
  end

  defp generate(_a, _c, %State{ore_used: c}, best = %State{ore_used: b}) when c > b, do: best
  defp generate(_all_rules, _curr_rules, s = %State{need: n}, _best) when map_size(n) == 0, do: s
  defp generate(_all_rules, [], _curr, _best), do: nil

  defp generate(all_rules, [{lst, {cnt, p}} | rest], state, best) do
    if Map.has_key?(state.need, p) do
      need_val = Map.get(state.need, p)
      mult = Integer.floor_div(need_val, cnt)
      mult = if mult == 0, do: 1, else: mult
      {cnt, p} = {cnt * mult, p}
      lst = Enum.map(lst, fn {cnt, k} -> {cnt * mult, k} end)

      needs = subtract_generated(state.need, {cnt, p})
      neg_needs = Enum.filter(needs, fn {_k, v} -> v < 0 end)
      needs = remove_less_than_zero(needs)

      stock = Enum.reduce(lst, state.stock, &reduce_stock/2)
      neg_stock = Enum.filter(stock, fn {_k, v} -> v < 0 end)
      stock = remove_less_than_zero(stock)

      needs = add_costs(needs, neg_stock)
      stock = add_costs(stock, neg_needs)

      steps = [{lst, {cnt, p}} | state.steps]

      ore = Enum.reduce(lst, state.ore_used, &add_ore_used/2)

      generate(
        all_rules,
        all_rules,
        %State{state | need: needs, stock: stock, steps: steps, ore_used: ore},
        best
      )
    else
      generate(all_rules, rest, state, best)
    end
  end

  defp add_ore_used({cnt, :ORE}, acc), do: acc + cnt
  defp add_ore_used(_cost, acc), do: acc

  defp reduce_stock({cnt, kind}, map) do
    if Map.has_key?(map, kind) do
      Map.update!(map, kind, &(&1 - cnt))
    else
      Map.put(map, kind, -1 * cnt)
    end
  end

  defp subtract_generated(map, {cnt, k}) do
    Map.update!(map, k, &(&1 - cnt))
  end

  defp add_costs(map, []), do: map

  defp add_costs(map, [{k, cnt} | rest]) do
    Map.update(map, k, -1 * cnt, &(&1 + -1 * cnt))
    |> add_costs(rest)
  end

  defp remove_less_than_zero(map) do
    map
    |> Enum.filter(fn {_k, v} -> v > 0 end)
    |> Enum.into(%{})
  end
end
