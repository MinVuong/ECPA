def ECPA(p, X1, Y1, Z1, X2, Y2, Z2):
    p = int(p, 16)
    X1, Y1, Z1 = int(X1, 16), int(Y1, 16), int(Z1, 16)
    X2, Y2, Z2 = int(X2, 16), int(Y2, 16), int(Z2, 16)
    
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
    R = (S1 - S2) % p
    
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
    
    return hex(X3)[2:].zfill(64), hex(Y3)[2:].zfill(64), hex(Z3)[2:].zfill(64)


if __name__ == '__main__':
    # Modulo p (256-bit hex)
    p = "fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f"
    
    # Điểm P (X1, Y1, Z1) và Q (X2, Y2, Z2) dưới dạng hex 256-bit
    P = ("0000000000000000000000000000000000000000000000000000000000000000", 
         "0000000000000000000000000000000000000000000000000000000000000001", 
         "0000000000000000000000000000000000000000000000000000000000000000")
    
    Q = ("4b82bf5f6655ac6be5f66fc070f0f31838cb375027040d0ab1b5680c84f43127", 
         "01c08b7d0e94c0dcb7defda9224f53e61e47fe20ad2420a71de13d393f2b9399", 
         "0000000000000000000000000000000000000000000000000000000000000001")
    
    # Tính toán ECPA
    X3, Y3, Z3 = ECPA(p, P[0], P[1], P[2], Q[0], Q[1], Q[2])
    
    print("KQ Jacobian:")
    print("X3 =", X3)
    print("Y3 =", Y3)
    print("Z3 =", Z3)
