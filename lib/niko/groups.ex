defmodule Niko.Groups do
  @moduledoc """
  The Groups context with hardcoded group slugs.
  """

  @groups [
    "data_platform","b2c","pricing"
  ]

  @doc """
  Returns the list of available group slugs.

  ## Examples

      iex> list_groups()
      ["engineering", "design", "marketing", "management", "sales", "support"]

  """
  def list_groups do
    @groups
  end

  @doc """
  Returns the list of groups as options for forms.

  ## Examples

      iex> group_options()
      [{"Engineering", "engineering"}, {"Design", "design"}, ...]

  """
  def group_options do
    @groups
    |> Enum.map(fn slug ->
      {humanize_group(slug), slug}
    end)
  end

  @doc """
  Checks if a group slug is valid.

  ## Examples

      iex> valid_group?("engineering")
      true

      iex> valid_group?("invalid")
      false

  """
  def valid_group?(slug) do
    slug in @groups
  end

  @doc """
  Humanizes a group slug for display.

  ## Examples

      iex> humanize_group("engineering")
      "Engineering"

  """
  def humanize_group(slug) do
    slug
    |> String.capitalize()
  end

  @doc """
  Validates a list of group slugs.

  ## Examples

      iex> validate_groups(["engineering", "design"])
      {:ok, ["engineering", "design"]}

      iex> validate_groups(["engineering", "invalid"])
      {:error, ["invalid"]}

  """
  def validate_groups(groups) when is_list(groups) do
    invalid_groups = Enum.reject(groups, &valid_group?/1)

    if Enum.empty?(invalid_groups) do
      {:ok, groups}
    else
      {:error, invalid_groups}
    end
  end

  def validate_groups(_), do: {:error, "Groups must be a list"}
end
