defmodule NikoWeb.Live.UserAuth do
  @moduledoc """
  LiveView hook for handling user authentication based on session.

  This module provides an on_mount callback that extracts the selected_user_id
  from the session and assigns the current user to the LiveView socket.
  """

  import Phoenix.Component, only: [assign: 3]

  alias Niko.Accounts

  def on_mount(:default, _params, %{"selected_user_id" => user_id} = _session, socket)
      when is_integer(user_id) do
    current_user =
      try do
        Accounts.get_user!(user_id)
      rescue
        Ecto.NoResultsError -> nil
      end

    IO.puts("Selected user found: #{inspect(current_user)}")
    {:cont, assign(socket, :current_user, current_user)}
  end

  def on_mount(:default, _params, _session, socket) do
    {:cont, assign(socket, :current_user, nil)}
  end
end
