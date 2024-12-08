@tool
extends Control

signal CLICK_CELL_DATA(cell:String)
signal CLICK_CELL_POS(pos:Vector2i)
signal CLICK_ROW(row:Array)
signal CLICK_ROW_INDEX(index:int)
signal DOUBLE_CLICK(pos:Vector2i, key:Key, is_header:bool)


var table:Tree
var header:Tree

var background:Panel

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
	table = $Background/ScrollContainer/VBoxContainer/Table
	header = $Background/ScrollContainer/VBoxContainer/Header
	background = $Background
	
	table.button_clicked.connect(on_header_button_clicked)
	
	table.cell_selected.connect(get_cell_data)
	table.cell_selected.connect(get_cell_pos_selected_cell)
	table.item_selected.connect(get_row_data)
	table.item_selected.connect(get_row_index)
	table.item_activated.connect(get_cell_pos_double_click)


func set_header(header_row:Array[String]) -> void:
	header.clear()
	header.hide_root = true
	if header_row.size() < 1:
		header.columns = 1
		return
	
	header.columns = header_row.size()
	
	var header_root:TreeItem = header.create_item()
	var item:TreeItem = header.create_item(header_root)
	for column:int in header_row.size():
		item.set_text(column, header_row[column])
		item.add_button(column, no_sorting_texture, 0)
		header.set_column_expand(column, false)
		header.set_column_clip_content(column, true)


func set_table(table_array:Array[Array], header_size:int) -> void:
	table.clear()
	table.hide_root = true
	
	table.columns = header.columns
	
	var table_root:TreeItem = table.create_item()
	
	for row:int in table_array.size():
		var item:TreeItem = table.create_item(table_root)
		for column:int in header_size:
			item.set_text(column, str(table_array[row][column]))
			item.set_autowrap_mode(column, TextServer.AUTOWRAP_OFF)
			item.set_text_overrun_behavior(column, TextServer.OVERRUN_TRIM_WORD_ELLIPSIS)
			table.set_column_expand(column, false)
			table.set_column_clip_content(column, true)
	
	for column:int in table.columns:
		table.set_column_custom_minimum_width(column, header.get_column_width(column))


func reload_table(table_array:Array[Array]) -> void:
	set_table(table_array, table.columns)


func auto_reload(table_array:Array[Array]) -> void:
	if table_array != original_table:
		set_table(table_array, table.columns)


func set_original_table(table:Array[Array]) -> void:
	original_table = table.duplicate(true)


func set_stylebox_background(stylebox:StyleBox) -> void:
	if stylebox:
		background.add_theme_stylebox_override("panel", stylebox)
		return
	background.remove_theme_stylebox_override("panel")


func set_header_color(color:Color) -> void:
	#TODO
	#haderBackground.color = color
	#if color:
		##var stylebox:StyleBoxFlat = header.get_theme_stylebox("panel")
		##stylebox.bg_color = color
		##header.add_theme_stylebox_override("panel", stylebox)
		#header.get_theme_stylebox("panel").bg_color = color
	#else:
		#header.remove_theme_stylebox_override("panel")
	var stylebox:StyleBoxFlat = header.get_theme_stylebox("panel")
	stylebox.bg_color = color
	header.add_theme_stylebox_override("panel", stylebox)


func set_header_width(column:int, width:int) -> void:
	if width == -1:
		width = header.get_root().get_child(0).get_text(column).length() * 15 + 15 #HACK
	
	header.set_column_custom_minimum_width(column, width)


func set_headerbackground() -> void:
	##TODO set colorRect to the correct size and position
	#haderBackground.set_global_position(table.global_position)
	#
	#for child in table.get_children(true):
		#if child is HScrollBar:
			##haderBackground.size.x = child.size.x
			#print(child.size)
	#haderBackground.size.x = 500
	#haderBackground.size.y = 50
	##print(background.get_global_rect())
	pass


func set_header_font(font:Font) -> void:
	if font:
		for i:int in table.columns:
			table.get_root().get_child(0).set_custom_font(i, font)
		return
	for i:int in table.columns:
		table.get_root().get_child(0).set_custom_font(i, SystemFont.new())


func set_header_font_color(color:Color) -> void:
	if color:
		for i:int in table.columns:
			table.get_root().get_child(0).set_custom_color(i, color)
		return


func set_header_font_size(size:int) -> void:
	for i:int in table.columns:
		table.get_root().get_child(0).set_custom_font_size(i, size)


func set_table_font(font:Font) -> void:
	if font:
		table.add_theme_font_override("font", font)
		return
	table.remove_theme_font_override("font")


func set_table_font_color(color:Color) -> void:
	if color:
		table.add_theme_color_override("font_color", color)
		return
	table.remove_theme_color_override("font_color")


func set_table_font_size(size:int) -> void:
	if size and size > 0:
		table.add_theme_font_size_override("font_size", size)
		return
	table.remove_theme_font_size_override("font_size")


func set_select_mode(mode:bool) -> void:
	if mode:
		table.select_mode = Tree.SELECT_SINGLE
	else:
		table.select_mode = Tree.SELECT_ROW


func set_allow_reselect(reselect:bool) -> void:
	table.allow_reselect = reselect


# -- internal signal functions --
func _on_tree_item_rect_changed() -> void:
	#haderBackground.set_global_position(table.global_position)
	#var header_width:int = 0
	#for i:int in table.columns:
		#header_width += table.get_column_width(i)
	#
	#if header_width < $Background/ScrollContainerTable.size.x:
		#haderBackground.size.x = header_width#tree.size.x #TODO da fehlt ein stück
	#else:
		#haderBackground.size.x = $Background/ScrollContainerTable.size.x
	#
	#haderBackground.size.y = 50 #TODO
	pass


# -- signal functions --
func get_cell_data() -> void:
	if table.get_root().get_children().find(table.get_selected()) == 0:
		return
	
	CLICK_CELL_DATA.emit(table.get_selected().get_text(table.get_selected_column()))


func get_cell_pos_selected_cell() -> void:
	var result:Vector2i = Vector2i(-1, -1)
	result.x = table.get_selected_column()
	result.y = table.get_root().get_children().find(table.get_selected())
	
	if result.y == 0:
		return
	
	CLICK_CELL_POS.emit(result)


func get_row_data() -> void:
	if table.get_root().get_children().find(table.get_selected()) == 0:
		return
	
	var result:Array
	var sel_item:TreeItem = table.get_selected()
	for i:int in table.columns:
		result.append(sel_item.get_text(i))
	
	CLICK_ROW.emit(result)


func get_row_index() -> void:
	var result:int = -1
	result = table.get_root().get_children().find(table.get_selected())
	
	if result == 0:
		return
	
	CLICK_ROW_INDEX.emit(result)


func get_cell_pos_double_click() -> void:
	var result:Vector2i = Vector2i.ZERO
	var key:Key = KEY_NONE
	var is_header:bool = false
	if Input.is_key_pressed(KEY_ENTER):
		key = KEY_ENTER
	if Input.is_key_pressed(KEY_SPACE):
		key = KEY_SPACE
	result.x = table.get_selected_column()
	result.y = table.get_root().get_children().find(table.get_selected()) - 1
	if result.y == -1:
		is_header = true
	
	DOUBLE_CLICK.emit(result, key, is_header)


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
					set_table(sorted_table, table.columns)
				MOUSE_BUTTON_RIGHT:
					sort_mode_ascending = true
					set_table(original_table, table.columns)
			for i:int in table.columns:
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
