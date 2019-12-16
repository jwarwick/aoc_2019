defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "ex1" do
    input = "12345678"
    assert Day16.fft(input, 1) == "48226158"
    assert Day16.fft("48226158", 1) == "34040438"

    assert Day16.fft(input, 2) == "34040438"
    assert Day16.fft(input, 3) == "03415518"
    assert Day16.fft(input, 4) == "01029498"
  end

  test "ex2" do
    assert Day16.fft("80871224585914546619083218645595", 100) |> String.slice(0..7) == "24176176"
    assert Day16.fft("19617804207202209144916044189917", 100) |> String.slice(0..7) == "73745418"
    assert Day16.fft("69317163492948606335995924319873", 100) |> String.slice(0..7) == "52432133"
  end
end
