defmodule BrexTest do
  use ExUnit.Case
  doctest Brex

  test "greets the world" do
    assert Brex.hello() == :world
  end
end
