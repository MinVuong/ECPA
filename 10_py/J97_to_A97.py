def mod_inverse(a, p):
    """Tính nghịch đảo modulo của a modulo p dùng thuật toán Euclid mở rộng."""
    if a == 0:
        raise ValueError("Không có nghịch đảo modulo vì a = 0")
    
    # Lưu p gốc để trả về kết quả đúng
    p_orig = p
    # Đảm bảo a dương và nhỏ hơn p
    a = a % p
    
    # Khởi tạo các biến cho thuật toán Euclid mở rộng
    x, y = 0, 1
    last_x, last_y = 1, 0
    
    while p != 0:
        quotient = a // p
        a, p = p, a % p
        last_x, x = x, last_x - quotient * x
        last_y, y = y, last_y - quotient * y
    
    # Nếu gcd(a, p_orig) != 1, không có nghịch đảo
    if a != 1:
        raise ValueError("Không tồn tại nghịch đảo modulo")
    
    # Đảm bảo last_x dương
    return last_x % p_orig

def jacobian_to_affine(X, Y, Z, p):
    """
    Chuyển đổi điểm từ tọa độ Jacobian (X, Y, Z) sang tọa độ Affine (x, y).
    Input:
        X, Y, Z: Tọa độ Jacobian (số nguyên).
        p: Modulo của trường hữu hạn (prime field).
    Output:
        Tuple (x, y) trong tọa độ Affine, hoặc None nếu là điểm tại vô cực.
    """
    if Z == 0:
        return None  # Điểm tại vô cực
    
    try:
        # Tính Z^(-1) mod p
        Z_inv = mod_inverse(Z, p)
        
        # Tính Z_inv^2 và Z_inv^3
        Z_inv2 = (Z_inv * Z_inv) % p
        Z_inv3 = (Z_inv2 * Z_inv) % p
        
        # Tính x = X * Z_inv^2 mod p
        x = (X * Z_inv2) % p
        
        # Tính y = Y * Z_inv^3 mod p
        y = (Y * Z_inv3) % p
        
        return (x, y)
    
    except ValueError as e:
        raise ValueError(f"Lỗi khi tính nghịch đảo modulo: {e}")

# Tham số của đường cong secp256k1
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F  # Modulo của trường

# Ví dụ sử dụng
if __name__ == "__main__":
    # Điểm Jacobian ví dụ (X, Y, Z)
    # Đây chỉ là giá trị minh họa, bạn có thể thay bằng giá trị thực tế
    X = 0x9bae2d5bac61e6ea5de635bca754b2564b7d78c45277cad67e45c4cbbea6e706
    Y = 0x34fb8147eed1c0fbe29ead4d6c472eb4ef7b2191fde09e494b2a9845fe3f605e
    Z = 0xc327b5d2636b32f27b051e4742b1bbd5324432c1000bfedca4368a29f6654152
    try:
        # Chuyển đổi sang tọa độ Affine
        affine_point = jacobian_to_affine(X, Y, Z, p)
        
        if affine_point is None:
            print("Điểm tại vô cực")
        else:
            x, y = affine_point
            print(f"Tọa độ Affine: x = {hex(x)}, y = {hex(y)}")
            
    except ValueError as e:
        print(f"Lỗi: {e}")
    
    # Thử với điểm tại vô cực (Z = 0)
    try:
        affine_point = jacobian_to_affine(X, Y, 0, p)
        if affine_point is None:
            print("Điểm tại vô cực (Z = 0)")
    except ValueError as e:
        print(f"Lỗi: {e}")