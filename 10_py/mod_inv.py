def mod_inv(x, mod):
    
    a, b, u, v = x, mod, 1, 0
    while b:
        q = a // b
        a, b = b, a % b
        u, v = v, u - q * v
    return u % mod if a == 1 else None  # Trả về None nếu không tồn tại nghịch đảo

def inverse_2_256_mod_n(n):
    """Tính (2^256)^-1 mod n"""
    return mod_inv(2**256, n)

# Số n được đặt sẵn
n = 89  # Bạn có thể thay đổi số này tùy ý
result = inverse_2_256_mod_n(n)

if result is None:
    print(f"(2^256)^-1 không tồn tại modulo {n}")
else:
    print(f"(2^256)^-1 mod {n} = {result}")
