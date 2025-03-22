def extended_gcd(a, b):
    """ Hàm để tính toán gcd và các hệ số x, y sao cho ax + by = gcd(a, b) """
    if a == 0:
        return b, 0, 1
    gcd, x1, y1 = extended_gcd(b % a, a)
    x = y1 - (b // a) * x1
    y = x1
    return gcd, x, y

def modular_inverse(a, m):
    """ Tính toán nghịch đảo modulo của a mod m """
    gcd, x, _ = extended_gcd(a, m)
    if gcd != 1:
        raise ValueError("Inverse doesn't exist")  # Nghịch đảo không tồn tại
    else:
        return x % m  # Trả về nghịch đảo modulo

def modulo_multiplication(b, a, m):
    """ Tính toán c = b * a^{-1} mod m """
    a_inv = modular_inverse(a, m)
    c = (b * a_inv) % m
    return c

# Ví dụ
b = 0x1
a = 0xd5076ae274e874c2eb0f7778717c39460236549ddd9fc651e68a0c0e787b4ce8
m = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f

c = modulo_multiplication(b, a, m)
print(f"c = {c:064x}")  # In c dưới dạng hex với 64 ký tự