extends Node2D


#
#func add_to_tree(node:Mission)-> void:
	#%TargetNode.add_child(node)
func _ready() -> void:
	Mission.add_to_tree = func(node): %TargetNode.add_child(node)
	Mission.add_link_to_tree = func(node): %LinkTargetNode.add_child(node)
	Mission.max_mult_bit = %MaxMultBitSpin.value
	get_viewport().files_dropped.connect(on_files_dropped)

#region PROCESS 代码区域
func _process(delta: float) -> void:
	
	_camera_move(delta)

var _root: Mission
var _in_order: int = 0

func _node_move(mission_node: Mission, depth := 0):
	const H_SPACE = 400.0  # 水平間距
	const V_SPACE = 800.0  # 垂直間距

	var childs = mission_node.get_sub_nodes()
	
	# 如果沒有子節點，則直接依計數器設定位置
	if childs.size() == 0:
		mission_node.position = Vector2(H_SPACE * _in_order, V_SPACE * depth)
		_in_order += 1
	else:
		# 先遞迴處理所有子節點
		for child in childs:
			_node_move(child, depth + 1)
		
		# 將父節點置中：
		# 取得子節點中最左邊的 x 座標和最右邊的 x 座標
		var leftmost_x = childs[0].position.x
		var rightmost_x = childs[childs.size() - 1].position.x
		
		# 父節點的 x 座標設定為這兩點的中點
		mission_node.position = Vector2((leftmost_x + rightmost_x) / 2.0, V_SPACE * depth)

	

var _camera_target_pos  = Vector2.ZERO
func _camera_move(delta: float) -> void:
	const CAMERA_MOVE_SPEED:float = 1500.0
	const CAMERA_LERP_SPEED:float = 8.0
	var speed_mult = 5.0 if Input.is_action_pressed("shift") else 1.0
	_camera_target_pos += \
		Input.get_vector("A", "D", "W", "S") * CAMERA_MOVE_SPEED * delta * speed_mult
	%Camera2D.offset = %Camera2D.offset.lerp(_camera_target_pos, CAMERA_LERP_SPEED * delta)
#endregion


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		%Camera2D.zoom *= 1.1
	elif event.is_action_pressed("zoom_out"):
		%Camera2D.zoom *= 0.9




func handle():
	_in_order = 0
	if _root:
		_root.handle()
		_node_move(_root)
	else:
		if %LineEditA.text.is_valid_int() and  %LineEditB.text.is_valid_int():
			_root = Mission.CreateNewMission( %LineEditA.text, %LineEditB.text )
			_node_move(_root)
		else:
			MessageManager.send_message("[color=red]input not valid")
	_on_camera_center_button_button_down()
	await get_tree().process_frame
	await get_tree().process_frame
	for i in %LinkTargetNode.get_children():
		i.move()
	
	MessageManager.send_message("[color=green]========= Process finish =========")
	MessageManager.send_message("Mission Node count: " + str(_in_order))
		


#


func _on_process_button_button_down() -> void:
	handle()


func _on_clear_button_button_down() -> void:
	#%LineEditA.text = ""
	#%LineEditB.text = ""
	for i in %TargetNode.get_children():
		i.queue_free()
	for i in %LinkTargetNode.get_children():
		i.queue_free()
	_root = null
	MessageManager.clear()


func _on_undo_button_button_down() -> void:
	pass # Replace with function body.


func _on_camera_center_button_button_down() -> void:
	_camera_target_pos.x = _root.position.x


func _on_max_mult_bit_spin_value_changed(value: float) -> void:
	Mission.max_mult_bit = value


func on_files_dropped(files):
	print(files)
	var arr = open_text_file(files[0])
	%LineEditA.text = arr[0]
	%LineEditB.text = arr[1]


func open_text_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("打开文件失败: ", FileAccess.get_open_error())
		return
	
	var content = file.get_as_text()
	file.close()
	print("文件内容: ", content)
	content = content.replace("\r", "")
	content = content.split("\n")
	print("文件内容: ", content)
	return content
