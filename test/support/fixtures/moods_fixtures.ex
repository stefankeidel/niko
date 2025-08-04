defmodule Niko.MoodsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Niko.Moods` context.
  """

  @doc """
  Generate a mood.
  """
  def mood_fixture(attrs \\ %{}) do
    {:ok, mood} =
      attrs
      |> Enum.into(%{
        date: ~D[2025-08-03],
        emojis: "some emojis",
        mood: :horrible
      })
      |> Niko.Moods.create_mood()

    mood
  end
end
