defmodule Util do
  @moduledoc """
  Useful funcitons for solving AoC
  """

  @doc """
  Generate path string for a file in the /priv directory
  """
  def priv_file(app, file) do
    Application.app_dir(app, "priv") |> Path.join(file)
  end

  @doc """
  Read a file into a list of strings
  """
  def split_file(file) do
    {:ok, contents} = File.read(file)
    String.split(contents, "\n", trim: true)
  end

  @doc """
  Read a file into a list of integers
  """
  def split_file_to_ints(file) do
    split_file(file)
    |> Enum.map(&String.to_integer/1)
  end
end
