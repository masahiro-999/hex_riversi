defmodule HexReversiWeb.HexReversiView do
  use Phoenix.LiveView
  use PetalComponents
  alias HexReversi.Board
  require Integer

  @doc """
  Game Board components
  """
  def render(assigns) do
    ~H"""
    <div class="centering_parent">
    <div class="grid grid-cols-1 gap-4 place-content-center">
    <.h1 class="centering_item" >
      <div class="grid grid-cols-2 grid-cols-2 gap-4">
        <div class="centering_item white " style="display: grid;width: 80px;height: 80px;"/>
        <div class="centering_item black " style="display: grid;width: 80px;height: 80px;"/>
        <div class="centering_item"><%= @board.white %></div>
        <div class="centering_item"><%= @board.black %></div>

        <%= if @board.gameover do %>
          <%= if @board.white == @board.black do %>
            <div class="centering_item col-span-2">Draw</div>
          <%= else %>
            <div class="centering_item">Winner</div>
            <div class={"centering_item " <> (if @board.white < @board.black, do: "black", else: "white")}
              style="display: grid;width: 80px;height: 80px;"></div>
          <% end %>
        <%= else %>
          <div class="centering_item">Next</div>
          <div class={"centering_item " <> (if @board.turn==:black, do: "black", else: "white")}
          style="display: grid;width: 80px;height: 80px;"></div>
        <% end %>

      </div>
    </.h1>

    <div class="centering_item" id='map' style={style_string(@board)}>
      <%= for {index, class_string, value} <- create_elements(@board) do %>
      <%= if insert_shit_div(@board, index) do %>
      <%= if index !=0 do %><div></div><% end %>
      <div></div>
      <% end %>
      <div phx-hook="Drag" class={"col-span-2 " <> class_string} phx-click="clicked" id={"cell"<>Integer.to_string(index)} phx-value-pos={index}>
      <%= value %>
      </div>
      <% end %>
    </div>
    <%= if @board.gameover do %>
    <.button class="centering_item" phx-click="new_game">New Game</.button>
    <% end %>
    </div>

    </div>
    """
  end

  def insert_shit_div(board, index) do
    {x,y} = Board.index_to_xy(index, board.xs)
    cond do
      (x==0 and Integer.is_even(y)) -> true
      true -> false
    end
  end

  def mount(_params, _session, socket) do
    board = Board.create_initial_board()
    {:ok, assign(socket, board: board)}
  end


  def handle_event("clicked", %{"pos" => string_pos}, socket) do
    pos = String.to_integer(string_pos)
    {:noreply, update(socket, :board, &Board.put(&1, pos))}
  end

  def handle_event("new_game", _ , socket) do
    board = Board.create_initial_board()
    {:noreply, update(socket, :board, fn _ -> board end)}
  end

  def style_string(board) do
    px = 40
    "display: grid;
      grid-template-columns: repeat(#{board.xs*2+1},#{px}px);
      grid-template-rows: repeat(#{board.ys*2+1},#{px*2}px);
      width: #{board.xs*2*px}px;
      height: #{board.ys*px*2}px;"
  end

  @spec create_elements(atom | %{:xs => integer, :ys => integer, optional(any) => any}) :: list
  def create_elements(board) do
    for index <- 0..(board.xs*board.ys-1) do
      {index, get_class_string(board, index), get_value_string(board, index)}
    end
  end

  def get_class_string(board, index) do
    cell = elem(board.cells, index)
    "cell"
    |> append_str_if(cell == :black, "black")
    |> append_str_if(cell == :white, "white")
  end

  def append_str_if(acc, true, str) do
    acc <> " " <> str
  end

  def append_str_if(acc, false, _str) do
    acc
  end

  def get_value_string(board, index) do
    ""
  end

end
