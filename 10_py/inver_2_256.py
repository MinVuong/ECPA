# Hàm tính nghịch đảo modulo sử dụng thuật toán Euclid mở rộng
def mod_inverse(a, m):
    # Áp dụng thuật toán Euclid mở rộng để tìm nghịch đảo
    g, x, y = extended_gcd(a, m)
    if g != 1:
        raise Exception(f"{a} và {m} không coprime, không có nghịch đảo.")
    else:
        return x % m

# Hàm mở rộng Euclid để tìm ước chung lớn nhất và các hệ số x, y
def extended_gcd(a, b):
    if a == 0:
        return b, 0, 1
    g, x1, y1 = extended_gcd(b % a, a)
    x = y1 - (b // a) * x1
    y = x1
    return g, x, y

# Tính (2^256) mod 367
base = 2
exponent = 256
modulus = 89

# Tính giá trị của (2^256) mod 367
value = pow(base, exponent, modulus)

# Tính nghịch đảo modulo
inverse = mod_inverse(value, modulus)

print("KQ:", inverse)
