#xử lí thêm bit 0 dẫn đầu
import time

# --- Tham số đường cong secp256k1 ---
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
a = 0
b = 7
Gx = 0xadc60c6eb52ab37ff799bf51f3071c3664a14bedd50daa748c9f951823892185
Gy = 0x8c3da685efe1470a10a2715befca474b8318c4cee378b0d472bc2c9fc9c2de2d
n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

G_affine = (Gx, Gy)
Jacobian_Infinity = (None, None, None)

# --- Hàm phụ trợ ---

def mod_inverse(a, m):
    """Tính nghịch đảo modulo của a theo modulo m bằng thuật toán Fermat."""
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

def affine_to_jacobian(P_affine):
    """Chuyển điểm từ tọa độ Affine sang Jacobian."""
    if P_affine is None:
        return Jacobian_Infinity
    x, y = P_affine
    return (x, y, 1)

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

def montgomery_ladder_jacobian(k, P_jacobian, output_file="scalar_mult_steps.txt"):
    """
    Tính k * P_jacobian sử dụng thuật toán Montgomery Ladder trên tọa độ Jacobian.
    Xử lý chuỗi nhị phân 256-bit đầy đủ, bao gồm các bit 0 dẫn đầu.
    Ghi kết quả trung gian vào tệp.
    """
    if P_jacobian is None or k == 0 or k % n == 0:
        return Jacobian_Infinity

    k = k % n
    if k == 0:
        return Jacobian_Infinity

    # Lấy biểu diễn nhị phân 256-bit, bao gồm các bit 0 dẫn đầu
    k_bin = format(k, '0256b')  # Chuỗi nhị phân đủ 256 bit

    R0 = Jacobian_Infinity
    R1 = P_jacobian

    with open(output_file, "w") as f:
        f.write("Montgomery Ladder Scalar Multiplication Steps:\n")
        f.write(f"Scalar k (binary, 256-bit): {k_bin}\n")
        f.write(f"Base Point P (Jacobian): {format_jacobian(P_jacobian)}\n\n")

        for step, bit in enumerate(k_bin):
            bit_position = 255 - step  # Vị trí bit đang xét (từ trái sang phải, 0-based index)
            f.write(f"Step {step + 1} (bit={bit}, bit_position={bit_position}):\n")
            f.write(f"  R0 (Jacobian): {format_jacobian(R0)}\n")
            f.write(f"  R1 (Jacobian): {format_jacobian(R1)}\n")

            if bit == '0':
                R1 = jacobian_point_add(R0, R1)
                R0 = jacobian_point_double(R0)
            else:  # bit == '1'
                R0 = jacobian_point_add(R0, R1)
                R1 = jacobian_point_double(R1)

            f.write(f"  After Step {step + 1}:\n")
            f.write(f"    R0 (Jacobian): {format_jacobian(R0)}\n")
            f.write(f"    R1 (Jacobian): {format_jacobian(R1)}\n\n")

        f.write("Final Result:\n")
        f.write(f"  R0 (Jacobian): {format_jacobian(R0)}\n")

    return R0

def format_jacobian(P):
    """Định dạng tọa độ Jacobian để ghi vào tệp."""
    if P == Jacobian_Infinity:
        return "Infinity"
    return f"X={hex(P[0])}, Y={hex(P[1])}, Z={hex(P[2])}"

# --- Ví dụ sử dụng và kiểm tra ---

if __name__ == "__main__":
    # Scalar (private key)
    scalar_k = 0x419c7456868c26ea3cabeafa8074ce3e96cee5e78bd090ebc6bdd5b9909b52ad

    # Chuyển điểm gốc G sang tọa độ Jacobian
    G_jacobian = affine_to_jacobian(G_affine)

    print(f"Đường cong: secp256k1")
    print(f"Điểm gốc G (Jacobian):")
    print(f"  X = {hex(G_jacobian[0])}")
    print(f"  Y = {hex(G_jacobian[1])}")
    print(f"  Z = {hex(G_jacobian[2])}")
    print(f"Scalar k = {hex(scalar_k)}")
    print("-" * 50)

    # Thực hiện phép nhân vô hướng k * G
    output_file = "scalar_mult_steps.txt"
    print(f"Thực hiện phép nhân vô hướng k * G bằng Montgomery Ladder (Jacobian)...")
    start_time = time.time()
    result_point_jacobian = montgomery_ladder_jacobian(scalar_k, G_jacobian, output_file)
    end_time = time.time()
    print(f"Thời gian thực hiện: {end_time - start_time:.6f} giây")
    print(f"Kết quả trung gian đã được ghi vào tệp: {output_file}")

    if result_point_jacobian != Jacobian_Infinity and result_point_jacobian is not None:
        Rx, Ry, Rz = result_point_jacobian
        print("Kết quả R = k * G (Jacobian):")
        print(f"  X = {hex(Rx)}")
        print(f"  Y = {hex(Ry)}")
        print(f"  Z = {hex(Rz)}")

        # Chuyển về tọa độ Affine để kiểm tra
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

    # Kiểm tra với k nhỏ (k = 13) để thấy tác động của bit 0 dẫn đầu
    print("-" * 50)
    scalar_k_test = 13
    print(f"Kiểm tra với k = {scalar_k_test} (xử lý bit 0 dẫn đầu)")
    start_time = time.time()
    result_test_jacobian = montgomery_ladder_jacobian(scalar_k_test, G_jacobian, "scalar_mult_test.txt")
    end_time = time.time()
    print(f"Thời gian thực hiện: {end_time - start_time:.6f} giây")
    if result_test_jacobian != Jacobian_Infinity and result_test_jacobian is not None:
        Rx, Ry, Rz = result_test_jacobian
        print("Kết quả 13*G (Jacobian):")
        print(f"  X = {hex(Rx)}")
        print(f"  Y = {hex(Ry)}")
        print(f"  Z = {hex(Rz)}")
        result_test_affine = jacobian_to_affine(result_test_jacobian)
        if result_test_affine:
            Ax, Ay = result_test_affine
            print("Kết quả 13*G (Affine để kiểm tra):")
            print(f"  Ax = {hex(Ax)}")
            print(f"  Ay = {hex(Ay)}")
        else:
            print("Không thể chuyển đổi kết quả Jacobian về Affine.")
    else:
        print("Kết quả là điểm vô cực (Jacobian).")

    # Kiểm tra trường hợp đặc biệt: n * G = Điểm vô cực
    print("-" * 50)
    print(f"Kiểm tra: n * G (với n là bậc của nhóm)")
    start_time = time.time()
    inf_point_jacobian = montgomery_ladder_jacobian(n, G_jacobian, "scalar_mult_inf.txt")
    end_time = time.time()
    print(f"Thời gian thực hiện: {end_time - start_time:.6f} giây")
    if inf_point_jacobian == Jacobian_Infinity or inf_point_jacobian is None:
        print("Kết quả: Điểm vô cực (Jacobian) (Đúng như mong đợi)")
    else:
        print(f"Kết quả (Jacobian): {format_jacobian(inf_point_jacobian)} (Sai!)")
        affine_inf = jacobian_to_affine(inf_point_jacobian)
        print(f"Kết quả (Affine): {affine_inf}")