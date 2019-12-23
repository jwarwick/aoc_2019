defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  @test_deck Enum.into(0..9, [])

  @ex1 """
  deal with increment 7
  deal into new stack
  deal into new stack
  """
  |> Day22.load()

  test "ex1" do
    assert Day22.shuffle(@ex1, @test_deck ) == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
  end

  @ex2 """
  cut 6
  deal with increment 7
  deal into new stack
  """
  |> Day22.load()

  test "ex2" do
    assert Day22.shuffle(@ex2, @test_deck ) == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]
  end

  @ex3 """
  deal with increment 7
  deal with increment 9
  cut -2
  """
  |> Day22.load()

  test "ex3" do
    assert Day22.shuffle(@ex3, @test_deck ) == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]
  end

  @ex4 """
  deal into new stack
  cut -2
  deal with increment 7
  cut 8
  cut -4
  deal with increment 7
  cut 3
  deal with increment 9
  deal with increment 3
  cut -1
  """
  |> Day22.load()

  test "ex4" do
    assert Day22.shuffle(@ex4, @test_deck ) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
  end

  test "neg cut" do
    assert Day22.shuffle("cut -4" |> Day22.load(), @test_deck) == [6, 7, 8, 9, 0, 1, 2, 3, 4, 5]
  end
end
