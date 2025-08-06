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
end
