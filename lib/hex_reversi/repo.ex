defmodule HexReversi.Repo do
  use Ecto.Repo,
    otp_app: :hex_reversi,
    adapter: Ecto.Adapters.Postgres
end
