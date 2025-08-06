defmodule NikoWeb.MicrosoftAuthController do
  use NikoWeb, :controller

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  def index(conn, %{"code" => code, "state" => state}) do
    # Perform state change here (to prevent CSRF)
    if state !== "random_uuid_here" do
      # error handling
    end

    {:ok, token} = ElixirAuthMicrosoft.get_token(code, conn)

    IO.inspect(token, label: "Token received from Microsoft")
    IO.inspect(get_session(conn), label: "Session")

    # remove key access token from token
    token = Map.drop(token, [:id_token])

    conn
    |> put_session(:token, token)
    |> redirect(to: "/welcome")
  end
end
