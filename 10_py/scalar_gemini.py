import sys

# Tăng giới hạn chuyển đổi int<->str để xử lý số lớn
# sys.set_int_max_str_digits(0) # Bỏ comment nếu cần thiết trên Python 3.11+ và gặp lỗi

# Tham số đường cong secp256k1
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
a = 0
b = 7

# Điểm vô cực trong tọa độ Jacobian
O = (1, 1, 0)

# --- Hàm tiện ích ---
def mod_inv(a, m):
    """Tính nghịch đảo modular của a theo modulo m bằng Định lý nhỏ Fermat"""
    if a == 0:
        raise ZeroDivisionError("division by zero")
    # m phải là số nguyên tố, điều này đúng với p của secp256k1
    return pow(a, m - 2, m)

# --- Phép toán tọa độ Jacobian ---
def jacobian_double(P):
    """Nhân đôi điểm P = (X, Y, Z) trong tọa độ Jacobian"""
    X1, Y1, Z1 = P
    if Z1 == 0:  # Điểm vô cực
        return O

    YSq = pow(Y1, 2, p)
    S = (4 * X1 * YSq) % p
    M = (3 * pow(X1, 2) + a * pow(Z1, 4)) % p # a=0 cho secp256k1
    # M = (3 * pow(X1, 2)) % p # Nếu a=0

    X3 = (pow(M, 2) - 2 * S) % p
    Y3 = (M * (S - X3) - 8 * pow(YSq, 2)) % p
    Z3 = (2 * Y1 * Z1) % p

    return (X3, Y3, Z3)

def jacobian_add(P, Q):
    """Cộng hai điểm P = (X1, Y1, Z1) và Q = (X2, Y2, Z2) trong tọa độ Jacobian"""
    X1, Y1, Z1 = P
    X2, Y2, Z2 = Q

    if Z1 == 0: return Q # P là điểm vô cực
    if Z2 == 0: return P # Q là điểm vô cực

    Z1Z1 = pow(Z1, 2, p)
    Z2Z2 = pow(Z2, 2, p)
    U1 = (X1 * Z2Z2) % p
    U2 = (X2 * Z1Z1) % p
    S1 = (Y1 * Z2 * Z2Z2) % p
    S2 = (Y2 * Z1 * Z1Z1) % p

    if U1 == U2:
        if S1 != S2:
            return O # P = -Q
        else:
            return jacobian_double(P) # P = Q

    H = (U2 - U1 + p) % p  # Đảm bảo kết quả không âm
    R = (S2 - S1 + p) % p  # Đảm bảo kết quả không âm
    H2 = pow(H, 2, p)
    H3 = (H * H2) % p
    U1H2 = (U1 * H2) % p

    X3 = (pow(R, 2) - H3 - 2 * U1H2) % p
    Y3 = (R * (U1H2 - X3) - S1 * H3) % p
    Z3 = (((Z1 * Z2) % p) * H) % p

    return (X3, Y3, Z3)

# --- Chuyển đổi tọa độ ---
def affine_to_jacobian(P):
    """Chuyển điểm Affine P = (x, y) sang Jacobian (X, Y, Z)"""
    if P is None: # Điểm vô cực Affine
        return O
    x, y = P
    return (x, y, 1)

def jacobian_to_affine(P):
    """Chuyển điểm Jacobian P = (X, Y, Z) sang Affine (x, y)"""
    X, Y, Z = P
    if Z == 0:
        return None # Điểm vô cực

    Zinv = mod_inv(Z, p)
    Zinv2 = pow(Zinv, 2, p)
    Zinv3 = (Zinv2 * Zinv) % p

    x = (X * Zinv2) % p
    y = (Y * Zinv3) % p
    return (x, y)

