def extended_euclidean(a, b):
    """Hàm để thực hiện thuật toán Euclid mở rộng."""
    u, v = a, b
    x1, x2 = 1, 0

    while u != 1:
        q = v // u
        v, u = u, v - q * u
        x1, x2 = x2, x1 - q * x2

    return x1 % b

def modular_inverse(a, p):
    """Hàm để tính phần tử nghịch đảo của a modulo p."""
    if a < 1 or a >= p:
        raise ValueError("a phai nam trong khoan[1, p-1].")
    return extended_euclidean(a, p)

# Ví dụ kiểm tra
p = 8  # Số nguyên tố
a = 7 # Số cần tìm phần tử nghịch đảo

inverse = modular_inverse(a, p)
print("phan tu nghich dao {} modulo {} la: {}".format(a, p, inverse))

# Kiểm tra lại: a * inverse % p == 1
check = (a * inverse) % p
print("kiem tra: {} * {} mod {} = {} (nen bang 1)".format(a, inverse, p, check))