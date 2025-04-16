class_name Mission extends Node2D
## [b]A[/b] = [b]W[/b] × [b]Y[/b]  [br]
## [b]B[/b] = [b]X[/b] × [b]Z[/b]  [br]
## [b]C[/b] = ([b]W[/b] + [b]X[/b]) × ([b]Y[/b] + [b]Z[/b])  [br][br]
## [b]U[/b] × [b]V[/b] = [b]A[/b] × 10^(2s) + ([b]C[/b] − [b]A[/b] − [b]B[/b]) × 10^s + [b]B[/b]



enum {
	IDLE, # 待分割
	WAITING,  # 已分割, 等待征服
	CONQUERED # 已征服
}
var state:int

var a:LargeNumber # IDLE
var b:LargeNumber # IDLE

var shift: int = 0 # WAITING 的偏移乘法（代表要補幾個零）
var sub_missionA:Mission: # WAITING
	set(new):
		sub_missionA = new
		var node = preload("uid://beaorchfk6iql").instantiate()
		add_link_to_tree.call(node)
		node.Missions = [%OutPosA, new.get_InPos()]
		
var sub_missionB:Mission: # WAITING
	set(new):
		sub_missionB = new
		var node = preload("uid://beaorchfk6iql").instantiate()
		add_link_to_tree.call(node)
		node.Missions = [%OutPosB, new.get_InPos()]

var sub_missionC:Mission: # WAITING
	set(new):
		sub_missionC = new
		var node = preload("uid://beaorchfk6iql").instantiate()
		add_link_to_tree.call(node)
		node.Missions = [%OutPosC, new.get_InPos()]


var answer:LargeNumber: # CONQUERED
	set(new):
		answer = new
		%AnswerPanel.visible = true
func get_InPos(): return %InPos

func update_formula():
	%Formula.text = "[color=yellow]Mission: [/color]"+_mult_to_string(a, b) + \
		"\n========================"
		

static var max_mult_bit:int = 1
func handle()-> bool:
	match state:
		IDLE:
			var n = max(a.data.size(), b.data.size()) # 判斷長度
			if n <= max_mult_bit: _KaratsubaConquer()
			else: _KaratsubaDivide()
			
		WAITING:
			if sub_missionA.state == CONQUERED and \
				sub_missionB.state == CONQUERED and \
				sub_missionC.state == CONQUERED:
				_KaratsubaMerge()
			else:
				sub_missionA.handle()
				sub_missionB.handle()
				sub_missionC.handle()
		CONQUERED:
			return true
	return false

func get_sub_nodes()->Array[Mission]:
	var arr:Array[Mission] = []
	if sub_missionA: arr.append(sub_missionA) 
	if sub_missionB: arr.append(sub_missionB) 
	if sub_missionC: arr.append(sub_missionC)
	return arr
	

static var add_to_tree:Callable
static var add_link_to_tree:Callable

## overloads [br](A: [LargeNumber] , B: [LargeNumber]) [br](A: [String] , B: [String])
static func CreateNewMission(numA, numB, Shift=0): # TODO
	var node:Mission = preload("uid://oju68vtkyqat").instantiate()
	if numA is String:
		node.a = LargeNumber.from_str(numA)
	elif numA is LargeNumber:
		node.a = numA
	
	if numB is String:
		node.b = LargeNumber.from_str(numB)
	elif numB is LargeNumber:
		node.b = numB
	
	if Shift != 0: node.shift = Shift
	node.state = IDLE
	
	add_to_tree.call(node)
	node.update_formula()
	return node

## 分割出子任務
func _KaratsubaDivide():
	# 判斷長度（以 a 為主）
	%SubAnswerContainer.visible = true
	var n = max(a.data.size(), b.data.size())
	var m = n / 2

	# 分割 a 成 a1, a0
	var a0 = a.slice(0, m)
	var a1 = a.slice(m, a.data.size())

	# 分割 b 成 b1, b0
	var b0 = b.slice(0, m)
	var b1 = b.slice(m, b.data.size())
	
	# 分割出正確子任務
	sub_missionA = CreateNewMission(a1, b1) # A = a1 × b1，最高位移
	sub_missionB = CreateNewMission(a0, b0)        # B = a0 × b0，無位移
	sub_missionC = CreateNewMission(               # C = (a0+a1)(b0+b1)
		LargeNumber.add(a0, a1),
		LargeNumber.add(b0, b1),
		
	)
	shift = m
	state = WAITING
	MessageManager.send_message(
		"[color=yellow]Divide [/color]" + _mult_to_string(a, b)
	)
	update_formula()
	%Formula.text += \
		"\n=> [b]A[/b] × 10^(2s) + ([b]C[/b] − [b]A[/b] − [b]B[/b]) × 10^s + [b]B[/b]\n" + \
		"[color=yellow]A[/color] = " + _mult_to_string(sub_missionA.a, sub_missionA.b) + "\n" +\
		"[color=yellow]B[/color] = " + _mult_to_string(sub_missionB.a, sub_missionB.b) + "\n" +\
		"[color=yellow]C[/color] = " + _mult_to_string(sub_missionC.a, sub_missionC.b) + "\n"
	ParticleText.spawn("[font_size=150][color=yellow]Divide ![/color]", self)

## 基底情況：進行單位乘法
func _KaratsubaConquer():
	answer = LargeNumber.mult(a, b)
	answer.normalize()
	state = CONQUERED
	%Answer.text = "[color=yellow]Answer: [/color]" + answer._to_string()
	MessageManager.send_message(
		"[color=yellow]Conquer: [/color]" + _mult_to_string(a, b) + " = "+ answer.to_string()
	)
	ParticleText.spawn("[font_size=150][color=yellow]Conquer ![/color]", self)

## 合併 add and shift 
func _KaratsubaMerge():
	var _a = sub_missionA.answer
	var _b = sub_missionB.answer
	var _c = sub_missionC.answer
	var partA = LargeNumber.shift(_a, shift*2)
	var partB = _b
	var partMid = LargeNumber.shift(
		LargeNumber.sub(LargeNumber.sub(_c, _a), _b),
		shift
	)

	answer = LargeNumber.add(partA, partMid)
	answer = LargeNumber.add(answer, partB)

	answer.normalize()
	state = CONQUERED
	%SubA.text = "[color=yellow]A[/color] = " + _a._to_string()
	%SubB.text = "[color=yellow]B[/color] = " + _b._to_string()
	%SubC.text = "[color=yellow]C[/color] = " + _c._to_string()
	%Answer.text = "[color=yellow]Answer: [/color]" + answer._to_string()
	MessageManager.send_message("[color=yellow]Merge: [/color]" + answer.to_string())
	ParticleText.spawn("[font_size=150][color=yellow]Merge ![/color]", self)
	

func _mult_to_string(A:LargeNumber, B:LargeNumber)-> String:
	return "( " + A._to_string()+ ") [color=red]x[/color] (" + B._to_string() + " )"

## Debug 用：顯示
#func _to_string() -> String:
	#var shift_str = " << " + str(shift) if (shift > 0) else ""
	#data._to_string() + shift_str
