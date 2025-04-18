@tool
extends Control

signal CLICK_CELL_DATA(cell:String)
signal CLICK_CELL_POS(pos:Vector2i)
signal CLICK_ROW(row:Array)
signal CLICK_ROW_INDEX(index:int)
signal DOUBLE_CLICK(pos:Vector2i, key:Key)


var tree:Tree
var tree_root:TreeItem
var background:Panel

var original_table:Array[Array]
var sort_mode_ascending:bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree.column_title_clicked.connect(on_column_title_clicked)
	
	tree.cell_selected.connect(get_cell_data)
	tree.cell_selected.connect(get_cell_pos_selected_cell)
	tree.item_selected.connect(get_row_data)
	tree.item_selected.connect(get_row_index)
	tree.item_activated.connect(get_cell_pos_double_click)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass


func _init_tree() -> void:
	tree = $Background/ScrollContainer/Tree
	background = $Background


func set_header(header_row:Array[String]) -> void:
	if header_row.size() < 1:
		tree.columns = 1
		tree.set_column_title(0, "")
		return
	
	tree.columns = header_row.size()
	
	for i:int in header_row.size():
		tree.set_column_title(i, header_row[i])
		tree.set_column_title_alignment(i, HORIZONTAL_ALIGNMENT_LEFT)


func set_table(table:Array[Array], header_size:int) -> void:
	tree.clear()
	tree_root = tree.create_item()
	tree.hide_root = true
	for row:int in table.size():
		var item:TreeItem = tree.create_item(tree_root)
		for column:int in header_size:
			item.set_text(column, str(table[row][column]))


func reload_table(table:Array[Array]) -> void:
	set_table(table, tree.columns)


func auto_reload(table:Array[Array]) -> void:
	if table != original_table:
		set_table(table, tree.columns)


func set_original_table(table:Array[Array]) -> void:
	original_table = table.duplicate(true)


func set_stylebox_background(stylebox:StyleBox) -> void:
	if stylebox:
		background.add_theme_stylebox_override("panel", stylebox)
		return
	background.remove_theme_stylebox_override("panel")


func set_header_stylebox_normal(stylebox:StyleBox) -> void:
	if stylebox:
		tree.add_theme_stylebox_override("title_button_normal", stylebox)
		return
	tree.remove_theme_stylebox_override("title_button_normal")


func set_header_stylebox_pressed(stylebox:StyleBox) -> void:
	if stylebox:
		tree.add_theme_stylebox_override("title_button_pressed", stylebox)
		return
	tree.remove_theme_stylebox_override("title_button_pressed")


func set_header_stylebox_hover(stylebox:StyleBox) -> void:
	if stylebox:
		tree.add_theme_stylebox_override("title_button_hover", stylebox)
		return
	tree.remove_theme_stylebox_override("title_button_hover")


func set_header_width(column:int, width:int) -> void:
	tree.set_column_custom_minimum_width(column, width)


func set_header_font(font:Font) -> void:
	if font:
		tree.add_theme_font_override("title_button_font", font)
		return
	tree.remove_theme_font_override("title_button_font")


func set_header_font_color(color:Color) -> void:
	if color:
		tree.add_theme_color_override("title_button_color", color)
		return
	tree.remove_theme_color_override("title_button_color")


func set_header_font_size(size:int) -> void:
	if size and size > 0:
		tree.add_theme_font_size_override("title_button_font_size", size)
		return
	tree.remove_theme_font_size_override("title_button_font_size")


func set_table_font(font:Font) -> void:
	if font:
		tree.add_theme_font_override("font", font)
		return
	tree.remove_theme_font_override("font")


func set_table_font_color(color:Color) -> void:
	if color:
		tree.add_theme_color_override("font_color", color)
		return
	tree.remove_theme_color_override("font_color")


func set_table_font_size(size:int) -> void:
	if size and size > 0:
		tree.add_theme_font_size_override("font_size", size)
		return
	tree.remove_theme_font_size_override("font_size")


func set_select_mode(mode:bool) -> void:
	if mode:
		tree.select_mode = Tree.SELECT_SINGLE
	else:
		tree.select_mode = Tree.SELECT_ROW


func set_allow_reselect(reselect:bool) -> void:
	tree.allow_reselect = reselect


# -- signal functions --
func get_cell_data() -> void:
	CLICK_CELL_DATA.emit(tree.get_selected().get_text(tree.get_selected_column()))


func get_cell_pos_selected_cell() -> void:
	var result:Vector2i = Vector2i(-1, -1)
	result.x = tree.get_selected_column()
	result.y = tree.get_root().get_children().find(tree.get_selected())
	
	CLICK_CELL_POS.emit(result)


func get_cell_pos_double_click() -> void:
	var result:Vector2i = Vector2i(-1, -1)
	var key:Key = KEY_NONE
	if Input.is_key_pressed(KEY_ENTER):
		key = KEY_ENTER
	if Input.is_key_pressed(KEY_SPACE):
		key = KEY_SPACE
	result.x = tree.get_selected_column()
	result.y = tree.get_root().get_children().find(tree.get_selected())
	
	DOUBLE_CLICK.emit(result, key)


func get_row_data() -> void:
	var result:Array
	var sel_item:TreeItem = tree.get_selected()
	for i:int in tree.columns:
		result.append(sel_item.get_text(i))
	
	CLICK_ROW.emit(result)


func get_row_index() -> void:
	var result:int = -1
	result = tree.get_root().get_children().find(tree.get_selected())
	
	CLICK_ROW_INDEX.emit(result)


func on_column_title_clicked(column:int, mouse_button_index:int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT or mouse_button_index == MOUSE_BUTTON_RIGHT:
		var sorted_table:Array[Array] = original_table.duplicate(true)
		match mouse_button_index:
			MOUSE_BUTTON_LEFT:
				if sort_mode_ascending:
					sorted_table.sort_custom(custom_sorter_ascending.bind(column))
				else:
					sorted_table.sort_custom(custom_sorter_descending.bind(column))
				sort_mode_ascending = !sort_mode_ascending
				set_table(sorted_table, tree.columns)
			MOUSE_BUTTON_RIGHT:
				sort_mode_ascending = true
				set_table(original_table, tree.columns)


# -- custom sorter --
static func custom_sorter_ascending(a, b, column:int) -> bool:
	# Handle placeholder values
	if str(a[column]) == "----":
		return false
	if str(b[column]) == "----":
		return true
	
	# If both values can be converted to floats, compare them as numbers
	if a[column] is String and b[column] is String:
		var a_float = a[column].to_float() if a[column].is_valid_float() else null
		var b_float = b[column].to_float() if b[column].is_valid_float() else null
		
		if a_float != null and b_float != null:
			return a_float <= b_float
	
	# For any other case (mixed types or non-numeric strings), convert to string and compare
	return str(a[column]) <= str(b[column])

static func custom_sorter_descending(a, b, column:int) -> bool:
	# Handle placeholder values
	if str(a[column]) == "----":
		return false
	if str(b[column]) == "----":
		return true
	
	# If both values can be converted to floats, compare them as numbers
	if a[column] is String and b[column] is String:
		var a_float = a[column].to_float() if a[column].is_valid_float() else null
		var b_float = b[column].to_float() if b[column].is_valid_float() else null
		
		if a_float != null and b_float != null:
			return a_float >= b_float
	
	# For any other case (mixed types or non-numeric strings), convert to string and compare
	return str(a[column]) >= str(b[column])
