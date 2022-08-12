defmodule HexReversi.BoardTest do
  use ExUnit.Case
  # use HexReversiWeb.ConnCase
  alias HexReversi.Board

  test "create_initial_board" do
    board = Board.create_initial_board()
    assert board.xs == 8
    assert board.ys == 8
    assert tuple_size(board.cells) == 64
    assert elem(board.cells, 3+8*3) == :black
    assert elem(board.cells, 4+8*4) == :black
    assert elem(board.cells, 3+8*4) == :white
    assert elem(board.cells, 4+8*3) == :white
  end

  test "neighber_dxdy" do
    assert Board.neighber_dxdy(8, 0, 0) == {1,0}
    assert Board.neighber_dxdy(8, 0, 3) == {-1,0}
    assert Board.neighber_dxdy(8, 16, 1) == {1,-1}
    assert Board.neighber_dxdy(8, 16, 2) == {0,-1}
    assert Board.neighber_dxdy(8, 16, 4) == {0,1}
    assert Board.neighber_dxdy(8, 16, 5) == {1,1}

    assert Board.neighber_dxdy(8, 8, 0) == {1,0}
    assert Board.neighber_dxdy(8, 8, 3) == {-1,0}
    assert Board.neighber_dxdy(8, 8, 1) == {0,-1}
    assert Board.neighber_dxdy(8, 8, 2) == {-1,-1}
    assert Board.neighber_dxdy(8, 8, 4) == {-1,1}
    assert Board.neighber_dxdy(8, 8, 5) == {0,1}
  end

  test "neighber_index" do
    assert Board.neighber_index(8, 8, 0, 0) == {:OK,1}
    assert Board.neighber_index(8, 8, 0, 1) == {:NG, nil}
    assert Board.neighber_index(8, 8, 0, 2) == {:NG, nil}
    assert Board.neighber_index(8, 8, 0, 3) == {:NG, nil}
    assert Board.neighber_index(8, 8, 0, 4) == {:OK, 8}
    assert Board.neighber_index(8, 8, 0, 5) == {:OK, 9}
  end

  test "neighber_index2" do
    assert Board.neighber_index(8, 8, 0+7*8, 0) == {:OK, 1+7*8}
    assert Board.neighber_index(8, 8, 0+7*8, 1) == {:OK, 0+6*8}
    assert Board.neighber_index(8, 8, 0+7*8, 2) == {:NG, nil}
    assert Board.neighber_index(8, 8, 0+7*8, 3) == {:NG, nil}
    assert Board.neighber_index(8, 8, 0+7*8, 4) == {:NG, nil}
    assert Board.neighber_index(8, 8, 0+7*8, 5) == {:NG, nil}
  end

  test "neighber_index3" do
    assert Board.neighber_index(8, 8, 5+7*8, 0) == {:OK, 6+7*8}
    assert Board.neighber_index(8, 8, 5+7*8, 1) == {:OK, 5+6*8}
    assert Board.neighber_index(8, 8, 5+7*8, 2) == {:OK, 4+6*8}
    assert Board.neighber_index(8, 8, 5+7*8, 3) == {:OK, 4+7*8}
    assert Board.neighber_index(8, 8, 5+7*8, 4) == {:NG, nil}
    assert Board.neighber_index(8, 8, 5+7*8, 5) == {:NG, nil}
  end

  test "get_neighber" do
    board = Board.create_initial_board()
    assert Board.get_neighber(board, 0, 0) == {:none,1}
    assert Board.get_neighber(board, 0, 1) == {:NG, nil}
    assert Board.get_neighber(board, 0, 2) == {:NG, nil}
    assert Board.get_neighber(board, 0, 3) == {:NG, nil}
    assert Board.get_neighber(board, 0, 4) == {:none, 8}
    assert Board.get_neighber(board, 0, 5) == {:none, 9}
  end

  test "get_neighber3" do
    board = Board.create_initial_board()
    assert Board.get_neighber(board, 5+7*8, 0) == {:none, 6+7*8}
    assert Board.get_neighber(board, 5+7*8, 1) == {:none, 5+6*8}
    assert Board.get_neighber(board, 5+7*8, 2) == {:none, 4+6*8}
    assert Board.get_neighber(board, 5+7*8, 3) == {:none, 4+7*8}
    assert Board.get_neighber(board, 5+7*8, 4) == {:NG, nil}
    assert Board.get_neighber(board, 5+7*8, 5) == {:NG, nil}
  end

  test "search_until_my_cell 1" do
    board = %Board{
      cells: {0,:black,:black,:black,:white,0}
    }
    assert Board.search_until_my_cell(board, 0, :white, 0) == true
    assert Board.search_until_my_cell(board, 0, :white, 3) == false
  end

  test "search_until_my_cell 2" do
    board = %Board{
      cells: {0,:black,:black,:black,0,:white}
    }
    assert Board.search_until_my_cell(board, 0, :white, 0) == false
  end

  test "can_turn_over? 1" do
    board = %Board{
      cells: {0,:black,:black,:black,:white,0}
    }
    assert Board.can_turn_over?(board, 0, :black, 0) == false
    assert Board.can_turn_over?(board, 0, :white, 0) == true
    assert Board.can_turn_over?(board, 0, :white, 3) == false
  end

  test "can_turn_over? 2" do
    board = %Board{
      cells: {0,0,:black,:black,:black,:white,0}
    }
    assert Board.can_turn_over?(board, 0, :black, 0) == false
  end

  test "can_turn_over? 3" do
    board = Board.create_initial_board()
    assert Board.can_turn_over?(board, Board.xy_to_index({5,3}, 8), :black) == true
    assert Board.can_turn_over?(board, Board.xy_to_index({5,3}, 8), :white) == false
    assert Board.can_turn_over?(board, Board.xy_to_index({4,5}, 8), :black) == true
  end

  test "can_put? 1" do
    board = Board.create_initial_board()
    assert Board.can_put?(board, Board.xy_to_index({5,3}, 8), :black) == true
    assert Board.can_put?(board, Board.xy_to_index({5,3}, 8), :white) == false
    assert Board.can_put?(board, Board.xy_to_index({4,5}, 8), :black) == true
    assert Board.can_put?(board, Board.xy_to_index({3,3}, 8), :black) == false
    assert Board.can_put?(board, Board.xy_to_index({3,4}, 8), :black) == false
  end

  test "turn_over_cell 1" do
    board =
      Board.create_initial_board()
      |> Board.turn_over_cell(Board.xy_to_index({5,3}, 8), :black)
    assert elem(board.cells, 5+8*3) == :black
  end

  test "turn_over 1" do
    board =
      Board.create_initial_board()
      |> Board.turn_over(Board.xy_to_index({5,3}, 8), :black, 3)
    assert elem(board.cells, 5+8*3) == :black
    assert elem(board.cells, 4+8*3) == :black
    assert elem(board.cells, 3+8*3) == :black
  end

  test "turn_over 2" do
    board =
      Board.create_initial_board()
      |> Board.turn_over(Board.xy_to_index({5,3}, 8), :black)
    assert elem(board.cells, 5+8*3) == :black
    assert elem(board.cells, 4+8*3) == :black
    assert elem(board.cells, 3+8*3) == :black
  end

  test "put 1" do
    board =
      Board.create_initial_board()
      |> Board.put(Board.xy_to_index({5,3}, 8))
    assert elem(board.cells, 5+8*3) == :black
    assert elem(board.cells, 4+8*3) == :black
    assert elem(board.cells, 3+8*3) == :black
    assert board.black == 4
    assert board.white == 1
  end

    test "put 2" do
    board =
      Board.create_initial_board()
      |> Board.turn_over(Board.xy_to_index({5,3}, 8), :white)
      |> Board.put(Board.xy_to_index({5,3}, 8))
    assert elem(board.cells, 5+8*3) == :white
    assert elem(board.cells, 4+8*3) == :white
    assert elem(board.cells, 3+8*3) == :black
    assert elem(board.cells, 3+8*4) == :white
    assert elem(board.cells, 4+8*4) == :black
  end


  test "set_score1" do
    board = Board.create_initial_board()
    |> Board.set_score(:black, 10)
    assert board.black == 10
  end

  test "set_score2" do
    board = Board.create_initial_board()
    |> Board.set_score(:white, 11)
    assert board.white == 11
  end

  test "update_score" do
    board = Board.create_initial_board()
    |> Board.update_score()
    assert board.black == 2
    assert board.white == 2
  end

  test "can_put? any place" do
    ret = Board.create_initial_board()
    |> Board.can_put?(:black)
    assert ret == true
  end

  test "change_turn" do
    board = Board.create_initial_board()
    |> Board.change_turn()
    assert board.turn == :white
  end

  test "change_turn2" do
    board = Board.create_initial_board()
    |> Board.change_turn()
    |> Board.change_turn()
    assert board.turn == :black
  end

  test "change_turn3" do
    board = Board.create_initial_board()
    |> Board.turn_over(Board.xy_to_index({3,3}, 8), :white)
    |> Board.turn_over(Board.xy_to_index({4,4}, 8), :white)
    |> Board.turn_over(Board.xy_to_index({4,3}, 8), :white)
    |> Board.turn_over(Board.xy_to_index({3,4}, 8), :white)
    |> Board.turn_over(Board.xy_to_index({1,0}, 8), :white)
    |> Board.turn_over(Board.xy_to_index({2,0}, 8), :black)
    |> Board.turn_over(Board.xy_to_index({3,0}, 8), :black)
    |> Board.turn_over(Board.xy_to_index({4,0}, 8), :black)
    |> Board.turn_over(Board.xy_to_index({5,0}, 8), :black)
    |> Board.turn_over(Board.xy_to_index({6,0}, 8), :black)
    |> Board.turn_over(Board.xy_to_index({7,0}, 8), :black)
    |> Board.change_turn()
    assert board.turn == :black
    assert board.gameover == false
  end

end
