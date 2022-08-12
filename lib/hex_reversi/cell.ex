defmodule HexReversi.Board.Cell do
  defstruct [
    :value,
    :open,
    :bomb,
    :flag
  ]
end
