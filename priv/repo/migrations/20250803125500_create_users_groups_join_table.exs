defmodule Niko.Repo.Migrations.CreateUsersGroupsJoinTable do
  use Ecto.Migration

  def change do
    create table(:users_groups, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users_groups, [:user_id, :group_id])
    create index(:users_groups, [:user_id])
    create index(:users_groups, [:group_id])
  end
end
