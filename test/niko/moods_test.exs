defmodule Niko.MoodsTest do
  use Niko.DataCase

  alias Niko.Moods

  describe "moods" do
    alias Niko.Moods.Mood

    import Niko.MoodsFixtures

    @invalid_attrs %{date: nil, mood: nil, emojis: nil}

    test "list_moods/0 returns all moods" do
      mood = mood_fixture()
      assert Moods.list_moods() == [mood]
    end

    test "get_mood!/1 returns the mood with given id" do
      mood = mood_fixture()
      assert Moods.get_mood!(mood.id) == mood
    end

    test "create_mood/1 with valid data creates a mood" do
      valid_attrs = %{date: ~D[2025-08-03], mood: :horrible, emojis: "some emojis"}

      assert {:ok, %Mood{} = mood} = Moods.create_mood(valid_attrs)
      assert mood.date == ~D[2025-08-03]
      assert mood.mood == :horrible
      assert mood.emojis == "some emojis"
    end

    test "create_mood/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Moods.create_mood(@invalid_attrs)
    end

    test "update_mood/2 with valid data updates the mood" do
      mood = mood_fixture()
      update_attrs = %{date: ~D[2025-08-04], mood: :"not-good", emojis: "some updated emojis"}

      assert {:ok, %Mood{} = mood} = Moods.update_mood(mood, update_attrs)
      assert mood.date == ~D[2025-08-04]
      assert mood.mood == :"not-good"
      assert mood.emojis == "some updated emojis"
    end

    test "update_mood/2 with invalid data returns error changeset" do
      mood = mood_fixture()
      assert {:error, %Ecto.Changeset{}} = Moods.update_mood(mood, @invalid_attrs)
      assert mood == Moods.get_mood!(mood.id)
    end

    test "delete_mood/1 deletes the mood" do
      mood = mood_fixture()
      assert {:ok, %Mood{}} = Moods.delete_mood(mood)
      assert_raise Ecto.NoResultsError, fn -> Moods.get_mood!(mood.id) end
    end

    test "change_mood/1 returns a mood changeset" do
      mood = mood_fixture()
      assert %Ecto.Changeset{} = Moods.change_mood(mood)
    end
  end
end
