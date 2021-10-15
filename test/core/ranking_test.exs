defmodule BettyPoker.Test.Core.RankingTest do
  use ExUnit.Case
  alias BettyPoker.Core.{Card, Ranking}
  doctest Ranking

  test "high card" do
    assert %Ranking{rank: :highest_card, tie_breaker: ["king", 9, 5, 3, 2]} ==
             Ranking.rank_hand([
               %Card{suit: "diamonds", value: "king"},
               %Card{suit: "clubs", value: 9},
               %Card{suit: "spades", value: 5},
               %Card{suit: "diamonds", value: 3},
               %Card{suit: "hearts", value: 2}
             ])
  end

  test "pair" do
    assert %Ranking{rank: :pair, tie_breaker: ["king", 9, 5]} ==
             Ranking.rank_hand([
               %Card{suit: "diamonds", value: "king"},
               %Card{suit: "clubs", value: 9},
               %Card{suit: "spades", value: 5},
               %Card{suit: "diamonds", value: 2},
               %Card{suit: "hearts", value: 2}
             ])
  end

  test "two pairs" do
    assert %Ranking{rank: :two_pairs, tie_breaker: "king"} ==
             Ranking.rank_hand([
               %Card{suit: "diamonds", value: 5},
               %Card{suit: "clubs", value: "king"},
               %Card{suit: "spades", value: 5},
               %Card{suit: "diamonds", value: 3},
               %Card{suit: "hearts", value: 3}
             ])
  end

  test "three of a kind" do
    assert %Ranking{rank: :three_of_a_kind, tie_breaker: 5} ==
             Ranking.rank_hand([
               %Card{suit: "diamonds", value: 5},
               %Card{suit: "clubs", value: 4},
               %Card{suit: "spades", value: 5},
               %Card{suit: "diamonds", value: 5},
               %Card{suit: "hearts", value: 6}
             ])
  end

  test "straight" do
    assert %Ranking{rank: :straight, tie_breaker: 6} ==
             Ranking.rank_hand([
               %Card{suit: "diamonds", value: 2},
               %Card{suit: "clubs", value: 4},
               %Card{suit: "spades", value: 5},
               %Card{suit: "diamonds", value: 3},
               %Card{suit: "hearts", value: 6}
             ])
  end

  test "flush" do
    assert %Ranking{rank: :flush, tie_breaker: "king"} ==
             Ranking.rank_hand([
               %Card{suit: "diamonds", value: "king"},
               %Card{suit: "diamonds", value: 9},
               %Card{suit: "diamonds", value: 5},
               %Card{suit: "diamonds", value: 3},
               %Card{suit: "diamonds", value: 2}
             ])
  end

  test "full house" do
    assert %Ranking{rank: :full_house, tie_breaker: 3} ==
             Ranking.rank_hand([
               %Card{suit: "diamonds", value: "king"},
               %Card{suit: "clubs", value: 3},
               %Card{suit: "spades", value: 3},
               %Card{suit: "diamonds", value: 3},
               %Card{suit: "hearts", value: "king"}
             ])
  end

  test "four of a kind" do
    assert %Ranking{rank: :four_of_a_kind, tie_breaker: 3} ==
             Ranking.rank_hand([
               %Card{suit: "diamonds", value: "king"},
               %Card{suit: "clubs", value: 3},
               %Card{suit: "spades", value: 3},
               %Card{suit: "diamonds", value: 3},
               %Card{suit: "hearts", value: 3}
             ])
  end

  test "straight flush" do
    assert %Ranking{rank: :straight_flush, tie_breaker: "ace"} ==
             Ranking.rank_hand([
               %Card{suit: "diamonds", value: "queen"},
               %Card{suit: "diamonds", value: "king"},
               %Card{suit: "diamonds", value: "jack"},
               %Card{suit: "diamonds", value: "ace"},
               %Card{suit: "diamonds", value: 10}
             ])
  end
end
