import time

# --- Tham số đường cong secp256k1 và hàm phụ trợ (GIỮ NGUYÊN) ---
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
a = 0
b = 7
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

G_affine = (Gx, Gy)
Jacobian_Infinity = (None, None, None)

def mod_inverse(a, m):
    if a == 0:
        raise ZeroDivisionError("Không thể tính nghịch đảo modulo của 0")
    return pow(a, m - 2, m)

# --- Phép toán điểm trên tọa độ Jacobian (GIỮ NGUYÊN) ---

def jacobian_point_double(P):
    X, Y, Z = P
    if Z is None or Y == 0:
        return Jacobian_Infinity
    YSq = (Y * Y) % p
    S = (4 * X * YSq) % p
    M = (3 * X * X) % p # a=0
    X_res = (M * M - 2 * S) % p
    Y_res = (M * (S - X_res) - 8 * YSq * YSq) % p
    Z_res = (2 * Y * Z) % p
    return (X_res, Y_res, Z_res)

def jacobian_point_add(P, Q):
    X1, Y1, Z1 = P
    X2, Y2, Z2 = Q
    if Z1 is None: return Q
    if Z2 is None: return P
    Z1sq = (Z1 * Z1) % p
    Z2sq = (Z2 * Z2) % p
    Z1cu = (Z1 * Z1sq) % p
    Z2cu = (Z2 * Z2sq) % p
    U1 = (X1 * Z2sq) % p
    U2 = (X2 * Z1sq) % p
    S1 = (Y1 * Z2cu) % p
    S2 = (Y2 * Z1cu) % p
    if U1 == U2:
        if S1 != S2: return Jacobian_Infinity
        else: return jacobian_point_double(P)
    H = (U2 - U1) % p
    R = (S2 - S1) % p
    Hsq = (H * H) % p
    Hcu = (H * Hsq) % p
    U1Hsq = (U1 * Hsq) % p
    X_res = (R * R - Hcu - 2 * U1Hsq) % p
    Y_res = (R * (U1Hsq - X_res) - S1 * Hcu) % p
    Z_res = (Z1 * Z2 * H) % p
    return (X_res, Y_res, Z_res)

# --- Chuyển đổi tọa độ (GIỮ NGUYÊN) ---

def affine_to_jacobian(P_affine):
    if P_affine is None: return Jacobian_Infinity
    x, y = P_affine
    return (x, y, 1)

def jacobian_to_affine(P_jacobian):
    X, Y, Z = P_jacobian
    if Z is None: return None
    if Z == 0: return None
    Z_inv = mod_inverse(Z, p)
    Z_inv_sq = (Z_inv * Z_inv) % p
    Z_inv_cu = (Z_inv_sq * Z_inv) % p
    x_affine = (X * Z_inv_sq) % p
    y_affine = (Y * Z_inv_cu) % p
    return (x_affine, y_affine)

# --- Phép nhân vô hướng bằng Montgomery Ladder trên tọa độ Jacobian ---

def montgomery_ladder_jacobian(k, P_jacobian, output_file):
    """Tính k * P_jacobian sử dụng thuật toán Montgomery Ladder trên tọa độ Jacobian và ghi kết quả trung gian vào tệp."""
    if P_jacobian is None or k == 0 or k % n == 0:
        return Jacobian_Infinity  # k*Infinity = Infinity, 0*P = Infinity, n*P = Infinity

    k = k % n  # Đảm bảo k nằm trong khoảng [1, n-1]
    if k == 0:
        return Jacobian_Infinity  # Nếu k là bội số của n

    # Khởi tạo R0 = Điểm vô cực, R1 = P (Jacobian)
    R0 = Jacobian_Infinity
    R1 = P_jacobian

    # Lấy biểu diễn nhị phân của k
    k_bin = bin(k)[2:]  # Bỏ tiền tố '0b'

    # Mở tệp để ghi kết quả
    with open(output_file, "w") as f:
        f.write("Montgomery Ladder Scalar Multiplication Steps:\n")
        f.write(f"Scalar k (binary): {k_bin}\n")
        f.write(f"Base Point P (Jacobian): X={hex(P_jacobian[0])}, Y={hex(P_jacobian[1])}, Z={hex(P_jacobian[2])}\n\n")

        # Duyệt qua các bit của k từ trái sang phải (MSB to LSB)
        for step, bit in enumerate(k_bin):
            f.write(f"Step {step + 1} (bit={bit}):\n")
            f.write(f"  R0 (Jacobian): {format_jacobian(R0)}\n")
            f.write(f"  R1 (Jacobian): {format_jacobian(R1)}\n")

            if bit == '0':
                # R1 <- R0 + R1
                R1 = jacobian_point_add(R0, R1)
                # R0 <- 2 * R0
                R0 = jacobian_point_double(R0)
            else:  # bit == '1'
                # R0 <- R0 + R1
                R0 = jacobian_point_add(R0, R1)
                # R1 <- 2 * R1
                R1 = jacobian_point_double(R1)

            f.write(f"  After Step {step + 1}:\n")
            f.write(f"    R0 (Jacobian): {format_jacobian(R0)}\n")
            f.write(f"    R1 (Jacobian): {format_jacobian(R1)}\n\n")

        # Ghi kết quả cuối cùng
        f.write("Final Result:\n")
        f.write(f"  R0 (Jacobian): {format_jacobian(R0)}\n")

    return R0


