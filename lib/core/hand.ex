defmodule BettyPoker.Core.Hand do
  @moduledoc """
  Hand module is a collection of functions for the hand that player has.
  """
  alias BettyPoker.Core.{Card, Ranking}
  defstruct cards: [], hand: nil

  @type t :: %__MODULE__{
          cards: list(Card.t()),
          hand: nil | Ranking.t()
        }

  @doc """
  Returns formated hand of the user.
  """
  @spec parse(String.t()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def parse(raw_cards) when is_binary(raw_cards) do
    with {:ok, cards} <- parse_out_cards(raw_cards) do
      {:ok, %__MODULE__{cards: cards, hand: Ranking.rank_hand(cards)}}
    end
  end

  ###########
  # Private #
  ###########
  defp parse_out_cards(raw_cards) do
    raw_cards
    |> String.split(" ")
    |> Enum.reduce_while([], fn raw_card, cards ->
      case Card.parse(raw_card) do
        {:ok, card} -> {:cont, [card] ++ cards}
        _ -> {:halt, {:error, "Cannot parse cards"}}
      end
    end)
    |> case do
      {:error, reason} -> {:error, reason}
      cards when length(cards) > 5 -> {:error, "too much cards"}
      cards -> {:ok, cards}
    end
  end
end
