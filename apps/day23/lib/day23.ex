defmodule Day23 do
  @moduledoc """
  AoC 2019, Day 23 - Category Six
  """

  @doc """
  Find first Y value sent to address 255
  """
  def part1 do
    Util.priv_file(:day23, "day23_input.txt")
    |> Intcode.load()
    |> spawn_network()
  end

  def spawn_network(prog) do
    {:ok, _pid} = Agent.start_link(fn -> %{} end, name: __MODULE__)
    {:ok, _pid} = Agent.start_link(fn -> %{} end, name: :mapper)
    {:ok, _pid} = Agent.start_link(fn -> %{} end, name: :inverse)
    for addr <- 0..49 do
      {:ok, pid} = Task.start(fn -> Process.sleep(250) && Intcode.run(prog, [addr], &read_message/0, &(send_message(self(), &1))) end)
      Agent.update(:mapper, fn state -> Map.put(state, addr, pid) end)
      IO.puts "Addr #{inspect addr} at #{inspect pid}"
    end
    Process.sleep(5000)
  end

  defp send_message(pid, val) do
    Agent.update(__MODULE__, &(update_state(&1, pid, val)))
  end

  defp update_state(map, pid, val) do
    curr = Map.get(map, pid, {nil, nil, nil})
    next = case curr do
      {255, b, nil} when b != nil -> IO.puts "GOT VALUE: #{inspect val}"
      {nil, nil, nil} -> {val, nil, nil}
      {a, nil, nil} -> {a, val, nil}
      {a, b, nil} -> addr = Agent.get(:mapper, fn state -> Map.get(state, a) end)
        IO.puts "Getting addr: #{inspect a}: #{inspect addr}"
        send(addr, b)
        send(addr, val)
        {nil, nil, nil}
    end
    |> IO.inspect
    Map.put(map, pid, next)
  end

  defp read_message do
    receive do 
      v -> v
    after
      0 -> -1
    end
  end
end
