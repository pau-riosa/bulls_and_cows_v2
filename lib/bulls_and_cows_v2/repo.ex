defmodule BullsAndCowsV2.Repo do
  use Ecto.Repo,
    otp_app: :bulls_and_cows_v2,
    adapter: Ecto.Adapters.Postgres
end
