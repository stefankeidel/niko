defmodule Niko.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias Niko.Repo

  alias Niko.Groups.Group

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  @doc """
  Gets a group with preloaded users.

  ## Examples

      iex> get_group_with_users!(123)
      %Group{users: [%User{}, ...]}

  """
  def get_group_with_users!(id) do
    Group
    |> Repo.get!(id)
    |> Repo.preload(:users)
  end

  @doc """
  Lists all users in a group.

  ## Examples

      iex> list_group_users(group)
      [%User{}, ...]

  """
  def list_group_users(%Group{} = group) do
    group
    |> Repo.preload(:users)
    |> Map.get(:users)
  end

  @doc """
  Adds a user to a group.

  ## Examples

      iex> add_group_member(group, user)
      {:ok, %Group{}}

  """
  def add_group_member(%Group{} = group, %Niko.Accounts.User{} = user) do
    group
    |> Repo.preload(:users)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:users, [user | group.users])
    |> Repo.update()
  end

  @doc """
  Removes a user from a group.

  ## Examples

      iex> remove_group_member(group, user)
      {:ok, %Group{}}

  """
  def remove_group_member(%Group{} = group, %Niko.Accounts.User{} = user) do
    group = Repo.preload(group, :users)
    updated_users = Enum.reject(group.users, &(&1.id == user.id))

    group
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:users, updated_users)
    |> Repo.update()
  end
end
