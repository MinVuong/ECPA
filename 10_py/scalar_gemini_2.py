import time

# --- Tham số đường cong secp256k1 ---
p_hex = "fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f"
p = int(p_hex, 16)
a = 0  # Hằng số a của secp256k1 (y^2 = x^3 + 7)
b = 7  # Hằng số b của secp256k1

# --- Hàm tính nghịch đảo modulo (Cần thiết để chuyển về Affine) ---
def inverse_mod(k, p_mod):
    """Tính k^-1 mod p_mod sử dụng thuật toán Euclid mở rộng."""
    if k == 0:
        raise ZeroDivisionError('division by zero')
    if k < 0:
        # k ** -1 mod p == (-k) ** -1 * (-1) mod p
        return (p_mod - inverse_mod(-k, p_mod)) % p_mod

    # Euclid mở rộng
    s, old_s = 0, 1
    t, old_t = 1, 0
    r, old_r = p_mod, k

    while r != 0:
        quotient = old_r // r
        old_r, r = r, old_r - quotient * r
        old_s, s = s, old_s - quotient * s
        old_t, t = t, old_t - quotient * t

    gcd, x, y = old_r, old_s, old_t
    assert gcd == 1, "Nghịch đảo modulo không tồn tại"
    return x % p_mod

# --- Phép cộng điểm Elliptic Curve (Jacobian) - Công thức chuẩn ---
def ec_add_jacobian(p_mod, X1, Y1, Z1, X2, Y2, Z2):
    """
    Thực hiện phép cộng P1 + P2 trên đường cong elliptic sử dụng tọa độ Jacobian.
    Sử dụng công thức chuẩn hóa.
    Trả về (X3, Y3, Z3) là tọa độ Jacobian của điểm kết quả.
    """
    # Xử lý trường hợp cộng với điểm vô cực (biểu diễn bởi Z=0)
    if Z1 == 0:
        return X2, Y2, Z2
    if Z2 == 0:
        return X1, Y1, Z1

    Z1sq = (Z1 * Z1) % p_mod
    Z2sq = (Z2 * Z2) % p_mod
    U1 = (X1 * Z2sq) % p_mod
    U2 = (X2 * Z1sq) % p_mod
    S1 = (Y1 * Z2sq * Z2) % p_mod
    S2 = (Y2 * Z1sq * Z1) % p_mod

    # Xử lý trường hợp P1 == P2 (nhân đôi) hoặc P1 == -P2
    if U1 == U2:
        if S1 != S2:
            return 0, 0, 0 # P1 = -P2, kết quả là điểm vô cực
        else:
            # P1 = P2, thực hiện nhân đôi
            return ec_double_jacobian(p_mod, a, X1, Y1, Z1)

    H = (U2 - U1) % p_mod
    R = (S2 - S1) % p_mod
    Hsq = (H * H) % p_mod
    Hcub = (H * Hsq) % p_mod
    U1Hsq = (U1 * Hsq) % p_mod

    X3 = (R * R - Hcub - 2 * U1Hsq) % p_mod
    Y3 = (R * (U1Hsq - X3) - S1 * Hcub) % p_mod
    Z3 = (Z1 * Z2 * H) % p_mod

    return X3, Y3, Z3

# --- Phép nhân đôi điểm Elliptic Curve (Jacobian) - Công thức chuẩn ---
def ec_double_jacobian(p_mod, a_curve, X1, Y1, Z1):
    """
    Thực hiện phép nhân đôi P1 (2*P1) trên đường cong elliptic sử dụng tọa độ Jacobian.
    Sử dụng công thức chuẩn hóa cho y^2 = x^3 + ax + b.
    Trả về (X3, Y3, Z3) là tọa độ Jacobian của điểm kết quả.
    """
    if Y1 == 0 or Z1 == 0: # Nhân đôi điểm vô cực hoặc điểm có y=0
        return 0, 0, 0

    YSq = (Y1 * Y1) % p_mod
    S = (4 * X1 * YSq) % p_mod
    Z1_4 = pow(Z1, 4, p_mod) # Z1^4 mod p
    M = (3 * X1 * X1 + a_curve * Z1_4) % p_mod
    X3 = (M * M - 2 * S) % p_mod
    Y3 = (M * (S - X3) - 8 * YSq * YSq) % p_mod
    Z3 = (2 * Y1 * Z1) % p_mod

    return X3, Y3, Z3

