defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  @test_map """
  COM)B
  B)C
  C)D
  D)E
  E)F
  B)G
  G)H
  D)I
  E)J
  J)K
  K)L
  """

  test "read orbit map" do
    g = Day06.parse_graph(@test_map)
    assert 12 == Enum.count(Graph.vertices(g))
    assert 11 == Enum.count(Graph.edges(g))
    assert Graph.is_tree?(g)
  end

  test "orbit checksum" do
    g = Day06.parse_graph(@test_map)
    assert 42 == Day06.orbit_checksum(g)
  end
end
