class_name LargeNumber extends RefCounted

var data:Array[int] = []
var sign: int = 1 # 支援負號



# === 由字串建構 ===
static func from_str(text: String) -> LargeNumber:
	var ln = LargeNumber.new()
	var s = text.strip_edges()
	if s.begins_with("-"):
		ln.sign = -1
		s = s.substr(1, s.length() - 1)
	elif s.begins_with("+"):
		s = s.substr(1, s.length() - 1)

	for i in range(s.length() - 1, -1, -1):
		var c = s[i]
		if not c.is_valid_int():
			continue
		ln.data.append(int(c))
	ln.normalize()
	return ln

# === 加法 ===
static func add(a: LargeNumber, b: LargeNumber) -> LargeNumber:
	var result = LargeNumber.new()
	var size = max(a.data.size(), b.data.size())
	for i in range(size):
		var x = a.data[i] if i < a.data.size() else 0
		var y = b.data[i] if i < b.data.size() else 0
		result.data.append(x + y)
	result.normalize()
	return result

# === 減法（只支援 a >= b，未支援負號）===
static func sub(a: LargeNumber, b: LargeNumber) -> LargeNumber:
	var result = LargeNumber.new()
	var borrow = 0
	for i in range(a.data.size()):
		var x = a.data[i]
		var y = b.data[i] if i < b.data.size() else 0
		var diff = x - y - borrow
		if diff < 0:
			diff += 10
			borrow = 1
		else:
			borrow = 0
		result.data.append(diff)
	result.normalize()
	return result

# === 位移（乘以 10^k） ===
static func shift(a: LargeNumber, k: int) -> LargeNumber:
	var res = a.clone()
	for i in range(k):
		res.data.insert(0, 0)
	return res

# === 一位乘法 ===
static func mult(a: LargeNumber, b: LargeNumber) -> LargeNumber:
	var result = LargeNumber.new()
	var arr:Array[int] = []

	# 初始化結果陣列長度（最大長度不會超過 a+b 長度）
	arr.resize(a.data.size() + b.data.size())
	for i in range(arr.size()):
		arr[i] = 0

	for i in range(a.data.size()):
		for j in range(b.data.size()):
			arr[i + j] += a.data[i] * b.data[j]

	# 處理進位
	for i in range(arr.size() - 1):
		if arr[i] >= 10:
			arr[i + 1] += arr[i] / 10
			arr[i] %= 10

	# 處理最後一位的進位（可能會再多一位）
	if arr[arr.size() - 1] >= 10:
		arr.append(arr[arr.size() - 1] / 10)
		arr[arr.size() - 2] %= 10

	result.data = arr
	result.sign = a.sign * b.sign
	result.normalize()
	return result


func slice(start: int, end: int) -> LargeNumber:
	var result = LargeNumber.new()
	result.sign = sign  # 保留符號（視需求可自訂）
	for i in range(start, end):
		if i >= 0 and i < data.size():
			result.data.append(data[i])
	result.normalize()
	return result

# === 複製 ===
func clone() -> LargeNumber:
	var n = LargeNumber.new()
	n.data = data.duplicate()
	n.sign = sign
	return n

# 清除前導0 & 進位
func normalize():
	var carry = 0
	for i in range(data.size()):
		data[i] += carry
		if data[i] >= 10:
			carry = data[i] / 10
			data[i] %= 10
		else:
			carry = 0
	while carry > 0:
		data.append(carry % 10)
		carry /= 10

	# 移除前導0
	while data.size() > 1 and data[-1] == 0:
		data.pop_back()

	# 若為0則歸正
	if data.size() == 1 and data[0] == 0:
		sign = 1

## 轉為字串
#func _to_string() -> String:
	#var result = ""
	#for i in range(data.size() - 1, -1, -1):
		#result += str(data[i])
	#return ("-" if sign < 0 else "") + result

## 轉為字串（從低位開始 + 千位逗號）
func _to_string() -> String:
	var digits := []
	for d in data:
		digits.append(str(d))
	
	var result := ""
	for i in range(digits.size()):
		result = digits[i] + result
		if (i + 1) % 3 == 0 and i + 1 < digits.size():
			result = "," + result
	
	return ("-" if sign < 0 else "") + result



#
