extends Control


@export var flip:bool = false: set = _set_flip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _set_flip(value:bool) -> void:
	$TextureRect.flip_v = value
