defmodule Niko.Repo.Migrations.CreateMoods do
  use Ecto.Migration

  def change do
    create table(:moods) do
      add :date, :date
      add :mood, :string
      add :emojis, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:moods, [:user_id])
  end
end
