def mont(a, b, mod):
    # Kiểm tra nếu mod là số lẻ (Montgomery yêu cầu mod phải là số lẻ)
    if mod % 2 == 0:
        raise ValueError("Modulus must be odd for Montgomery multiplication.")

    # Tính R là lũy thừa của 2 lớn hơn mod
    R = 1 << (mod.bit_length())

    # Tính R^-1 và mod^-1 để sử dụng trong phép tính
    # Sử dụng thuật toán Euclid mở rộng để tính nghịch đảo modulo
    def extended_gcd(a, b):
        if b == 0:
            return a, 1, 0
        else:
            g, x, y = extended_gcd(b, a % b)
            return g, y, x - (a // b) * y

    # Tính R_inv và mod_inv
    g, R_inv, _ = extended_gcd(R, mod)
    if g != 1:
        raise ValueError("R and mod must be coprime for Montgomery multiplication.")
    R_inv = R_inv % mod  # Đảm bảo R_inv là số dương

    g, mod_inv, _ = extended_gcd(mod, R)
    mod_inv = -mod_inv % R  # Đảm bảo mod_inv là số dương

    # Chuyển đổi a và b sang dạng Montgomery
    a_mont = (a * R) % mod
    b_mont = (b * R) % mod

    # Thực hiện phép nhân Montgomery
    def montgomery_reduce(x):
        t = (x + (x * mod_inv % R) * mod) // R
        if t >= mod:
            t -= mod
        return t

    # Nhân a_mont và b_mont trong dạng Montgomery
    product_mont = montgomery_reduce(a_mont * b_mont)

    # Chuyển đổi kết quả về dạng bình thường
    result = montgomery_reduce(product_mont)

    # Trả về cả kết quả trong dạng Montgomery và dạng bình thường
    return product_mont, result

# Ví dụ sử dụng
a = 13
b = 17
mod = 41

product_mont, result = mont(a, b, mod)
print(f"Result in Montgomery form: {product_mont}")
print(f"Result in normal form: {result}")