# --- Thuật toán Montgomery Ladder ---
def montgomery_ladder(P_affine, k):
    """
    Tính kP sử dụng thuật toán Montgomery Ladder (Left-to-right)
    Input: P_affine = (x, y), k là số nguyên 256-bit
    Output: Q = kP (trong tọa độ Jacobian)
    """
    if k == 0:
        return O
    if P_affine is None: # k * O = O
        return O

    # Bước 1: Khởi tạo
    R0 = affine_to_jacobian(P_affine)
    R1 = jacobian_double(R0)

    # Lấy số bit của k (ví dụ: 256 cho số 256-bit)
    # Cẩn thận: k có thể nhỏ hơn 2^255
    k_bits = k.bit_length()

    # Bước 2: Lặp từ bit áp chót (n-2) xuống 0
    # Thuật toán gốc giả định bit đầu là 1 và lặp từ n-2.
    # Nếu bit đầu của k là 0, chúng ta cần điều chỉnh hoặc đảm bảo k != 0
    # Cách triển khai này hoạt động đúng ngay cả khi bit cao nhất là 0
    # vì vòng lặp đi từ bit_length - 2.

    for i in range(k_bits - 2, -1, -1):
        # Lấy bit thứ i (tính từ 0 là bit thấp nhất)
        k_i = (k >> i) & 1

        # Bước 3 & 4 hoặc 5 & 6
        if k_i == 1:
            R0 = jacobian_add(R0, R1)
            R1 = jacobian_double(R1)
        else: # k_i == 0
            R1 = jacobian_add(R0, R1)
            R0 = jacobian_double(R0)

    # Bước 9: Trả về R0
    return R0

# --- Input được gán sẵn ---

# Ví dụ: Sử dụng điểm generator G của secp256k1
Gx = 0x2230E9BB9A661A80FC7D9BEE960E53B6AA54C23FFE9937202F47331A75B968D7
Gy = 0x42F6683C0EF050B0370287BB2C87035978224601DA557C0FD1BBD34582ED19E7
P_input_affine = (Gx, Gy)

# Ví dụ: Sử dụng một scalar k 256-bit ngẫu nhiên (hoặc bạn có thể đặt giá trị cụ thể)
# k_input = 0x1A2B3C4D5E6F708192A3B4C5D6E7F8091A2B3C4D5E6F708192A3B4C5D6E7F809
# k_input = 3 # Ví dụ k nhỏ để dễ kiểm tra
k_input = 0xd83715f87b79685cdc41927073554fa5d6ddc3d8e9327ee7ac9fc6a0eed765ed

print(f"Đường cong: secp256k1")
print(f"Điểm đầu vào P (Affine):")
print(f"  x = {P_input_affine[0]:#066x}")
print(f"  y = {P_input_affine[1]:#066x}")
print(f"Scalar k:")
print(f"  k = {k_input:#066x} ({k_input})")
print("-" * 70)

# --- Thực hiện thuật toán ---
Q_jacobian = montgomery_ladder(P_input_affine, k_input)

# --- Chuyển đổi kết quả sang Affine để hiển thị (tùy chọn) ---
Q_affine = jacobian_to_affine(Q_jacobian)

# --- In kết quả ---
print("Kết quả Q = kP:")
print("  Tọa độ Jacobian (X, Y, Z):")
print(f"    X = {Q_jacobian[0]:#066x}")
print(f"    Y = {Q_jacobian[1]:#066x}")
print(f"    Z = {Q_jacobian[2]:#066x}")
print("-" * 70)
if Q_affine:
    print("  Tọa độ Affine (x, y):")
    print(f"    x = {Q_affine[0]:#066x}")
    print(f"    y = {Q_affine[1]:#066x}")
else:
    print("  Tọa độ Affine: Điểm vô cực")

# --- Kiểm tra nhanh (ví dụ k=3) ---
if k_input == 3:
     P_jac = affine_to_jacobian(P_input_affine)
     P2_jac = jacobian_double(P_jac)
     P3_jac_check = jacobian_add(P2_jac, P_jac)
     P3_affine_check = jacobian_to_affine(P3_jac_check)
     print("-" * 70)
     print("Kiểm tra với k=3 (tính 2P + P):")
     if Q_affine == P3_affine_check:
         print("  Kết quả khớp!")
         print(f"    x = {P3_affine_check[0]:#066x}")
         print(f"    y = {P3_affine_check[1]:#066x}")
     else:
         print("  Kết quả KHÔNG khớp!")