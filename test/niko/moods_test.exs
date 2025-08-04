defmodule Niko.MoodsTest do
  use Niko.DataCase

  alias Niko.Moods

  describe "moods" do
    alias Niko.Moods.Mood

    import Niko.MoodsFixtures
    import Niko.AccountsFixtures

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
      user = user_fixture()
      valid_attrs = %{date: ~D[2025-08-03], mood: :horrible, emojis: "😊", user_id: user.id}

      assert {:ok, %Mood{} = mood} = Moods.create_mood(valid_attrs)
      assert mood.date == ~D[2025-08-03]
      assert mood.mood == :horrible
      assert mood.emojis == "😊"
    end

    test "create_mood/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Moods.create_mood(@invalid_attrs)
    end

    test "update_mood/2 with valid data updates the mood" do
      mood = mood_fixture()
      update_attrs = %{date: ~D[2025-08-04], mood: :not_good, emojis: "🎉"}

      assert {:ok, %Mood{} = mood} = Moods.update_mood(mood, update_attrs)
      assert mood.date == ~D[2025-08-04]
      assert mood.mood == :not_good
      assert mood.emojis == "🎉"
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

    test "create_mood/1 with valid emoji lengths" do
      user = user_fixture()

      # Test single emoji
      assert {:ok, %Mood{} = mood} =
               Moods.create_mood(%{date: ~D[2025-08-03], emojis: "😊", user_id: user.id})

      assert mood.emojis == "😊"

      # Test two characters
      assert {:ok, %Mood{} = mood} =
               Moods.create_mood(%{date: ~D[2025-08-04], emojis: "Hi", user_id: user.id})

      assert mood.emojis == "Hi"

      # Test empty string (Ecto normalizes empty strings to nil)
      assert {:ok, %Mood{} = mood} =
               Moods.create_mood(%{date: ~D[2025-08-05], emojis: "", user_id: user.id})

      assert mood.emojis == nil

      # Test nil
      assert {:ok, %Mood{} = mood} =
               Moods.create_mood(%{date: ~D[2025-08-06], emojis: nil, user_id: user.id})

      assert mood.emojis == nil
    end

    test "create_mood/1 with invalid emoji lengths" do
      user = user_fixture()

      # Test three characters
      assert {:error, %Ecto.Changeset{} = changeset} =
               Moods.create_mood(%{date: ~D[2025-08-03], emojis: "ABC", user_id: user.id})

      assert %{emojis: ["should be at most 2 characters"]} = errors_on(changeset)

      # Test long string
      assert {:error, %Ecto.Changeset{} = changeset} =
               Moods.create_mood(%{date: ~D[2025-08-04], emojis: "Hello World", user_id: user.id})

      assert %{emojis: ["should be at most 2 characters"]} = errors_on(changeset)

      # Test multiple emojis (if they exceed 2 characters)
      assert {:error, %Ecto.Changeset{} = changeset} =
               Moods.create_mood(%{date: ~D[2025-08-05], emojis: "😊🎉🚀", user_id: user.id})

      assert %{emojis: ["should be at most 2 characters"]} = errors_on(changeset)
    end
  end
end
