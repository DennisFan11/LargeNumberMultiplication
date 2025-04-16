class_name ParticleText extends Node2D
var _pos_ref:Node2D
static func spawn(text:String, pos_ref:Node2D):
	
	var node = preload("uid://b01u5igx0jcuq").instantiate()
	node.text = text
	node._pos_ref = pos_ref
	
	Mission.add_to_tree.call(node)
	var tween := node.get_tree().create_tween()
	node.scale = Vector2.ZERO
	node.rotation = PI/4.0
	tween.tween_property(node, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node, "rotation", 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_interval(0.5)
	tween.tween_property(node, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(node.queue_free)
	
	
func _process(delta: float) -> void:
	position = _pos_ref.position
	



var text:
	set(new): %RichTextLabel.text = new
