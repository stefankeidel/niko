defmodule Niko.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :display_name, :string
    field :email, :string
    field :groups, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:display_name, :email, :groups])
    |> validate_required([:display_name, :email])
    |> validate_length(:display_name, min: 1, max: 100)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/,
      message: "must be a valid email address"
    )
    |> unique_constraint(:email)
    |> validate_groups()
  end

  defp validate_groups(changeset) do
    case get_change(changeset, :groups) do
      nil -> changeset
      groups ->
        case Niko.Groups.validate_groups(groups) do
          {:ok, _} -> changeset
          {:error, invalid_groups} when is_list(invalid_groups) ->
            add_error(changeset, :groups, "contains invalid groups: #{Enum.join(invalid_groups, ", ")}")
          {:error, message} ->
            add_error(changeset, :groups, message)
        end
    end
  end
end
