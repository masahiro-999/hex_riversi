defmodule HexReversiWeb.Game do
  use HexReversiWeb, :live_view

  def render(assigns) do
    ~H"""
      <.live_component module={HexReversiWeb.Components.HexReversiGui} xs="10" ys="10" bomb="10" id={1}/>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, counter: 0)}
  end
end
