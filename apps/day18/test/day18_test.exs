defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  @ex1 """
  #########
  #b.A.@.a#
  #########
  """
  test "ex1" do
    assert Day18.shortest_path(@ex1) == 8
  end

  @ex2 """
  ########################
  #f.D.E.e.C.b.A.@.a.B.c.#
  ######################.#
  #d.....................#
  ########################
  """
  test "ex2" do
    assert Day18.shortest_path(@ex2) == 86
  end

  @ex3 """
  ########################
  #...............b.C.D.f#
  #.######################
  #.....@.a.B.c.d.A.e.F.g#
  ########################
  """
  test "ex3" do
    assert Day18.shortest_path(@ex3) == 132
  end

  @ex4 """
  #################
  #i.G..c...e..H.p#
  ########.########
  #j.A..b...f..D.o#
  ########@########
  #k.E..a...g..B.n#
  ########.########
  #l.F..d...h..C.m#
  #################
  """
  test "ex4" do
    assert Day18.shortest_path(@ex4) == 136
  end

  @ex5 """
  ########################
  #@..............ac.GI.b#
  ###d#e#f################
  ###A#B#C################
  ###g#h#i################
  ########################
  """
  test "ex5" do
    assert Day18.shortest_path(@ex5) == 81
  end
end
