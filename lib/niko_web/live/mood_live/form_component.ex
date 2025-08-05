defmodule NikoWeb.MoodLive.FormComponent do
  use NikoWeb, :live_component

  alias Niko.Moods

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.simple_form
        for={@form}
        id="mood-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-4"
      >
        <div class="flex items-center space-x-2">
          <span class="text-2xl">📅</span>
          <.input field={@form[:date]} type="date" label="Date" />
        </div>

        <%= if @future_date? do %>
          <div class="bg-blue-50 border-l-4 border-blue-400 p-4 rounded-r-lg">
            <div class="flex items-center">
              <span class="text-2xl mr-3">🔮</span>
              <div>
                <h3 class="text-sm font-medium text-blue-800">Future Date Selected</h3>
                <p class="text-sm text-blue-700 mt-1">
                  You can't set a mood for future dates yet. Time travel hasn't been invented!
                  But you can still add emojis to plan your day.
                </p>
              </div>
            </div>
          </div>
        <% else %>
          <div class="flex items-center space-x-2">
            <span class="text-2xl">😊</span>
            <.input
              field={@form[:mood]}
              type="select"
              label="How were you feeling?"
              prompt="Choose your mood..."
              options={[
                {"😱 Horrible", :horrible},
                {"😕 Not Good", :not_good},
                {"😊 Good", :good},
                {"🤩 Awesome", :awesome}
              ]}
            />
          </div>
        <% end %>

        <div class="space-y-3">
          <div class="flex items-center space-x-2">
            <span class="text-2xl">✨</span>
            <.input
              field={@form[:emojis]}
              type="text"
              label="Emojis (max 2)"
              placeholder="Special emojis about this day"
              id="emojis-input"
            />
          </div>

          <div class="ml-8">
            <label class="block text-sm font-medium text-gray-700 mb-2">Quick emojis:</label>
            <div class="flex space-x-2">
              <button
                type="button"
                class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md shadow-sm bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200"
                onclick="insertEmoji('🏭')"
                title="Office HH"
              >
                <span class="text-xl mr-2">🏭</span>
                <span class="text-sm text-gray-700">Office Hamburg</span>
              </button>

              <button
                type="button"
                class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md shadow-sm bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200"
                onclick="insertEmoji('🌴')"
                title="Vacation"
              >
                <span class="text-xl mr-2">🌴</span>
                <span class="text-sm text-gray-700">Vacation</span>
              </button>

              <button
                type="button"
                class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md shadow-sm bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200"
                onclick="insertEmoji('🚀')"
                title="Slack Day"
              >
                <span class="text-xl mr-2">🚀</span>
                <span class="text-sm text-gray-700">Slack Day</span>
              </button>
            </div>
          </div>
        </div>

        <:actions>
          <.button
            phx-disable-with="Saving..."
            class="w-full bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white font-medium py-2 px-4 rounded-lg transition-all duration-200 transform hover:scale-105"
          >
            Save
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{mood: mood} = assigns, socket) do
    # Determine if the mood's date is in the future
    today = Date.utc_today()
    mood_date = mood.date || today
    future_date? = Date.compare(mood_date, today) == :gt

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:future_date?, future_date?)
     |> assign_new(:form, fn ->
       to_form(Moods.change_mood(mood))
     end)}
  end

  @impl true
  def handle_event("validate", %{"mood" => mood_params}, socket) do
    changeset = Moods.change_mood(socket.assigns.mood, mood_params)

    # Re-check if date is in the future when validating
    today = Date.utc_today()

    new_date =
      case Map.get(mood_params, "date") do
        nil -> socket.assigns.mood.date || today
        date_string -> Date.from_iso8601!(date_string)
      end

    future_date? = Date.compare(new_date, today) == :gt

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))
     |> assign(:future_date?, future_date?)}
  end

  def handle_event("save", %{"mood" => mood_params}, socket) do
    save_mood(socket, socket.assigns.action, mood_params)
  end

  defp save_mood(socket, :edit, mood_params) do
    # Authorization check: ensure user can only edit their own moods
    if socket.assigns.current_user &&
         socket.assigns.mood.user_id == socket.assigns.current_user.id do
      # Clear mood for future dates
      mood_params_processed =
        if socket.assigns.future_date? do
          Map.put(mood_params, "mood", nil)
        else
          mood_params
        end

      # Ensure user_id cannot be changed to someone else's ID
      mood_params_with_user =
        Map.put(mood_params_processed, "user_id", socket.assigns.current_user.id)

      case Moods.update_mood(socket.assigns.mood, mood_params_with_user) do
        {:ok, mood} ->
          notify_parent({:saved, mood})

          success_message =
            if socket.assigns.future_date?,
              do: "Note saved successfully!",
              else: "Mood updated successfully"

          {:noreply,
           socket
           |> put_flash(:info, success_message)
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "You can only edit your own moods")
       |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp save_mood(socket, :new, mood_params) do
    # Authorization check: ensure user can only create moods for themselves
    if socket.assigns.current_user do
      # Clear mood for future dates
      mood_params_processed =
        if socket.assigns.future_date? do
          Map.put(mood_params, "mood", nil)
        else
          mood_params
        end

      # Ensure user_id is locked to current user
      mood_params_with_user =
        Map.put(mood_params_processed, "user_id", socket.assigns.current_user.id)

      case Moods.create_mood(mood_params_with_user) do
        {:ok, mood} ->
          notify_parent({:saved, mood})

          success_message =
            if socket.assigns.future_date?,
              do: "Note created successfully!",
              else: "Mood created successfully"

          {:noreply,
           socket
           |> put_flash(:info, success_message)
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "You must be logged in to create moods")
       |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
