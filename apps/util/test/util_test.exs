defmodule UtilTest do
  use ExUnit.Case
  doctest Util

  test "splits file on newlines" do
    result = Util.split_file("test/files/input.txt")
    assert result == ["80740", "103617", "86598", "135938", "98650"]
  end

  test "splits file on newlines into ints" do
    result = Util.split_file_to_ints("test/files/input.txt")
    assert result == [80740, 103617, 86598, 135938, 98650]
  end
end
