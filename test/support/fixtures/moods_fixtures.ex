defmodule Niko.MoodsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Niko.Moods` context.
  """

  import Niko.AccountsFixtures

  @doc """
  Generate a mood.
  """
  def mood_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, mood} =
      attrs
      |> Enum.into(%{
        date: ~D[2025-08-03],
        emojis: "😊",
        mood: :horrible,
        user_id: user.id
      })
      |> Niko.Moods.create_mood()

    mood
  end
end
