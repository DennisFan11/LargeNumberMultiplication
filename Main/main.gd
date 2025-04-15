extends Node2D


var _layer_arr:Array[Layer] = []


@onready var target_node = %LayerContainers
@onready var _layer_scene:PackedScene = preload("uid://coykf1220ytuv")
func _new_layer()->Layer:
	var node = _layer_scene.instantiate()
	target_node.add_child(node)
	_layer_arr.append(node)
	await get_tree().process_frame
	await get_tree().process_frame
	%ScrollContainer.ensure_control_visible(node)
	return node 

func _get_data():
	var a = %Line1.text
	var b = %Line2.text
	return a + " * " + b

## divide
func _on_divide_button_button_down() -> void:
	var node = await _new_layer()
	node.text = _get_data()

## conquer
func _on_conquer_button_button_down() -> void:
	_new_layer()

## undo
func _on_undo_button_button_down() -> void:
	if _layer_arr.size() != 0:
		_layer_arr[-1].queue_free()
		_layer_arr.resize(_layer_arr.size() - 1)
