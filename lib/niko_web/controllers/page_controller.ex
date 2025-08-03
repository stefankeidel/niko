defmodule NikoWeb.PageController do
  use NikoWeb, :controller
  alias Niko.Accounts

  def home(conn, _params) do
    users = Accounts.list_users()

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, users: users, selected_user: conn.assigns[:current_user])
  end

  def select_user(conn, %{"user_id" => user_id}) when user_id != "" do
    user = Accounts.get_user!(user_id)

    conn
    |> put_session(:selected_user_id, user.id)
    |> put_flash(:info, "Selected user: #{user.display_name}")
    |> redirect(to: ~p"/")
  end

  def select_user(conn, %{"user_id" => ""}) do
    conn
    |> delete_session(:selected_user_id)
    |> put_flash(:info, "User selection cleared")
    |> redirect(to: ~p"/")
  end

  def select_user(conn, _params) do
    conn
    |> put_flash(:error, "Please select a user")
    |> redirect(to: ~p"/")
  end
end
