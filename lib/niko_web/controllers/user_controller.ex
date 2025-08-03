defmodule NikoWeb.UserController do
  use NikoWeb, :controller

  alias Niko.Accounts
  alias Niko.Accounts.User
  alias Niko.Groups

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user_with_groups!(id)
    all_groups = Groups.list_groups()

    available_groups =
      Enum.reject(all_groups, fn group ->
        Enum.any?(user.groups, &(&1.id == group.id))
      end)

    render(conn, :show, user: user, available_groups: available_groups)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, :edit, user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: ~p"/users")
  end

  def add_group(conn, %{"user_id" => user_id, "group_id" => group_id} = _params)
      when group_id != "" do
    user = Accounts.get_user!(user_id)
    group = Groups.get_group!(group_id)

    case Accounts.add_user_to_group(user, group) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User added to group successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to add user to group.")
        |> redirect(to: ~p"/users/#{user}")
    end
  end

  def add_group(conn, %{"user_id" => user_id, "group_id" => ""} = _params) do
    user = Accounts.get_user!(user_id)

    conn
    |> put_flash(:error, "Please select a group.")
    |> redirect(to: ~p"/users/#{user}")
  end

  def remove_group(conn, %{"user_id" => user_id, "group_id" => group_id}) do
    user = Accounts.get_user!(user_id)
    group = Groups.get_group!(group_id)

    case Accounts.remove_user_from_group(user, group) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User removed from group successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to remove user from group.")
        |> redirect(to: ~p"/users/#{user}")
    end
  end
end
