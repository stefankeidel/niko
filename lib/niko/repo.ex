defmodule Niko.Repo do
  use Ecto.Repo,
    otp_app: :niko,
    adapter: Ecto.Adapters.Postgres
end
