extends Control

var a:Array[Array]

# Called when the node enters the scene tree for the first time.
func _ready():
	if $Table.auto_reload:
		a.append(["This", "data", "loaded", "on"])
		a.append(["the", "_ready", "func"])
		$Table.table = a
	else:
		$auto_reload_test_btn.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$index_input.max_value = $Table.table.size() - 1


func _on_add_btn_pressed():
	var array_long:Array = ["This", "Array", "is", "to", "long"]
	var array_short:Array = ["And this", "is to", "short"]
	$Table.add_row(array_long)
	$Table.add_row(array_short)
	


func _on_remove_last_btn_pressed():
	if $Table.remove_last_row():
		print("Last row was removed")
	else:
		print("Last row was not removed")


func _on_remove_row_at_btn_pressed():
	$Table.remove_row_at($index_input.value)


func _on_table_click_cell_data(cell:String):
	print("This is the Text of the selected cell: ", cell)


func _on_table_click_row(row:Array):
	print("This is the selected row: ", row)


func _on_table_click_cell_pos(pos:Vector2i):
	print("This is the Vector2i of the selected cell: ", pos)


func _on_table_click_row_index(index:int):
	print("This is the selected row index: ", index)


func _on_auto_reload_test_btn_pressed() -> void:
	a.append(["Spawn", "a", "new", "line"])


func _on_table_double_click(pos: Vector2i, key:Key) -> void:
	print("This is the Vector2i of the double clicked cell: ", pos)
	print("And the cell value ist: ", $Table.table[pos.y][pos.x])
	print("The pressed key was: ", key)
