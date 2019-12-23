defmodule NAT do
  @moduledoc """
  Not Always Transmitting Process
  """
  use GenServer

  defstruct addr_map: %{}, messages: %{}, last: {nil, nil}, ys: MapSet.new()

  def start_link do
    GenServer.start_link(__MODULE__, %NAT{}, name: __MODULE__)
  end

  def add_address(addr, pid) do
    GenServer.cast(__MODULE__, {:address, addr, pid})
  end

  def send_message(val) do
    GenServer.cast(__MODULE__, {:msg, self(), val})
  end

  @impl true
  def init(arg) do
    {:ok, arg}
  end

  @impl true
  def handle_cast({:address, addr, pid}, state=%NAT{addr_map: map}) do
    {:noreply, %NAT{state | addr_map: Map.put(map, addr, pid)}, 1000}
  end

  def handle_cast({:msg, pid, val}, state=%NAT{addr_map: addrs, messages: msgs, last: last}) do
    curr = Map.get(msgs, pid, {nil, nil, nil})
    {next, last} = case curr do
      {255, b, nil} when b != nil -> IO.puts "GOT VALUE: #{inspect {b, val}}"
        {{nil, nil, nil}, {b, val}}

      {nil, nil, nil} -> {{val, nil, nil}, last}
      {a, nil, nil} -> {{a, val, nil}, last}
      {a, b, nil} -> addr = Map.get(addrs, a)
        send(addr, b)
        send(addr, val)
        {{nil, nil, nil}, last}
    end
    {:noreply, %NAT{state | messages: Map.put(msgs, pid, next), last: last}, 1000}
  end

  @impl true
  def handle_info(:timeout, state=%NAT{addr_map: addrs, last: {x, y}, ys: ys}) do
    IO.puts "Timed out"
    if MapSet.member?(ys, y) do
      IO.puts "Second sent yvalue: #{inspect y}"
      {:stop, :normal, state}
    else
      ys = MapSet.put(ys, y)
      addr = Map.get(addrs, 0)
      send(addr, x)
      send(addr, y)
      {:noreply, %NAT{state | ys: ys}, 1000}
    end
  end
end
