defmodule NikoWeb.Plugs.SelectUser do
  import Plug.Conn
  alias Niko.Accounts

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    selected_user_id = get_session(conn, :selected_user_id)

    selected_user =
      if selected_user_id do
        try do
          Accounts.get_user!(selected_user_id)
        rescue
          Ecto.NoResultsError -> nil
        end
      else
        nil
      end

    assign(conn, :current_user, selected_user)
  end
end
