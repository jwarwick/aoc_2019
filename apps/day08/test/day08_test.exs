defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "parse" do
    layers = Day08.string_to_layers("123456789012", 3, 2)
    assert layers == [[1, 2, 3, 4, 5, 6], [7, 8, 9, 0, 1, 2]]
  end

  test "checksum" do
    layers = Day08.string_to_layers("123126789012", 3, 2)
    assert Day08.checksum(layers) == 4
  end
end
