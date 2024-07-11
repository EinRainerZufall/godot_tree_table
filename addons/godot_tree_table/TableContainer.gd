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


const SorterArrow:GDScript = preload("res://addons/godot_tree_table/SorterArrow.gd")
var preload_sorterArrow:PackedScene = preload("res://addons/godot_tree_table/SorterArrow.tscn")
var arrow_texture:Texture2D = preload("res://addons/godot_tree_table/arrow.svg")

var sorterArrow:SorterArrow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree.column_title_clicked.connect(on_column_title_clicked)
	
	tree.cell_selected.connect(get_cell_data)
	tree.cell_selected.connect(get_cell_pos_selected_cell)
	tree.item_selected.connect(get_row_data)
	tree.item_selected.connect(get_row_index)
	tree.item_activated.connect(get_cell_pos_double_click)
	
	#set_sorter_arrow_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass


func _init_tree() -> void:
	tree = $Background/ScrollContainer/Tree
	background = $Background


func set_header_old(header_row:Array[String]) -> void:
	if header_row.size() < 1:
		tree.columns = 1
		tree.set_column_title(0, "")
		return
	
	tree.columns = header_row.size()
	
	for i:int in header_row.size():
		tree.set_column_title(i, header_row[i])
		tree.set_column_title_alignment(i, HORIZONTAL_ALIGNMENT_LEFT)


func set_header(header_row:Array[String]) -> void:
	tree.clear()
	tree.hide_root = true
	if header_row.size() < 1:
		tree.columns = 1
		return
	
	tree.columns = header_row.size()
	
	tree_root = tree.create_item()
	var item:TreeItem = tree.create_item(tree_root)
	for i:int in header_row.size():
		item.set_text(i, header_row[i])
		item.add_button(i, arrow_texture, 0)


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
			#item.set_autowrap_mode(column, TextServer.AUTOWRAP_WORD)
			item.set_text_overrun_behavior(column, TextServer.OVERRUN_TRIM_WORD)


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


func set_header_color_normal(color:Color) -> void:
	#TODO
	var img:Image = arrow_texture.get_image()
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a == 0: # Wenn Pixel transparent
				img.set_pixel(x, y, color)
	
	var new_arrow_texture:Texture2D = ImageTexture.create_from_image(img)

	for i:int in tree.columns:
		tree.get_root().get_child(0).set_custom_bg_color(i, color)
		#print(tree.get_root().get_child(0).get_button(i, 0))
		tree.get_root().get_child(0).set_button(i, 0, new_arrow_texture)


func set_header_stylebox_pressed(stylebox:StyleBox) -> void:
	#TODO
	if stylebox:
		tree.add_theme_stylebox_override("title_button_pressed", stylebox)
		return
	tree.remove_theme_stylebox_override("title_button_pressed")


func set_header_stylebox_hover(stylebox:StyleBox) -> void:
	#TODO
	if stylebox:
		tree.add_theme_stylebox_override("title_button_hover", stylebox)
		return
	tree.remove_theme_stylebox_override("title_button_hover")


func set_header_width(column:int, width:int) -> void:
	#TODO
	tree.set_column_custom_minimum_width(column, width)


func set_sorter_arrow_position() -> void:
	var total_position:int = 0
	for i:int in tree.columns:
		print("inc. pos: ", tree.get_column_width(i))
		sorterArrow = preload_sorterArrow.instantiate()
		sam.add_child(sorterArrow)
		total_position += tree.get_column_width(i)
		print("total position: ", total_position)
		sam.get_child(i).position.x = total_position
		sam.get_child(i).position.y = tree.get_theme_font_size("title_button_font_size") + 4 #FIXME Magic number


func set_header_font(font:Font) -> void:
	#TODO
	if font:
		tree.add_theme_font_override("title_button_font", font)
		return
	tree.remove_theme_font_override("title_button_font")


func set_header_font_color(color:Color) -> void:
	#TODO
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


func on_column_title_clicked(column:int, mouse_button_index:int) -> void:
	#TODO
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
