defmodule BettyPoker.Core.Ranking do
  @moduledoc """
  Ranking module is a collection of rulesets for the presented hand of the user.
  """
  alias BettyPoker.Core.{Card, Hand}
  defstruct rank: nil, tie_breaker: nil
  @card_sequence [2, 3, 4, 5, 6, 7, 8, 9, 10, "jack", "queen", "king", "ace"]
  @rank_sequence [
    :highest_card,
    :pair,
    :two_pair,
    :three_of_a_kind,
    :straight,
    :flush,
    :full_house,
    :four_of_a_kind,
    :straight_flush
  ]
  @type t :: %__MODULE__{
          rank:
            :flush
            | :four_of_a_kind
            | :full_house
            | :highest_card
            | :pair
            | :straight
            | :straight_flush
            | :three_of_a_kind
            | :two_pair,
          tie_breaker: list() | non_neg_integer() | String.t()
        }

  @doc """
  Function returns who won the round from two hands.
  """
  @spec who_won?(%Hand{}, %Hand{}) :: binary()
  def who_won?(%{hand: %{rank: rank}} = black, %{hand: %{rank: rank}} = white) do
    case compare(black.hand.tie_breaker, white.hand.tie_breaker) do
      %{color: color, reason: reason} ->
        "#{String.capitalize(color)} won - #{reason}"

      _ ->
        "Tie."
    end
  end

  def who_won?(black, white) do
    black_rank_index = return_rank_index(black.hand.rank)
    white_rank_index = return_rank_index(white.hand.rank)

    if black_rank_index > white_rank_index do
      "Black won - #{format_rank(black.hand.rank)}."
    else
      "White won - #{format_rank(white.hand.rank)}."
    end
  end

  @doc """
  Function returns rank of the provided list of cards with the tie braker.

  - High Card: Hands which do not fit any higher category are
  ranked by the value of their highest card. If the highest
  cards have the same value, the hands are ranked by the next
  highest, and so on.

  - Pair: 2 of the 5 cards in the hand have the same value.
  Hands which both contain a pair are ranked by the value of
  the cards forming the pair. If these values are the same,
  the hands are ranked by the values of the cards not
  forming the pair, in decreasing order.

  - Two Pairs: The hand contains 2 different pairs. Hands
  which both contain 2 pairs are ranked by the value of
  their highest pair. Hands with the same highest pair
  are ranked by the value of their other pair. If these
  values are the same the hands are ranked by the value
  of the remaining card.

  - Three of a Kind: Three of the cards in the hand have the
  same value. Hands which both contain three of a kind are
  ranked by the value of the 3 cards.

  - Straight: Hand contains 5 cards with consecutive values.
  Hands which both contain a straight are ranked by their
  highest card.

  - Flush: Hand contains 5 cards of the same suit. Hands which
  are both flushes are ranked using the rules for High Card.

  - Full House: 3 cards of the same value, with the remaining 2
  cards forming a pair. Ranked by the value of the 3 cards.

  - Four of a kind: 4 cards with the same value. Ranked by the
  value of the 4 cards.

  - Straight flush: 5 cards of the same suit with consecutive
  values. Ranked by the highest card in the hand.
  """
  @spec rank_hand(list(%Card{})) :: __MODULE__.t()
  def rank_hand(cards) do
    cond do
      is_straight_flush?(cards) ->
        %__MODULE__{rank: :straight_flush, tie_breaker: highest_card(cards)}

      is_four_of_a_kind?(cards) ->
        %__MODULE__{rank: :four_of_a_kind, tie_breaker: get_value_for_value(cards, 4)}

      is_full_house?(cards) ->
        %__MODULE__{rank: :full_house, tie_breaker: get_value_for_value(cards, 3)}

      is_flush?(cards) ->
        %__MODULE__{rank: :flush, tie_breaker: highest_card(cards)}

      is_straight?(cards) ->
        %__MODULE__{rank: :straight, tie_breaker: highest_card(cards)}

      is_three_of_a_kind?(cards) ->
        %__MODULE__{rank: :three_of_a_kind, tie_breaker: get_value_for_value(cards, 3)}

      is_two_pairs?(cards) ->
        %__MODULE__{rank: :two_pairs, tie_breaker: get_value_for_value(cards, 1)}

      is_pair?(cards) ->
        %__MODULE__{rank: :pair, tie_breaker: get_desc_list_of_cards(cards)}

      true ->
        %__MODULE__{rank: :highest_card, tie_breaker: get_desc_list_of_cards(cards)}
    end
  end

  ###########
  # Private #
  ###########
  defp format_rank(rank) do
    rank
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.join(" ")
  end

  defp compare(black, white) when is_list(black) and is_list(white) do
    black_list = Enum.map(black, &{&1, return_card_index(&1)})
    white_list = Enum.map(white, &{&1, return_card_index(&1)})

    Enum.reduce_while(0..5, %{reason: :tie}, fn index, tie ->
      case {Enum.at(black_list, index), Enum.at(white_list, index)} do
        {value, value} ->
          {:cont, tie}

        {{val, black_index}, {_val, white_index}} when black_index > white_index ->
          {:halt, %{color: "black", reason: "high card: #{val}."}}

        {{_val, black_index}, {val, white_index}} when black_index < white_index ->
          {:halt, %{color: "white", reason: "high card: #{val}."}}
      end
    end)
  end

  defp compare(black, white) do
    case {return_card_index(black), return_card_index(white)} do
      {index, index} ->
        %{reason: :tie}

      {black_index, white_index} when black_index > white_index ->
        %{color: "black", reason: "high card: #{black}."}

      {black_index, white_index} when black_index < white_index ->
        %{color: "white", reason: "high card: #{black}."}
    end
  end

  defp is_straight_flush?(cards) do
    are_cards_consecutive_value?(cards) and are_cards_same_suit?(cards)
  end

  defp is_four_of_a_kind?(cards) do
    cards
    |> get_frequency_for_cards()
    |> Enum.reduce(0, fn
      {_key, value}, frequency_sum when value > 2 -> frequency_sum + value
      _, frequency_sum -> frequency_sum
    end)
    |> Kernel.==(4)
  end

  defp is_full_house?(cards) do
    cards
    |> get_frequency_for_cards()
    |> Enum.reduce(0, fn
      {_key, value}, frequency_sum when value > 1 -> frequency_sum + value
      _, frequency_sum -> frequency_sum
    end)
    |> Kernel.==(5)
  end

  defp is_flush?(cards) do
    are_cards_same_suit?(cards) and not are_cards_consecutive_value?(cards)
  end

  defp is_straight?(cards) do
    are_cards_consecutive_value?(cards) and not are_cards_same_suit?(cards)
  end

  defp is_three_of_a_kind?(cards) do
    cards
    |> get_frequency_for_cards()
    |> Enum.reduce(0, fn
      {_key, value}, frequency_sum when value > 1 -> frequency_sum + value
      _, frequency_sum -> frequency_sum
    end)
    |> Kernel.==(3)
  end

  defp is_two_pairs?(cards) do
    cards
    |> get_frequency_for_cards()
    |> Enum.reduce(0, fn
      {_key, value}, frequency_sum when value > 1 and value < 4 -> frequency_sum + value
      _, frequency_sum -> frequency_sum
    end)
    |> Kernel.==(4)
  end

  defp is_pair?(cards) do
    cards
    |> get_frequency_for_cards()
    |> Enum.reduce(0, fn
      {_key, value}, frequency_sum when value > 1 and value < 3 -> frequency_sum + value
      _, frequency_sum -> frequency_sum
    end)
    |> Kernel.==(2)
  end

  defp highest_card(cards) do
    [index | _tail] =
      cards
      |> Enum.map(fn %{value: value} ->
        return_card_index(value)
      end)
      |> Enum.sort(:desc)

    Enum.at(@card_sequence, index)
  end

  defp get_desc_list_of_cards(cards) do
    pair_value = get_value_for_value(cards, 2)

    cards
    |> Enum.reduce([], fn
      %{value: value} = card, acc when value != pair_value ->
        [card.value] ++ acc

      _, acc ->
        acc
    end)
    |> Enum.sort_by(&return_card_index(&1), :desc)
  end

  defp get_value_for_value(cards, number) do
    cards
    |> get_frequency_for_cards()
    |> Enum.reduce_while(nil, fn
      {key, value}, _acc when value == number -> {:halt, key}
      _freq, acc -> {:cont, acc}
    end)
  end

  defp get_frequency_for_cards(cards) do
    cards
    |> Enum.map(&Map.get(&1, :value))
    |> Enum.frequencies()
  end

  defp are_cards_same_suit?(cards) do
    [suit | tail] = Enum.map(cards, &Map.get(&1, :suit))

    tail
    |> Enum.reduce_while(suit, fn
      value, value -> {:cont, value}
      _, _ -> {:halt, false}
    end)
    |> Kernel.&&(true)
  end

  defp are_cards_consecutive_value?(cards) do
    [first_index | rest] =
      cards
      |> Enum.map(fn %{value: value} ->
        return_card_index(value)
      end)
      |> Enum.sort()

    rest
    |> Enum.reduce_while(first_index, fn
      index, previous_index when index - previous_index == 1 -> {:cont, index}
      _index, _previous_index -> {:halt, false}
    end)
    |> Kernel.&&(true)
  end

  defp return_card_index(value) do
    Enum.find_index(@card_sequence, fn index -> index == value end)
  end

  defp return_rank_index(hand_rank) do
    Enum.find_index(@rank_sequence, fn rank -> rank == hand_rank end)
  end
end
