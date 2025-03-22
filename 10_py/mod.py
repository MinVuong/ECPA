# Chương trình tính 2^256 mod 419
def mod(base, exponent, modulus):
    return pow(base, exponent, modulus)

# Đặt giá trị base = 2, exponent = 256, và modulus = 419
base = 2
exponent = 256
modulus = 419

# Tính kết quả
result = mod(base, exponent, modulus)

# In kết quả
print(f"Result la: {result}")