# --- Thuật toán Montgomery Ladder ---
def montgomery_ladder(k, Px_affine, Py_affine, p_mod, a_curve):
    """
    Tính kP sử dụng thuật toán Montgomery Ladder với tọa độ Jacobian.
    Input:
        k: số nguyên nhân.
        Px_affine, Py_affine: tọa độ affine của điểm P.
        p_mod: modulus của trường.
        a_curve: tham số 'a' của đường cong.
    Output:
        (X_res, Y_res, Z_res): tọa độ Jacobian của kP.
    """
    if k == 0:
        return 0, 0, 0 # kP là điểm vô cực

    # Chuyển điểm P ban đầu sang Jacobian (X, Y, Z=1)
    Px_jac, Py_jac, Pz_jac = Px_affine, Py_affine, 1

    # Khởi tạo R0 = P, R1 = 2P
    R0 = (Px_jac, Py_jac, Pz_jac)
    R1 = ec_double_jacobian(p_mod, a_curve, Px_jac, Py_jac, Pz_jac)

    k_bin = bin(k)[2:] # Lấy chuỗi nhị phân của k, bỏ '0b'

    # Lặp từ bit thứ hai (index 1) đến hết
    for i in range(1, len(k_bin)):
        if k_bin[i] == '1':
            # R0 = R0 + R1
            R0 = ec_add_jacobian(p_mod, R0[0], R0[1], R0[2], R1[0], R1[1], R1[2])
            # R1 = 2 * R1
            R1 = ec_double_jacobian(p_mod, a_curve, R1[0], R1[1], R1[2])
        else: # k_bin[i] == '0'
            # R1 = R0 + R1
            R1 = ec_add_jacobian(p_mod, R0[0], R0[1], R0[2], R1[0], R1[1], R1[2])
            # R0 = 2 * R0
            R0 = ec_double_jacobian(p_mod, a_curve, R0[0], R0[1], R0[2])

    return R0 # Trả về kết quả dưới dạng Jacobian (X, Y, Z)

# --- Chuyển đổi Jacobian sang Affine ---
def jacobian_to_affine(X, Y, Z, p_mod):
    """Chuyển đổi tọa độ Jacobian (X, Y, Z) sang Affine (x, y)."""
    if Z == 0:
        return None, None # Điểm vô cực

    Zinv = inverse_mod(Z, p_mod)
    Zinv_sq = (Zinv * Zinv) % p_mod
    Zinv_cub = (Zinv_sq * Zinv) % p_mod

    x_affine = (X * Zinv_sq) % p_mod
    y_affine = (Y * Zinv_cub) % p_mod
    return x_affine, y_affine

# --- Ví dụ sử dụng ---
if __name__ == '__main__':
    # Điểm generator G của secp256k1 (tọa độ Affine)
    Gx_hex = "2230E9BB9A661A80FC7D9BEE960E53B6AA54C23FFE9937202F47331A75B968D7"
    Gy_hex = "42F6683C0EF050B0370287BB2C87035978224601DA557C0FD1BBD34582ED19E7"
    Gx_int = int(Gx_hex, 16)
    Gy_int = int(Gy_hex, 16)

    # Số nhân k (ví dụ)
    k = 0xd83715f87b79685cdc41927073554fa5d6ddc3d8e9327ee7ac9fc6a0eed765ed
    #k = int("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1", 16) # Một số k lớn hơn

    print(f"Đường cong: secp256k1 (y^2 = x^3 + {b})")
    print(f"Modulus p = {p_hex}")
    print(f"Điểm Gx = {Gx_hex}")
    print(f"Điểm Gy = {Gy_hex}")
    print(f"Số nhân k = {k} ({hex(k)})")
    print("-" * 40)

    start_time = time.time()
    # Thực hiện Montgomery Ladder
    Qx_jac, Qy_jac, Qz_jac = montgomery_ladder(k, Gx_int, Gy_int, p, a)
    end_time = time.time()

    print(f"Thời gian thực hiện Montgomery Ladder: {end_time - start_time:.6f} giây")
    print("-" * 40)
    print("Kết quả kG (Tọa độ Jacobian):")
    print(f"X = {hex(Qx_jac)[2:].zfill(64)}")
    print(f"Y = {hex(Qy_jac)[2:].zfill(64)}")
    print(f"Z = {hex(Qz_jac)[2:].zfill(64)}")
    print("-" * 40)

    # Chuyển kết quả về tọa độ Affine để dễ kiểm tra
    start_time_affine = time.time()
    Qx_aff, Qy_aff = jacobian_to_affine(Qx_jac, Qy_jac, Qz_jac, p)
    end_time_affine = time.time()

    if Qx_aff is not None:
        print(f"Thời gian chuyển sang Affine: {end_time_affine - start_time_affine:.6f} giây")
        print("Kết quả kG (Tọa độ Affine):")
        print(f"x = {hex(Qx_aff)[2:].zfill(64)}")
        print(f"y = {hex(Qy_aff)[2:].zfill(64)}")
    else:
        print("Kết quả kG là điểm vô cực.")