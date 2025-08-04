defmodule NikoWeb.MoodLive.Index do
  use NikoWeb, :live_view

  alias Niko.Moods
  alias Niko.Moods.Mood

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to user selection changes for real-time updates
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Niko.PubSub, "user_selection")
    end

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
    socket
    |> assign(:page_title, "New Mood")
    |> assign(:mood, %Mood{})
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
