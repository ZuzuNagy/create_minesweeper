require './app/table'

table = Table.new(3,3, [[1,2],[2,0]])
p table.mines_count_arround(2,2) == 1
p table.mines_count_arround(0,0) == 0
p table.mines_count_arround(1,1) == 2

p table.fields_arround(1,1).size == 8

p table.fields_arround(1,1) == [[0,0],[0,1],[0,2],[1,0],[1,2],[2,0],[2,1],[2,2]]
p table.fields_arround(0,0) == [[0,1],[1,0],[1,1]]
p table.fields_arround(2,2) == [[1,1],[1,2],[2,1]]

p table.create_grid == [[0,1,1],[1,2,'x'],['x',2,1]]

p Table.new(2,4,[[1,1]]).create_grid == [[1,1,1,0],[1,'x',1,0]]
