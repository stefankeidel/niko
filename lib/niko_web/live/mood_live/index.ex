defmodule NikoWeb.MoodLive.Index do
  use NikoWeb, :live_view

  alias Niko.Moods
  alias Niko.Moods.Mood
  alias Niko.Accounts

  @impl true
  def mount(_params, session, socket) do
    # Get current user from session
    current_user =
      case Map.get(session, "selected_user_id") do
        nil ->
          nil

        user_id ->
          try do
            Accounts.get_user!(user_id)
          rescue
            Ecto.NoResultsError -> nil
          end
      end

    # Initialize with current month/year
    today = Date.utc_today()
    current_month = today.month
    current_year = today.year

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:current_month, current_month)
      |> assign(:current_year, current_year)
      |> assign(:today, today)
      # Initialize to prevent nil errors
      |> assign(:weekend_days, %{})
      |> load_calendar_data()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("navigate_month", %{"direction" => "prev"}, socket) do
    socket = navigate_month(socket, -1)
    {:noreply, socket}
  end

  def handle_event("navigate_month", %{"direction" => "next"}, socket) do
    socket = navigate_month(socket, 1)
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    mood = Moods.get_mood!(id)
    {:ok, _} = Moods.delete_mood(mood)

    socket = load_calendar_data(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({NikoWeb.MoodLive.FormComponent, {:saved, _mood}}, socket) do
    socket =
      socket
      |> load_calendar_data()
      |> put_flash(:info, "Mood saved successfully")

    {:noreply, socket}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Mood")
    |> assign(:mood, Moods.get_mood!(id))
  end

  defp apply_action(socket, :new, params) do
    user_id =
      case Map.get(params, "user_id") do
        nil -> if socket.assigns.current_user, do: socket.assigns.current_user.id, else: nil
        id -> String.to_integer(id)
      end

    date =
      case Map.get(params, "date") do
        nil -> Date.utc_today()
        date_string -> Date.from_iso8601!(date_string)
      end

    socket
    |> assign(:page_title, "New Mood")
    |> assign(:mood, %Mood{user_id: user_id, date: date})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Calendar View")
    |> assign(:mood, nil)
  end

  # Calendar helper functions
  defp load_calendar_data(socket) do
    %{current_month: month, current_year: year} = socket.assigns

    users = Accounts.list_users()
    moods = get_moods_for_month(month, year)
    calendar_data = build_calendar_data(users, moods)
    days_in_month = Date.days_in_month(Date.new!(year, month, 1))

    # Use Calendar.strftime for month name
    date = Date.new!(year, month, 1)
    month_name = Calendar.strftime(date, "%B")

    # Create weekend info for each day
    weekend_days =
      1..days_in_month
      |> Enum.map(fn day ->
        date = Date.new!(year, month, day)
        {day, weekend?(date)}
      end)
      |> Map.new()

    IO.inspect(weekend_days, label: "Weekend Days")

    socket
    |> assign(:users, users)
    |> assign(:calendar_data, calendar_data)
    |> assign(:days_in_month, days_in_month)
    |> assign(:month_name, month_name)
    |> assign(:weekend_days, weekend_days)
  end

  defp navigate_month(socket, direction) do
    %{current_month: month, current_year: year} = socket.assigns

    {new_month, new_year} =
      case month + direction do
        0 -> {12, year - 1}
        13 -> {1, year + 1}
        new_month -> {new_month, year}
      end

    socket
    |> assign(:current_month, new_month)
    |> assign(:current_year, new_year)
    |> load_calendar_data()
  end

  defp get_moods_for_month(month, year) do
    start_date = Date.new!(year, month, 1)
    end_date = Date.end_of_month(start_date)

    Moods.list_moods()
    |> Enum.filter(fn mood ->
      Date.compare(mood.date, start_date) in [:gt, :eq] and
        Date.compare(mood.date, end_date) in [:lt, :eq]
    end)
  end

  defp build_calendar_data(users, moods) do
    # Create a map of user_id -> date -> mood
    mood_map =
      moods
      |> Enum.group_by(& &1.user_id)
      |> Map.new(fn {user_id, user_moods} ->
        date_mood_map =
          user_moods
          |> Map.new(fn mood -> {mood.date.day, mood} end)

        {user_id, date_mood_map}
      end)

    # Ensure all users have an entry, even if empty
    users
    |> Map.new(fn user ->
      {user.id, Map.get(mood_map, user.id, %{})}
    end)
  end

  # Helper function to determine if a date is a weekend (Saturday or Sunday)
  defp weekend?(date) do
    day_of_week = Date.day_of_week(date)
    # Saturday = 6, Sunday = 7
    day_of_week == 6 || day_of_week == 7
  end

  # Helper function to get mood display info
  def mood_display_class(:awesome), do: "bg-green-500 text-white"
  def mood_display_class(:good), do: "bg-yellow-500 text-white"
  def mood_display_class(:"not-good"), do: "bg-orange-500 text-white"
  def mood_display_class(:horrible), do: "bg-red-500 text-white"
  def mood_display_class(_), do: "bg-gray-100 text-gray-500"
end
