defmodule Niko.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :display_name, :string
      add :email, :string
      add :groups, {:array, :string}, default: []

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
