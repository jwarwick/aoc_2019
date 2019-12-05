defmodule Util do
  @moduledoc """
  Useful funcitons for solving AoC
  """

  @doc """
  Generate path string for a file in the /priv directory
  """
  @spec priv_file(atom(), String.t()) :: String.t()
  def priv_file(app, file) do
    Application.app_dir(app, "priv") |> Path.join(file)
  end

  @doc """
  Read a file into a list of strings
  """
  @spec split_file(Path.t()) :: [String.t()]
  def split_file(file) do
    {:ok, contents} = File.read(file)
    String.split(contents, "\n", trim: true)
  end

  @doc """
  Read a file into a list of integers
  """
  @spec split_file_to_ints(Path.t()) :: [integer()]
  def split_file_to_ints(file) do
    split_file(file)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Read an IntCode file
  """
  @spec read_intcode(Path.t()) :: map()
  @deprecated "Use Intcode.read/1 instead"
  def read_intcode(file) do
    {:ok, contents} = File.read(file)
    parse_intcode(contents)
  end

  @doc """
  Parse an IntCode string
  """
  @spec parse_intcode(String.t()) :: map()
  @deprecated "Use Intcode.parse/1 instead"
  def parse_intcode(str) do
    String.trim(str)
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {val, idx}, acc -> Map.put(acc, idx, val) end)
  end
end
