defmodule HexReversiWeb.PageController do
  use HexReversiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
