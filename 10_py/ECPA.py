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
    p = "D4E6F8A1B3C5D7E9F2A4C6D8E1B3F5A7C9D2E4F6A8B1C3D5E7F9A2B4C6D8E1F3"
    
    # Điểm P (X1, Y1, Z1) và Q (X2, Y2, Z2) dưới dạng hex 256-bit
    P = ("827F8DA5B3C4E6F1D2A7C9E8B6D4F3A1C5E2F7D9B8A6C3E5F2D7B9A4C1E6F3D8", 
         "91A3B5C7D9E2F4A6C8D1E3F5B7A9C2D4E6F8B1A3D5C7E9F2B4A6D8C1E3F5B7A9", 
         "0000000000000000000000000000000000000000000000000000000000000001")
    
    Q = ("A2B3C4D5E6F708192A3B4C5D6E7F8091A2B3C4D5E6F708192A3B4C5D6E7F8091", 
         "B6D8E1F3A5C7D9E2F4A6B8C1D3E5F7A9B2C4D6E8F1A3B5C7D9E2F4A6B8C1D3E5", 
         "0000000000000000000000000000000000000000000000000000000000000001")
    
    # Tính toán ECPA
    X3, Y3, Z3 = ECPA(p, P[0], P[1], P[2], Q[0], Q[1], Q[2])
    
    print("KQ Jacobian:")
    print("X3 =", X3)
    print("Y3 =", Y3)
    print("Z3 =", Z3)
