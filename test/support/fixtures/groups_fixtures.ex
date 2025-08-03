defmodule Niko.GroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Niko.Groups` context.
  """

  @doc """
  Generate a unique group name.
  """
  def unique_group_name, do: "test-group-#{System.unique_integer([:positive])}"

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        name: unique_group_name()
      })
      |> Niko.Groups.create_group()

    group
  end
end
