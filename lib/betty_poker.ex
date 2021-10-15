defmodule BettyPoker do
  @moduledoc """
  API model for the Betty Poker application.
  """
  alias BettyPoker.Core.{Hand, Ranking}

  @doc """
  Function that returns who won the round

  ## Examples

        iex> BettyPoker.show_hands "2H 4S 4C 3D 4H", "2S 8S AS QS 3S"
        "White won - flush."

        iex> BettyPoker.show_hands "2H 3D 5S 9C KD", "2C 3H 4S 8C AH"
        "White won - high card: ace."

        iex> BettyPoker.show_hands "2H 3D 5S 9C KD", "2C 3H 4S 8C KH"
        "Black won - high card: 9."

        iex> BettyPoker.show_hands "2H 3D 5S 9C KD", "2D 3H 5C 9S KH"
        "Tie."

        iex> BettyPoker.show_hands "10D JD QD AD KD", "2D 3H 5C 9S KH"
        "Black won - straight flush."

        iex> BettyPoker.show_hands "10D JD QD AD KD", "10C JC KC AC QC"
        "Tie."
  """
  # @spec show_hands()
  def show_hands(black, white) do
    with {:ok, black_hand} <- Hand.parse(black),
         {:ok, white_hand} <- Hand.parse(white) do
      Ranking.who_won?(black_hand, white_hand)
    end
  end
end
