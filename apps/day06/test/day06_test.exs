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
    assert 11 == Enum.count(Graph.edges(g)) / 2
    # assert Graph.is_tree?(g)
  end

  test "orbit checksum" do
    g = Day06.parse_graph(@test_map)
    assert 42 == Day06.orbit_checksum(g)
  end

  test "part1" do
    assert 295_936 == Day06.part1()
  end

  @part2_test_map """
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
  K)YOU
  I)SAN
  """

  test "orbit_count" do
    g = Day06.parse_graph(@part2_test_map)
    assert 4 == Day06.orbit_transfer_count(g, "YOU", "SAN")
  end
end
