![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/EinRainerZufall/godot_tree_table/total)
# godot_tree_table
A simple table node with built-in sorter
 
To add:  `Control/Container/PanelContainer/Table`
### ![](https://github.com/EinRainerZufall/godot_tree_table/blob/main/addons/godot_tree_table/images/preview1.png)

## Sorter
The built-in sorter is activated by left-clicking on the corresponding header column and toggles between ascending and descending. Right-click to return to the original order. Empty cells are created as "----" and  are always at the end of the table when sorting.

## built-in functions
### set_table
```GDscript
func set_table(new_table:Array[Array]) -> void:
```
Sets the passed array as a table, the inner arrays are automatically adjusted to the number of columns, if they are expanded the text is set to "----". If `auto_reload` is active, the table is automatically  
updated when the passed array changes.

### add_row
```GDscript
func add_row(new_row:Array) -> void:
```
Adds a new row, the array is automatically adjusted to the number of columns, if they are expanded the text is set to "----".

### remove_last_row
```GDscript
func remove_last_row() -> bool:
```
Deletes the last row, does not return an error if the table is empty. If a row has been removed, `True` is returned, otherwise `False`

### remove_row_at
```GDscript
func remove_row_at(index:int) -> void:
```
Deletes the row at the specified `index` (0 based). A positive index is counted from the beginning, a negative index is counted from the end. Returns an error if the specified index does not exist.

### get_value_at
```GDscript
func get_value_at(pos:Vector2i) -> String:
```
Returns the text of the cell at the given position.

### reload_table
```GDscript
func reload_table() -> void:
```
Reloads the table. The manual way if the array that was set with `set_table` has changed.

## Signals
Available signals
```GDscript
signal CLICK_CELL_DATA(cell:String)
signal CLICK_CELL_POS(pos:Vector2i)
signal CLICK_ROW(row:Array)
signal CLICK_ROW_INDEX(index:int)
signal DOUBLE_CLICK(pos:Vector2i, key:Key)
```
The CELL signals are only available if the `table_select_mode` is set to `CELL`

