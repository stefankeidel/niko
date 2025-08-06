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