def format_jacobian(P):
    """Định dạng tọa độ Jacobian để ghi vào tệp."""
    if P == Jacobian_Infinity:
        return "Infinity"
    return f"X={hex(P[0])}, Y={hex(P[1])}, Z={hex(P[2])}"


# --- Ví dụ sử dụng ---
if __name__ == "__main__":
    # Scalar (private key) - chọn một số ngẫu nhiên nhỏ hơn n
    scalar_k = 0x3E9F128209B8F412C2874E2F6656446BE30138B748B9E18401EE9BABC5CE923F

    # Chuyển điểm gốc G sang tọa độ Jacobian
    G_jacobian = affine_to_jacobian(G_affine)

    print(f"Đường cong: secp256k1")
    print(f"Điểm gốc G (Jacobian):")
    print(f"  X = {hex(G_jacobian[0])}")
    print(f"  Y = {hex(G_jacobian[1])}")
    print(f"  Z = {hex(G_jacobian[2])}")
    print(f"Scalar k = {hex(scalar_k)}")
    print("-" * 30)

    # Ghi kết quả trung gian vào tệp
    output_file = "scalar_mult_steps.txt"
    print(f"Thực hiện phép nhân vô hướng k * G bằng Montgomery Ladder (Jacobian)...")
    result_point_jacobian = montgomery_ladder_jacobian(scalar_k, G_jacobian, output_file)
    print(f"Kết quả trung gian đã được ghi vào tệp: {output_file}")

    if result_point_jacobian is not Jacobian_Infinity and result_point_jacobian is not None:
        Rx, Ry, Rz = result_point_jacobian
        print("Kết quả R = k * G (Jacobian):")
        print(f"  X = {hex(Rx)}")
        print(f"  Y = {hex(Ry)}")
        print(f"  Z = {hex(Rz)}")

        # Để kiểm tra, bạn có thể chuyển đổi kết quả về Affine
        result_point_affine = jacobian_to_affine(result_point_jacobian)
        if result_point_affine:
            Ax, Ay = result_point_affine
            print("Kết quả R = k * G (Affine để kiểm tra):")
            print(f"  Ax = {hex(Ax)}")
            print(f"  Ay = {hex(Ay)}")
        else:
            print("Không thể chuyển đổi kết quả Jacobian về Affine.")
    else:
        print("Kết quả là điểm vô cực (Jacobian).")

    # Kiểm tra lại với một scalar khác, ví dụ k=2
    print("-" * 30)
    scalar_k_test = 2
    print(f"Kiểm tra với k = {scalar_k_test}")
    start_time = time.time()
    result_2G_jacobian = montgomery_ladder_jacobian(scalar_k_test, G_jacobian)
    end_time = time.time()
    print(f"Thời gian thực hiện: {end_time - start_time:.6f} giây")
    if result_2G_jacobian is not Jacobian_Infinity and result_2G_jacobian is not None:
        Rx, Ry, Rz = result_2G_jacobian
        print("Kết quả 2*G (Jacobian):")
        print(f"  X = {hex(Rx)}")
        print(f"  Y = {hex(Ry)}")
        print(f"  Z = {hex(Rz)}")
        result_2G_affine = jacobian_to_affine(result_2G_jacobian)
        if result_2G_affine:
            Ax, Ay = result_2G_affine
            print("Kết quả 2*G (Affine để kiểm tra):")
            print(f"  Ax = {hex(Ax)}")
            print(f"  Ay = {hex(Ay)}")
        else:
            print("Không thể chuyển đổi kết quả Jacobian về Affine.")
    else:
        print("Kết quả là điểm vô cực (Jacobian).")

    # Kiểm tra một trường hợp đặc biệt: n * G = Điểm vô cực
    print("-" * 30)
    print(f"Kiểm tra: n * G (với n là bậc của nhóm)")
    start_time = time.time()
    inf_point_jacobian = montgomery_ladder_jacobian(n, G_jacobian)
    end_time = time.time()
    print(f"Thời gian thực hiện: {end_time - start_time:.6f} giây")
    if inf_point_jacobian is Jacobian_Infinity or inf_point_jacobian is None:
        print("Kết quả: Điểm vô cực (Jacobian) (Đúng như mong đợi)")
    else:
        print(f"Kết quả (Jacobian): {inf_point_jacobian} (Sai!)")
        affine_inf = jacobian_to_affine(inf_point_jacobian)
        print(f"Kết quả (Affine): {affine_inf}")