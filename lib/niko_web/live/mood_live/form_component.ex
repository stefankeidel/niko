defmodule NikoWeb.MoodLive.FormComponent do
  use NikoWeb, :live_component

  alias Niko.Moods

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage mood records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="mood-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:date]} type="date" label="Date" />
        <.input
          field={@form[:mood]}
          type="select"
          label="Mood"
          prompt="Choose a value"
          options={Ecto.Enum.values(Niko.Moods.Mood, :mood)}
        />
        <.input field={@form[:emojis]} type="text" label="Emojis" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Mood</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{mood: mood} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Moods.change_mood(mood))
     end)}
  end

  @impl true
  def handle_event("validate", %{"mood" => mood_params}, socket) do
    changeset = Moods.change_mood(socket.assigns.mood, mood_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"mood" => mood_params}, socket) do
    save_mood(socket, socket.assigns.action, mood_params)
  end

  defp save_mood(socket, :edit, mood_params) do
    case Moods.update_mood(socket.assigns.mood, mood_params) do
      {:ok, mood} ->
        notify_parent({:saved, mood})

        {:noreply,
         socket
         |> put_flash(:info, "Mood updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_mood(socket, :new, mood_params) do
    case Moods.create_mood(mood_params) do
      {:ok, mood} ->
        notify_parent({:saved, mood})

        {:noreply,
         socket
         |> put_flash(:info, "Mood created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
