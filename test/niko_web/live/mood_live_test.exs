defmodule NikoWeb.MoodLiveTest do
  use NikoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Niko.MoodsFixtures

  @create_attrs %{date: "2025-08-03", mood: :horrible, emojis: "some emojis"}
  @update_attrs %{date: "2025-08-04", mood: :not_good, emojis: "some updated emojis"}
  @invalid_attrs %{date: nil, mood: nil, emojis: nil}

  defp create_mood(_) do
    mood = mood_fixture()
    %{mood: mood}
  end

  describe "Index" do
    setup [:create_mood]

    test "lists all moods", %{conn: conn, mood: mood} do
      {:ok, _index_live, html} = live(conn, ~p"/moods")

      assert html =~ "Listing Moods"
      assert html =~ mood.emojis
    end

    test "saves new mood", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/moods")

      assert index_live |> element("a", "New Mood") |> render_click() =~
               "New Mood"

      assert_patch(index_live, ~p"/moods/new")

      assert index_live
             |> form("#mood-form", mood: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mood-form", mood: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/moods")

      html = render(index_live)
      assert html =~ "Mood created successfully"
      assert html =~ "some emojis"
    end

    test "updates mood in listing", %{conn: conn, mood: mood} do
      {:ok, index_live, _html} = live(conn, ~p"/moods")

      assert index_live |> element("#moods-#{mood.id} a", "Edit") |> render_click() =~
               "Edit Mood"

      assert_patch(index_live, ~p"/moods/#{mood}/edit")

      assert index_live
             |> form("#mood-form", mood: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mood-form", mood: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/moods")

      html = render(index_live)
      assert html =~ "Mood updated successfully"
      assert html =~ "some updated emojis"
    end

    test "deletes mood in listing", %{conn: conn, mood: mood} do
      {:ok, index_live, _html} = live(conn, ~p"/moods")

      assert index_live |> element("#moods-#{mood.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#moods-#{mood.id}")
    end
  end

  describe "Show" do
    setup [:create_mood]

    test "displays mood", %{conn: conn, mood: mood} do
      {:ok, _show_live, html} = live(conn, ~p"/moods/#{mood}")

      assert html =~ "Show Mood"
      assert html =~ mood.emojis
    end

    test "updates mood within modal", %{conn: conn, mood: mood} do
      {:ok, show_live, _html} = live(conn, ~p"/moods/#{mood}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Mood"

      assert_patch(show_live, ~p"/moods/#{mood}/show/edit")

      assert show_live
             |> form("#mood-form", mood: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#mood-form", mood: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/moods/#{mood}")

      html = render(show_live)
      assert html =~ "Mood updated successfully"
      assert html =~ "some updated emojis"
    end
  end
end
