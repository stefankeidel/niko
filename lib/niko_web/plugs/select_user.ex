defmodule NikoWeb.Plugs.SelectUser do
  import Plug.Conn
  alias Niko.Accounts

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    selected_user = get_current_user(conn)
    assign(conn, :current_user, selected_user)
  end

  defp get_current_user(conn) do
    # First try to get user from stored selected_user_id
    case get_session(conn, :selected_user_id) do
      nil ->
        # If no stored user_id, try to get user from Microsoft token
        get_user_from_token(conn)

      user_id when is_integer(user_id) ->
        # Try to get user from database
        try do
          Accounts.get_user!(user_id)
        rescue
          Ecto.NoResultsError ->
            # If user doesn't exist in DB, try to get from token
            get_user_from_token(conn)
        end
    end
  end

  defp get_user_from_token(conn) do
    case get_session(conn, :token) do
      nil ->
        nil

      token ->
        try do
          # Get user profile from Microsoft using the stored token
          case ElixirAuthMicrosoft.get_user_profile(token.access_token) do
            {:ok, profile} ->
              # Find or create user in our database
              user_attrs = %{
                email: profile.userPrincipalName,
                display_name: profile.displayName
              }

              case Accounts.find_or_create_user_by_email(user_attrs) do
                {:ok, user} ->
                  user

                {:error, _changeset} ->
                  nil
              end

            {:error, _reason} ->
              # Token might be expired or invalid
              nil
          end
        rescue
          # Handle any unexpected errors (e.g., network issues, malformed token)
          _error ->
            nil
        end
    end
  end
end
