a = 0x7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffafb
b = 0x7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff79b
prime = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed

result = (a * b) % prime
print(hex(result))