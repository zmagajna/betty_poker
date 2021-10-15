defmodule BettyPoker.Test.Core.CardTest do
  use ExUnit.Case
  alias BettyPoker.Core.Card

  test "returned parsed out Card structure" do
    assert {:ok, %Card{suit: "clubs", value: 2}} == Card.parse("2C")
    assert {:ok, %Card{suit: "clubs", value: 2}} == Card.parse("2c")
  end

  test "non binary elements should return error" do
    assert {:error, "Wrong element"} == Card.parse(1243)
    assert {:error, "Wrong element"} == Card.parse(%{})
    assert {:error, "Wrong element"} == Card.parse([])
  end

  test "wrong color should return error" do
    assert {:error, "Wrong suit"} = Card.parse("10¤")
    assert {:error, "Wrong suit"} = Card.parse("2Z")
  end

  test "wrong value should return error" do
    assert {:error, "Wrong value"} = Card.parse("1C")
  end
end
