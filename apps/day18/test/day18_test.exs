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

  @part2_ex1 """
  #######
  #a.#Cd#
  ##@#@##
  #######
  ##@#@##
  #cB#Ab#
  #######
  """
  test "ex6" do
    assert Day18.multi_shortest_path(@part2_ex1) == 8
  end

  @part2_ex2 """
  ###############
  #d.ABC.#.....a#
  ######@#@######
  ###############
  ######@#@######
  #b.....#.....c#
  ###############
  """
  test "ex7" do
    assert Day18.multi_shortest_path(@part2_ex2) == 24
  end

  @part2_ex3 """
  #############
  #DcBa.#.GhKl#
  #.###@#@#I###
  #e#d#####j#k#
  ###C#@#@###J#
  #fEbA.#.FgHi#
  #############
  """
  test "ex8" do
    assert Day18.multi_shortest_path(@part2_ex3) == 32
  end

  @part2_ex4 """
  #############
  #g#f.D#..h#l#
  #F###e#E###.#
  #dCba@#@BcIJ#
  #############
  #nK.L@#@G...#
  #M###N#H###.#
  #o#m..#i#jk.#
  #############
  """
  test "ex9" do
    assert Day18.multi_shortest_path(@part2_ex4) == 72
  end
end
