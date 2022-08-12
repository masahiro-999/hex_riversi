defmodule HexReversi.Board do
  require Integer

  defstruct [
    xs: 8,
    ys: 8,
    cells: nil,
    gameover: false,
    turn: :black,
    white: 0,
    black: 0,
    pass: false
  ]

  def create_initial_board() do
    xs = ys = 8
    initial_cells =[
      {xy_to_index({3,3}, xs), :black},
      {xy_to_index({4,4}, xs), :black},
      {xy_to_index({3,4}, xs), :white},
      {xy_to_index({4,3}, xs), :white},
    ]

    cells = Enum.reduce(
      initial_cells,
      Tuple.duplicate(:none, xs*ys),
      fn ({index, value}, acc) -> put_elem(acc, index, value) end
      )

    %__MODULE__{
      cells: cells,
      gameover: false,
      turn: :black,
      white: 2,
      black: 2,
      pass: false
    }
  end

  def put(board = %__MODULE__{}, index) do
    cond do
      can_put?(board, index, board.turn) -> turn_over(board, index, board.turn) |> change_turn() |> update_score()
      true -> board
    end
  end

  def change_turn(board = %__MODULE__{}) do
    next_turn = get_next_turn(board)
    cond do
      can_put?(board, next_turn) -> %{board| turn: next_turn}
      can_put?(board, board.turn) -> %{board| turn: board.turn}
      true -> make_game_over(board)
    end
  end

  def get_next_turn(board = %__MODULE__{}) do
    case board.turn do
      :black -> :white
      :white -> :black
      _ -> :black
    end
  end

  def can_put?(board = %__MODULE__{}, turn) do
    Tuple.to_list(board.cells)
    |> Enum.with_index()
    |> Enum.filter(fn {value, _index} -> value not in [:white, :black] end)
    |> Enum.map(fn({_value, index}) -> can_put?(board, index, turn) end)
    |> Enum.any?()
    end

  def can_put?(board = %__MODULE__{}, index, turn) do
    cond do
      elem(board.cells, index) in [:white, :black] -> false
      true -> can_turn_over?(board, index, turn)
    end
  end

  def can_turn_over?(board = %__MODULE__{}, index, turn) do
    0..5
    |> Enum.map(&can_turn_over?(board, index, turn, &1))
    |> Enum.any?()
  end

  def can_turn_over?(board = %__MODULE__{}, index, turn, dir) do
    case get_neighber(board, index, dir) do
      {^turn, _} -> false
      {:NG, _} -> false
      {:white, index} -> search_until_my_cell(board, index, turn, dir)
      {:black, index} -> search_until_my_cell(board, index, turn, dir)
      {_, _} -> false
    end
  end

  def search_until_my_cell(board = %__MODULE__{}, index, turn, dir) do
    case get_neighber(board, index, dir) do
      {^turn, _} -> true
      {:NG, _} -> false
      {:white, index} -> search_until_my_cell(board, index, turn, dir)
      {:black, index} -> search_until_my_cell(board, index, turn, dir)
      {_, _} -> false
    end
  end

  def get_neighber(board = %__MODULE__{}, index, dir) do
    case neighber_index(board.xs, board.ys, index, dir) do
      {:OK, index} -> {elem(board.cells, index), index}
      {:NG, _} -> {:NG, nil}
    end
  end

  def neighber_index(xs, ys, index, dir) do
    ret = add(index_to_xy(index, xs), neighber_dxdy(xs, index, dir))
    cond do
      within_area?(ret, xs, ys) -> {:OK, xy_to_index(ret, xs)}
      true -> {:NG, nil}
    end
  end

  def neighber_dxdy(xs, index, dir) do
    case {y_is_even(index, xs), dir} do
      {_, 0} -> {1,0}
      {_, 3} -> {-1,0}
      {true, 1} -> {1,-1}
      {true, 2} -> {0,-1}
      {true, 4} -> {0,1}
      {true, 5} -> {1,1}
      {false, 1} -> {0,-1}
      {false, 2} -> {-1,-1}
      {false, 4} -> {-1,1}
      {false, 5} -> {0,1}
    end
  end

  def y_is_even(index, xs) do
    Integer.is_even(div(index, xs))
  end

  def turn_over(board = %__MODULE__{}, index, turn) do
    0..5
    |> Enum.filter(&can_turn_over?(board, index, turn, &1))
    |> Enum.reduce(board |> turn_over_cell(index, turn), fn(dir, board) -> turn_over(board, index, turn, dir) end)
  end

  def turn_over(board = %__MODULE__{}, index, turn, dir) do
    board = turn_over_cell(board, index, turn)
    case get_neighber(board, index, dir) do
      {^turn, _} -> board
      {:black, index} -> turn_over(board, index, turn, dir)
      {:white, index} -> turn_over(board, index, turn, dir)
    end
  end

  def turn_over_cell(board = %__MODULE__{}, index, turn) do
    %{board | cells: put_elem(board.cells, index, turn)}
  end

  def make_game_over(board = %__MODULE__{}) do
    Map.put(board, :gameover, true)
  end

  def add({x1,y1},{x2,y2}) do
    {x1+x2, y1+y2}
  end

  def within_area?({x,y}, xs, ys) do
    (x >= 0 and x < xs and y >= 0  and y < ys)
  end

  def index_to_xy(index,xs) do
    { rem(index, xs), div(index,xs) }
  end

  def xy_to_index({x,y}, xs) do
    x + y*xs
  end

  def update_score(board = %__MODULE__{}) do
    board.cells
    |> Tuple.to_list()
    |> Enum.frequencies()
    |> Enum.filter(fn({key, _}) -> key in [:black, :white] end)
    |> Enum.reduce(board, fn({turn, value}, board) -> set_score(board, turn, value) end)
  end

  def set_score(board = %__MODULE__{}, turn, value) do
    %{board| turn => value}
  end
end
