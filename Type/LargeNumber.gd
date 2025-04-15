class_name LargeNumber extends RefCounted

const BASE := 10

func multiply_karatsuba(a: Array, b: Array) -> Array:
	a = trim_leading_zeros(a)
	b = trim_leading_zeros(b)

	if a.size() == 0 or b.size() == 0:
		return [0]
	if a.size() == 1 and b.size() == 1:
		return normalize([a[0] * b[0]])

	var n = max(a.size(), b.size())
	if n % 2 != 0:
		n += 1

	a = resize_with_zero(a, n)
	b = resize_with_zero(b, n)

	var m = int(n / 2)

	var a0 = a.slice(0, m)
	var a1 = a.slice(m, n - m)
	var b0 = b.slice(0, m)
	var b1 = b.slice(m, n - m)

	var z0 = multiply_karatsuba(a0, b0)
	var z2 = multiply_karatsuba(a1, b1)
	var a0a1 = add_arrays(a0, a1)
	var b0b1 = add_arrays(b0, b1)
	var z1 = multiply_karatsuba(a0a1, b0b1)
	z1 = sub_arrays(z1, z0)
	z1 = sub_arrays(z1, z2)

	var result = add_arrays(
		add_arrays(
			shift_left(z2, 2 * m),
			shift_left(z1, m)
		),
		z0
	)

	return trim_leading_zeros(normalize(result))


func normalize(arr: Array) -> Array:
	var result = arr.duplicate()
	var carry = 0
	for i in range(result.size()):
		result[i] += carry
		carry = result[i] / BASE
		result[i] %= BASE
	while carry > 0:
		result.append(carry % BASE)
		carry /= BASE
	return result


func add_arrays(a: Array, b: Array) -> Array:
	var n = max(a.size(), b.size())
	var result := []
	for i in range(n):
		var ai = a[i] if i < a.size() else 0
		var bi = b[i] if i < b.size() else 0
		result.append(ai + bi)
	return result


func sub_arrays(a: Array, b: Array) -> Array:
	# 假設 a >= b
	var result := []
	var borrow = 0
	for i in range(a.size()):
		var ai = a[i]
		var bi = b[i] if i < b.size() else 0
		var diff = ai - bi - borrow
		if diff < 0:
			diff += BASE
			borrow = 1
		else:
			borrow = 0
		result.append(diff)
	return result


func shift_left(arr: Array, n: int) -> Array:
	var result := arr.duplicate()
	for i in range(n):
		result.insert(0, 0)
	return result


func trim_leading_zeros(arr: Array) -> Array:
	var res = arr.duplicate()
	while res.size() > 1 and res[-1] == 0:
		res.pop_back()
	return res


func resize_with_zero(arr: Array, n: int) -> Array:
	var res = arr.duplicate()
	while res.size() < n:
		res.append(0)
	return res


#
