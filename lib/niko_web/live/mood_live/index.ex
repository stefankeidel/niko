defmodule NikoWeb.MoodLive.Index do
  use NikoWeb, :live_view

  alias Niko.Moods
  alias Niko.Moods.Mood

  @impl true
  def mount(_params, session, socket) do
    # Get current user from session
    current_user =
      case Map.get(session, "selected_user_id") do
        nil ->
          nil

        user_id ->
          try do
            Niko.Accounts.get_user!(user_id)
          rescue
            Ecto.NoResultsError -> nil
          end
      end

    socket = assign(socket, :current_user, current_user)
    {:ok, stream(socket, :moods, Moods.list_moods())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Mood")
    |> assign(:mood, Moods.get_mood!(id))
  end

  defp apply_action(socket, :new, _params) do
    user_id = if socket.assigns.current_user, do: socket.assigns.current_user.id, else: nil

    socket
    |> assign(:page_title, "New Mood")
    |> assign(:mood, %Mood{user_id: user_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Moods")
    |> assign(:mood, nil)
  end

  @impl true
  def handle_info({NikoWeb.MoodLive.FormComponent, {:saved, mood}}, socket) do
    {:noreply, stream_insert(socket, :moods, mood)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    mood = Moods.get_mood!(id)
    {:ok, _} = Moods.delete_mood(mood)

    {:noreply, stream_delete(socket, :moods, mood)}
  end
end
