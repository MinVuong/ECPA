def ECPA(p, X1, Y1, Z1, X2, Y2, Z2):
    """
    Thực hiện thuật toán ECPA (Elliptic Curve Point Addition ở tọa độ Jacobian)
    theo các bước đã được mô tả trong đoạn code Verilog.
    
    Tất cả các phép tính được thực hiện theo modulo p.
    Đầu ra vẫn ở dạng tọa độ Jacobian: (X3, Y3, Z3)
    """
    # Stage 1
    Z1_Z2 = (Z1 * Z2) % p
    Z1_SQ = (Z1 * Z1) % p
    Z2_SQ = (Z2 * Z2) % p

    # Stage 2
    Z1_cube = (Z1_SQ * Z1) % p
    Z2_cube = (Z2_SQ * Z2) % p
    U1 = (X1 * Z2_SQ) % p
    U2 = (X2 * Z1_SQ) % p

    # Stage 3
    S1 = (Y1 * Z2_cube) % p
    S2 = (Y2 * Z1_cube) % p
    H = (U1 - U2) % p
    R  = (S1 - S2) % p

    # Stage 4
    Z3 = (Z1_Z2 * H) % p
    H_SQ = (H * H) % p

    # Stage 5
    V = (U1 * H_SQ) % p
    H_cube = (H_SQ * H) % p
    R_SQ = (R * R) % p

    # Stage 6
    twoV = (2 * V) % p
    R_SQ_ADD_G = (R_SQ + H_cube) % p

    # Stage 7
    X3 = (R_SQ_ADD_G - twoV) % p

    # Stage 8
    V_SUB_X3 = (V - X3) % p

    # Stage 9
    Y3 = (R * V_SUB_X3) % p

    return X3, Y3, Z3


if __name__ == '__main__':
    # Sử dụng số nguyên mô-đun p, ví dụ p = 97
    p = 23

    # Giả sử ta có 2 điểm ở tọa độ Jacobian (với Z khác 0 nếu không là điểm vô hạn)
    P = (5, 17, 1)      # P = (X1, Y1, Z1)
    Q = (7, 13, 1)    # Q = (X2, Y2, Z2)

    # Tính điểm R = P + Q theo thuật toán ECPA
    X3, Y3, Z3 = ECPA(p, P[0], P[1], P[2], Q[0], Q[1], Q[2])

    print("ket qua o he Jacobian:")
    print("X3 =", X3)
    print("Y3 =", Y3)
    print("Z3 =", Z3)
