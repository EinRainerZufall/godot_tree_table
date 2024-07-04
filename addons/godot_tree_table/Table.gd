@tool
extends PanelContainer

enum select_mode {CELL, ROW}

signal CLICK_CELL_DATE(cell:String)
signal CLICK_CELL_POS(pos:Vector2i)
signal CLICK_ROW(row:Array)
signal CLICK_ROW_INDEX(index:int)

# user settings
@export var header_row:Array[String]: set = _set_header_row
## The custom minimum width of the header columns, at 0 the width is automatically adjusted to the text length
@export var header_width:Array[int]: set = _set_header_width
@export var table:Array[Array]: set = set_table
@export var table_select_mode:select_mode = select_mode.ROW: set = _set_table_select_mode
@export var table_allow_reselect:bool = false: set = _set_table_allow_reselect
## If active, the _ready function checks whether 'table' has changed, if yes, the table is reloaded
@export var auto_reload:bool = false
@export_group("Header")
@export var header_stylebox_normal:StyleBox: set = _set_header_stylebox_normal
@export var header_stylebox_pressed:StyleBox: set = _set_header_stylebox_pressed
@export var header_stylebox_hover:StyleBox: set = _set_header_stylebox_hover
@export_group("Table")
@export var background_stylebox:StyleBox: set = _set_stylebox_background
@export_group("Font")
@export var header_font:Font: set = _set_header_font
@export var header_font_color:Color: set = _set_header_font_color
## Sets the font size of the table header, if 0 then the default size is used
@export_range(0, 1, 1, "or_greater") var header_font_size:int: set = _set_header_font_size
@export var table_font:Font: set = _set_table_font
@export var table_font_color:Color: set = _set_table_font_color
## Sets the font size of the table, if 0 then the default size is used
@export_range(0, 1, 1, "or_greater") var table_font_size:int: set = _set_table_font_size



const TableContainer = preload("res://addons/godot_tree_table/TableContainer.gd")
var preload_tableContainer:PackedScene = preload("res://addons/godot_tree_table/TableContainer.tscn")

var tableContainer:TableContainer


func _init() -> void:
	_init_tree()


func _init_tree() -> void:
	tableContainer = preload_tableContainer.instantiate()
	self.add_child(tableContainer, true)
	
	tableContainer._init_tree()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tableContainer.CLICK_CELL_DATE.connect(_on_click_cell_data)
	tableContainer.CLICK_CELL_POS.connect(_on_click_cell_pos)
	tableContainer.CLICK_ROW.connect(_on_click_row)
	tableContainer.CLICK_ROW_INDEX.connect(_on_click_row_index)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	if auto_reload:
		tableContainer.auto_reload(table)


## Sets the entire table to the passed array, shortens or expands the inner arrays if necessary
func set_table(new_table:Array[Array]) -> void:
	for row:Array in new_table:
		var row_columns:int = row.size()
		var header_columns:int = header_row.size()
		if row_columns > header_columns:
			row.resize(header_columns)
		elif row_columns < header_columns:
			row.resize(header_columns)
			for i:int in row.size():
				if typeof(row[i]) == TYPE_NIL:
					row[i] = "----"
	table = new_table
	
	tableContainer.set_original_table(table)
	tableContainer.set_table(table, header_row.size())

## Adds the passed array to the table, shortens or extends it if necessary 
func add_row(new_row:Array) -> void:
	table.append(new_row)
	set_table(table)

## Deletes the last row of the table, true if it deleted something, otherwise false, returns no errors
func remove_last_row() -> bool:
	if table.size() == 0:
		return false
	table.remove_at(table.size() - 1)
	set_table(table)
	return true

## Deletes the row on the passed index, counted from the end if the index is negative
func remove_row_at(index:int) -> void:
	if index >= table.size():
		push_error("Error: Index pos = %d is out of bounds (size() = %d)." % [index, table.size()])
		return
	if index < 0:
		table.remove_at(table.size() + index)
	else:
		table.remove_at(index)
	set_table(table)

## Reloads the table
func reload_table() -> void:
	tableContainer.reload_table(table)


# -- Inernal funtions --
func _set_header_row(value:Array[String]) -> void:
	header_row = value
	tableContainer.set_header(header_row)
	
	header_width.resize(header_row.size())


func _set_stylebox_background(value:StyleBox) -> void:
	background_stylebox = value
	tableContainer.set_stylebox_background(background_stylebox)


func _set_header_stylebox_normal(value:StyleBox) -> void:
	header_stylebox_normal = value
	tableContainer.set_header_stylebox_normal(header_stylebox_normal)


func _set_header_stylebox_pressed(value:StyleBox) -> void:
	header_stylebox_pressed = value
	tableContainer.set_header_stylebox_pressed(header_stylebox_pressed)


func _set_header_stylebox_hover(value:StyleBox) -> void:
	header_stylebox_hover = value
	tableContainer.set_header_stylebox_hover(header_stylebox_hover)


func _set_header_width(value:Array[int]) -> void:
	header_width = value
	
	for i:int in header_width.size():
		tableContainer.set_header_width(i, header_width[i])


func _set_header_font(value:Font) -> void:
	header_font = value
	tableContainer.set_header_font(header_font)


func _set_header_font_color(value:Color) -> void:
	header_font_color = value
	tableContainer.set_header_font_color(header_font_color)


func _set_header_font_size(value:int) -> void:
	header_font_size = value
	tableContainer.set_header_font_size(header_font_size)


func _set_table_font(value:Font) -> void:
	table_font = value
	tableContainer.set_table_font(table_font)


func _set_table_font_color(value:Color) -> void:
	table_font_color = value
	tableContainer.set_table_font_color(table_font_color)


func _set_table_font_size(value:int) -> void:
	table_font_size = value
	tableContainer.set_table_font_size(table_font_size)


func _set_table_select_mode(value:select_mode) -> void:
	table_select_mode = value
	
	match table_select_mode:
		select_mode.CELL:
			tableContainer.set_select_mode(true)
		select_mode.ROW:
			tableContainer.set_select_mode(false)


func _set_table_allow_reselect(value:bool) -> void:
	table_allow_reselect = value
	tableContainer.set_allow_reselect(table_allow_reselect)


# -- signal functions --
func _on_click_cell_data(result:String) -> void:
	CLICK_CELL_DATE.emit(result)

func _on_click_row(result:Array) -> void:
	CLICK_ROW.emit(result)

func _on_click_cell_pos(result:Vector2i) -> void:
	CLICK_CELL_POS.emit(result)

func _on_click_row_index(result:int) -> void:
	CLICK_ROW_INDEX.emit(result)
