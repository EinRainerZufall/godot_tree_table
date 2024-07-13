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
var sam:Control

var original_table:Array[Array]
var sort_mode_ascending:bool = true

var no_sorting_texture:Texture2D = preload("res://addons/godot_tree_table/no_sorting.svg")
var ascending_sorting_texture:Texture2D = preload("res://addons/godot_tree_table/arrow_up.svg")
var descending_sorting_texture:Texture2D = preload("res://addons/godot_tree_table/arrow_down.svg")

const SorterArrow:GDScript = preload("res://addons/godot_tree_table/SorterArrow.gd")
var preload_sorterArrow:PackedScene = preload("res://addons/godot_tree_table/SorterArrow.tscn")

var sorterArrow:SorterArrow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass


func _init_tree() -> void:
	tree = $Background/ScrollContainer/Tree
	background = $Background
	
	tree.button_clicked.connect(on_header_button_clicked)
	
	tree.cell_selected.connect(get_cell_data)
	tree.cell_selected.connect(get_cell_pos_selected_cell)
	tree.item_selected.connect(get_row_data)
	tree.item_selected.connect(get_row_index)
	tree.item_activated.connect(get_cell_pos_double_click)


func set_header(header_row:Array[String]) -> void:
	tree.clear()
	tree.hide_root = true
	if header_row.size() < 1:
		tree.columns = 1
		return
	
	tree.columns = header_row.size()
	
	tree_root = tree.create_item()
	var item:TreeItem = tree.create_item(tree_root)
	for column:int in header_row.size():
		item.set_text(column, header_row[column])
		item.add_button(column, no_sorting_texture, 0)
		tree.set_column_expand(column, false)
		tree.set_column_clip_content(column, true)


func set_table(table:Array[Array], header_size:int) -> void:
	var child:TreeItem = tree.get_root().get_first_child()
	child = child.get_next()
	while child:
		var next_child:TreeItem = child.get_next()
		tree.get_root().remove_child(child)
		child = next_child
	
	for row:int in table.size():
		var item:TreeItem = tree.create_item(tree_root)
		for column:int in header_size:
			item.set_text(column, str(table[row][column]))
			item.set_autowrap_mode(column, TextServer.AUTOWRAP_OFF)
			item.set_text_overrun_behavior(column, TextServer.OVERRUN_TRIM_WORD_ELLIPSIS)


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


func set_header_color(color:Color) -> void:
	#TODO
	for i:int in tree.columns:
		tree.get_root().get_child(0).set_custom_bg_color(i, color)
		#tree.get_root().get_child(0).get_button(i, 0).


func set_header_width(column:int, width:int) -> void:
	if width == -1:
		width = tree.get_root().get_child(0).get_text(column).length() * 15 + 15
	
	tree.set_column_custom_minimum_width(column, width)


func set_header_font(font:Font) -> void:
	if font:
		for i:int in tree.columns:
			tree.get_root().get_child(0).set_custom_font(i, font)
		return
	for i:int in tree.columns:
		tree.get_root().get_child(0).set_custom_font(i, SystemFont.new())


func set_header_font_color(color:Color) -> void:
	if color:
		for i:int in tree.columns:
			tree.get_root().get_child(0).set_custom_color(i, color)
		return


func set_header_font_size(size:int) -> void:
	for i:int in tree.columns:
		tree.get_root().get_child(0).set_custom_font_size(i, size)


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
	if tree.get_root().get_children().find(tree.get_selected()) == 0:
		return
	
	CLICK_CELL_DATA.emit(tree.get_selected().get_text(tree.get_selected_column()))


func get_cell_pos_selected_cell() -> void:
	var result:Vector2i = Vector2i(-1, -1)
	result.x = tree.get_selected_column()
	result.y = tree.get_root().get_children().find(tree.get_selected())
	
	if result.y == 0:
		return
	
	CLICK_CELL_POS.emit(result)


func get_row_data() -> void:
	if tree.get_root().get_children().find(tree.get_selected()) == 0:
		return
	
	var result:Array
	var sel_item:TreeItem = tree.get_selected()
	for i:int in tree.columns:
		result.append(sel_item.get_text(i))
	
	CLICK_ROW.emit(result)


func get_row_index() -> void:
	var result:int = -1
	result = tree.get_root().get_children().find(tree.get_selected())
	
	if result == 0:
		return
	
	CLICK_ROW_INDEX.emit(result)


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


func on_header_button_clicked(item:TreeItem, column:int, id:int, mouse_button_index:int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT or mouse_button_index == MOUSE_BUTTON_RIGHT:
		if id == 0: # sorting button is always ID 0
			var sorted_table:Array[Array] = original_table.duplicate(true)
			var texture:Texture2D = no_sorting_texture
			match  mouse_button_index:
				MOUSE_BUTTON_LEFT:
					if sort_mode_ascending:
						sorted_table.sort_custom(custom_sorter_ascending.bind(column))
						texture = ascending_sorting_texture
					else:
						sorted_table.sort_custom(custom_sorter_descending.bind(column))
						texture = descending_sorting_texture
					sort_mode_ascending = !sort_mode_ascending
					set_table(sorted_table, tree.columns)
				MOUSE_BUTTON_RIGHT:
					sort_mode_ascending = true
					set_table(original_table, tree.columns)
			for i:int in tree.columns:
				item.set_button(i, id, no_sorting_texture)
			item.set_button(column, id, texture)


# -- custom sorter --
static func custom_sorter_ascending(a, b, column:int) -> bool:
	if a[column] == "----":
		return false
	if a[column] <= b[column]:
		return true
	return false

static func custom_sorter_descending(a, b, column:int) -> bool:
	if a[column] == "----":
		return false
	if a[column] >= b[column]:
		return true
	return false
