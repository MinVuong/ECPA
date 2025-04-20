# --- Tham số đường cong secp256k1 ---
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

Jacobian_Infinity = (None, None, None)

# --- Hàm phụ trợ ---

def mod_inverse(a, m):
    """Tính nghịch đảo modulo của a theo modulo m."""
    if a == 0:
        raise ZeroDivisionError("Không thể tính nghịch đảo modulo của 0")
    return pow(a, m - 2, m)

# --- Phép toán điểm trên tọa độ Jacobian ---

def jacobian_point_double(P):
    """Nhân đôi một điểm trong tọa độ Jacobian."""
    X, Y, Z = P
    if Z is None or Y == 0:
        return Jacobian_Infinity
    YSq = (Y * Y) % p
    S = (4 * X * YSq) % p
    M = (3 * X * X) % p  # a=0
    X_res = (M * M - 2 * S) % p
    Y_res = (M * (S - X_res) - 8 * YSq * YSq) % p
    Z_res = (2 * Y * Z) % p
    return (X_res, Y_res, Z_res)

def jacobian_point_add(P, Q):
    """Cộng hai điểm trong tọa độ Jacobian."""
    X1, Y1, Z1 = P
    X2, Y2, Z2 = Q
    if Z1 is None:
        return Q
    if Z2 is None:
        return P
    Z1sq = (Z1 * Z1) % p
    Z2sq = (Z2 * Z2) % p
    Z1cu = (Z1 * Z1sq) % p
    Z2cu = (Z2 * Z2sq) % p
    U1 = (X1 * Z2sq) % p
    U2 = (X2 * Z1sq) % p
    S1 = (Y1 * Z2cu) % p
    S2 = (Y2 * Z1cu) % p
    if U1 == U2:
        if S1 != S2:
            return Jacobian_Infinity
        else:
            return jacobian_point_double(P)
    H = (U2 - U1) % p
    R = (S2 - S1) % p
    Hsq = (H * H) % p
    Hcu = (H * Hsq) % p
    U1Hsq = (U1 * Hsq) % p
    X_res = (R * R - Hcu - 2 * U1Hsq) % p
    Y_res = (R * (U1Hsq - X_res) - S1 * Hcu) % p
    Z_res = (Z1 * Z2 * H) % p
    return (X_res, Y_res, Z_res)

# --- Chuyển đổi tọa độ ---

def jacobian_to_affine(P_jacobian):
    """Chuyển điểm từ tọa độ Jacobian sang Affine."""
    X, Y, Z = P_jacobian
    if Z is None or Z == 0:
        return None
    Z_inv = mod_inverse(Z, p)
    Z_inv_sq = (Z_inv * Z_inv) % p
    Z_inv_cu = (Z_inv_sq * Z_inv) % p
    x_affine = (X * Z_inv_sq) % p
    y_affine = (Y * Z_inv_cu) % p
    return (x_affine, y_affine)

# --- Phép nhân vô hướng bằng Montgomery Ladder trên tọa độ Jacobian ---

def montgomery_ladder_jacobian(k, P_jacobian):
    """
    Tính k * P_jacobian bằng thuật toán Montgomery Ladder trong tọa độ Jacobian.
    Xử lý chuỗi nhị phân 256-bit, bao gồm bit 0 dẫn đầu.
    
    Args:
        k (int): Số vô hướng (scalar).
        P_jacobian (tuple): Điểm trong tọa độ Jacobian (X, Y, Z).
    
    Returns:
        tuple: Điểm kết quả trong tọa độ Jacobian (X, Y, Z) hoặc điểm vô cực.
    """
    if P_jacobian is None or k == 0 or k % n == 0:
        return Jacobian_Infinity

    k = k % n
    if k == 0:
        return Jacobian_Infinity

    # Lấy biểu diễn nhị phân 256-bit, bao gồm bit 0 dẫn đầu
    k_bin = format(k, '0256b')  # Chuỗi nhị phân đủ 256 bit

    R0 = Jacobian_Infinity
    R1 = P_jacobian

    for bit in k_bin:
        if bit == '0':
            R1 = jacobian_point_add(R0, R1)
            R0 = jacobian_point_double(R0)
        else:  # bit == '1'
            R0 = jacobian_point_add(R0, R1)
            R1 = jacobian_point_double(R1)

    return R0

# --- Hàm chính để chạy chương trình ---

if __name__ == "__main__":
    # Ví dụ điểm Jacobian đầu vào (có thể thay đổi)
    P_jacobian = (
        0x867cc23291cc05dca1ce1677008b12d9af590a075c50829bcb9643a0ff98b8fd,  # X
        0xec041b51153cee93c66df85584072387635b5dc37ab1c892307b5b803f85aa58,  # Y
        0x652f639cf96a62265c317810a05f0226a5e176239da34d2fd5a019b986c6eb0b  # Z
    )

    # Số vô hướng (có thể thay đổi)
    scalar_k = 0x10f21e9cfa0ec6c040815fc526fae83ab326623ba51ab38d7ca727f90891d527

    # Tính phép nhân vô hướng
    result_jacobian = montgomery_ladder_jacobian(scalar_k, P_jacobian)

    # In kết quả
    print("Kết quả R = k * P (Jacobian):")
    if result_jacobian == Jacobian_Infinity:
        print("Điểm vô cực")
    else:
        Rx, Ry, Rz = result_jacobian
        print(f"  X = {hex(Rx)}")
        print(f"  Y = {hex(Ry)}")
        print(f"  Z = {hex(Rz)}")

        # Chuyển về Affine để dễ đọc (tùy chọn)
        result_affine = jacobian_to_affine(result_jacobian)
        if result_affine:
            Ax, Ay = result_affine
            print("Kết quả R = k * P (Affine):")
            print(f"  Ax = {hex(Ax)}")
            print(f"  Ay = {hex(Ay)}")
        else:
            print("Không thể chuyển đổi về Affine.")