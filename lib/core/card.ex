defmodule BettyPoker.Core.Card do
  @moduledoc """
  Card module is responsible for the parsing out the card from unstructured to the stuructured way that our services can then read out.
  """
  @suits %{"C" => "clubs", "D" => "diamonds", "H" => "hearts", "S" => "spades"}
  @values %{
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "10" => 10,
    "J" => "jack",
    "Q" => "queen",
    "K" => "king",
    "A" => "ace"
  }
  @type t :: %__MODULE__{
          suit: nil | String.t(),
          value: nil | String.t()
        }
  defstruct suit: nil, value: nil

  @doc """
  Returns structured way of a card.

  ## Examples

        iex> BettyPoker.Core.Card.parse("QH")
        {:ok, %BettyPoker.Core.Card{suit: "hearts", value: "queen"}}

        iex> BettyPoker.Core.Card.parse("KD")
        {:ok, %BettyPoker.Core.Card{suit: "diamonds", value: "king"}}

        iex> BettyPoker.Core.Card.parse("10s")
        {:ok, %BettyPoker.Core.Card{suit: "spades", value: 10}}
  """
  @spec parse(binary) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def parse(raw_card) when is_binary(raw_card) do
    with <<color::binary-size(1), value::binary>> <-
           raw_card |> String.upcase() |> String.reverse(),
         suit when not is_tuple(suit) <- Map.get(@suits, color, {:error, "Wrong suit"}),
         value when not is_tuple(value) <-
           Map.get(@values, String.reverse(value), {:error, "Wrong value"}) do
      {:ok, %__MODULE__{suit: suit, value: value}}
    end
  end

  def parse(_elem) do
    {:error, "Wrong element"}
  end
end
