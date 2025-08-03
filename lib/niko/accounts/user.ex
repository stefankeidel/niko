defmodule Niko.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :display_name, :string
    field :email, :string

    many_to_many :groups, Niko.Groups.Group, join_through: "users_groups", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:display_name, :email])
    |> validate_required([:display_name, :email])
    |> validate_length(:display_name, min: 1, max: 100)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/,
      message: "must be a valid email address"
    )
    |> unique_constraint(:email)
  end

  @doc false
  def changeset_with_groups(user, attrs) do
    user
    |> cast(attrs, [:display_name, :email])
    |> validate_required([:display_name, :email])
    |> validate_length(:display_name, min: 1, max: 100)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/,
      message: "must be a valid email address"
    )
    |> unique_constraint(:email)
    |> cast_assoc(:groups)
  end
end
