defmodule BettyPoker.Test.Core.HandTest do
  use ExUnit.Case
  alias BettyPoker.Core.{Card, Hand, Ranking}

  test "raw input of hand should return card list and what he has in the hand" do
    assert {:ok,
            %Hand{
              cards: [
                %Card{suit: "diamonds", value: "king"},
                %Card{suit: "clubs", value: 9},
                %Card{suit: "spades", value: 5},
                %Card{suit: "diamonds", value: 3},
                %Card{suit: "hearts", value: 2}
              ],
              hand: %Ranking{rank: :highest_card, tie_breaker: ["king", 9, 5, 3, 2]}
            }} == Hand.parse("2H 3D 5S 9C KD")
  end

  test "raw input of hand should return error when wrong card" do
    assert {:error, "Cannot parse cards"} == Hand.parse("2Z 3D 5S 9C KD")
  end
end
