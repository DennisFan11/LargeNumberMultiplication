#extends Node2D
#
#
#var _layer_arr:Array[Layer] = []
#
#
#@onready var target_node = %LayerContainers
#@onready var _layer_scene:PackedScene = preload("uid://coykf1220ytuv")
#func _new_layer()->Layer:
	#var node = _layer_scene.instantiate()
	#target_node.add_child(node)
	#_layer_arr.append(node)
	#await get_tree().process_frame
	#await get_tree().process_frame
	#%ScrollContainer.ensure_control_visible(node)
	#return node 
#
#
#
### divide
#func _on_divide_button_button_down() -> void:
	#var node = await _new_layer()
	#if _layer_arr.size() == 1: # init
		#MessageManager.send_message("init")
		#var arr:Array[Polynomial] = [Polynomial.from_str(%Line1.text, %Line2.text)]
		#node.data = arr
	#else:
		#var same_count = 0
		#for i:Polynomial in _layer_arr[-2].data:
			#var new_arr = i.KaratsubaDivide()
			#
			#if !new_arr: # NOTE Faild
				#same_count+=1
				#continue
				#
			#for j:Polynomial in new_arr:
				##print(i.KaratsubaDivide())
				#node.data.append(j)
		#if same_count == _layer_arr[-2].data.size() or\
			#_layer_arr[-2].data.size() == node.data.size():
			#
			#MessageManager.send_message("[color=red]無法繼續分割[/color]")
			#_on_undo_button_button_down()
				#
	#
	## regen text
	#node.text = ""
	#for i:Polynomial in node.data:
		#node.text += i._to_string() + "\n"
	#
	#
#
#
### conquer
#func _on_conquer_button_button_down() -> void:
	#if _layer_arr.size() <= 0:
		#MessageManager.send_message("[color=red]無法計算[/color]")
		#return
	#var node = await _new_layer()
	#for i in _layer_arr[-2].data:
		#var newPoly:Polynomial = i.KaratsubaConquer()
		#if newPoly: 
			#node.data.append(newPoly)
		#else:  # NOTE Faild
			#_on_undo_button_button_down()
			#return
	#
	## regen text
	#node.text = ""
	#for i:Polynomial in node.data:
		#node.text += i._to_string() + "\n"
#
### merge
#func _on_merge_button_button_down() -> void:
	#if _layer_arr.size() <= 0:
		#MessageManager.send_message("[color=red]無法合併[/color]")
		#return
	#for i:Polynomial in _layer_arr[-1].data:
		#if i.state != Polynomial.NUMBER:
			#MessageManager.send_message("[color=red]無法合併[/color]")
			#return 
	#
	#var temp:Polynomial = Polynomial.ZERO
	#var node = await _new_layer()
	#for i in _layer_arr[-2].data:
		#temp = \
			#Polynomial.KaratsubaMerge(i, temp)
		#var arr:Array[Polynomial] = [temp]
		#node.data = arr
	#
	## regen text
	#node.text = ""
	#for i:Polynomial in node.data:
		#node.text += i._to_string() + "\n"
	#
#
### undo
#func _on_undo_button_button_down() -> void:
	#if _layer_arr.size() != 0:
		#_layer_arr[-1].queue_free()
		#_layer_arr.resize(_layer_arr.size() - 1)
