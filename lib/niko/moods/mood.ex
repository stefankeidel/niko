defmodule Niko.Moods.Mood do
  use Ecto.Schema
  import Ecto.Changeset

  schema "moods" do
    field :date, :date
    field :mood, Ecto.Enum, values: [:horrible, :"not-good", :good, :awesome]
    field :emojis, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mood, attrs) do
    mood
    |> cast(attrs, [:date, :mood, :emojis, :user_id])
    |> validate_required([:date, :mood, :emojis, :user_id])
  end
end
