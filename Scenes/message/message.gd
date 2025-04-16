extends Node
func send_message(text:String):
	var node:RichTextLabel = preload("uid://lmk6ax60x828").instantiate()
	node.text = text
	%VBoxContainer.add_child(node)
	await get_tree().process_frame
	await get_tree().process_frame
	%ScrollContainer.ensure_control_visible(node)
