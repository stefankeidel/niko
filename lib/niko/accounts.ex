defmodule Niko.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Niko.Repo

  alias Niko.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Gets a user with preloaded groups.

  ## Examples

      iex> get_user_with_groups!(123)
      %User{groups: [%Group{}, ...]}

  """
  def get_user_with_groups!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:groups)
  end

  @doc """
  Lists all groups for a user.

  ## Examples

      iex> list_user_groups(user)
      [%Group{}, ...]

  """
  def list_user_groups(%User{} = user) do
    user
    |> Repo.preload(:groups)
    |> Map.get(:groups)
  end

  @doc """
  Adds a user to a group.

  ## Examples

      iex> add_user_to_group(user, group)
      {:ok, %User{}}

  """
  def add_user_to_group(%User{} = user, %Niko.Groups.Group{} = group) do
    user = Repo.preload(user, :groups)

    # Check if user is already in the group
    if Enum.any?(user.groups, &(&1.id == group.id)) do
      {:ok, user}
    else
      # Insert into join table with timestamps
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      case Repo.insert_all(
             "users_groups",
             [
               %{
                 user_id: user.id,
                 group_id: group.id,
                 inserted_at: now,
                 updated_at: now
               }
             ],
             on_conflict: :nothing
           ) do
        {1, _} -> {:ok, Repo.preload(user, :groups, force: true)}
        # Already exists, no-op
        {0, _} -> {:ok, user}
        _ -> {:error, :insert_failed}
      end
    end
  end

  @doc """
  Removes a user from a group.

  ## Examples

      iex> remove_user_from_group(user, group)
      {:ok, %User{}}

  """
  def remove_user_from_group(%User{} = user, %Niko.Groups.Group{} = group) do
    user = Repo.preload(user, :groups)
    updated_groups = Enum.reject(user.groups, &(&1.id == group.id))

    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:groups, updated_groups)
    |> Repo.update()
  end
end
