defmodule NikoWeb.MicrosoftAuthController do
  use NikoWeb, :controller

  alias Niko.Accounts

  @doc """
  `index/2` handles the callback from Microsoft Auth API redirect.
  """
  def index(conn, %{"code" => code, "state" => state}) do
    # Perform state change here (to prevent CSRF)
    if state !== "random_uuid_here" do
      # error handling
    end

    {:ok, token} = ElixirAuthMicrosoft.get_token(code, conn)

    # Get user profile from Microsoft
    {:ok, profile} = ElixirAuthMicrosoft.get_user_profile(token.access_token)

    # Find or create user in our database
    user_attrs = %{
      email: profile.userPrincipalName,
      display_name: profile.displayName
    }

    case Accounts.find_or_create_user_by_email(user_attrs) do
      {:ok, user} ->
        # remove id_token from token, otherwise the cookie gets too big
        token = Map.drop(token, [:id_token])

        conn
        |> put_session(:token, token)
        |> put_session(:selected_user_id, user.id)
        |> redirect(to: "/moods")

      {:error, _changeset} ->
        # Handle error case - for now just redirect with error
        conn
        |> put_flash(:error, "Failed to create user account")
        |> redirect(to: "/")
    end
  end
end
