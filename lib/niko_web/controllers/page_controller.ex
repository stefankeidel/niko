defmodule NikoWeb.PageController do
  use NikoWeb, :controller
  alias Niko.Accounts

  def home(conn, _params) do
    users = Accounts.list_users()

    oauth_microsoft_url =
      ElixirAuthMicrosoft.generate_oauth_url_authorize(
        conn,
        "random_uuid_here"
      )

    render(conn, :home,
      users: users,
      selected_user: conn.assigns[:current_user],
      oauth_microsoft_url: oauth_microsoft_url
    )
  end

  def select_user(conn, %{"user_id" => user_id}) when user_id != "" do
    user = Accounts.get_user!(user_id)

    # Broadcast user selection to all LiveViews
    Phoenix.PubSub.broadcast(Niko.PubSub, "user_selection", {:user_selected, user})

    conn
    |> put_session(:selected_user_id, user.id)
    |> put_flash(:info, "Selected user: #{user.display_name}")
    |> redirect(to: ~p"/")
  end

  def select_user(conn, %{"user_id" => ""}) do
    # Broadcast user deselection to all LiveViews
    Phoenix.PubSub.broadcast(Niko.PubSub, "user_selection", {:user_deselected})

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

  def welcome(conn, _params) do
    # Check if there's a session token
    case conn |> get_session(:token) do
      # If not, we redirect the person to the login page
      nil ->
        conn |> redirect(to: "/")

      # If there's a token, we render the welcome page
      token ->
        {:ok, profile} = ElixirAuthMicrosoft.get_user_profile(token.access_token)

        conn
        |> put_view(NikoWeb.PageHTML)
        |> render(:welcome, profile: profile)
    end
  end
end
