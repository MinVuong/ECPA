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
    P = ("fa69f8011578db2ada27bb3aafe75d45ac5041510c1b450b2e1375e1c7861e49", 
         "d2e3a415a2413d1640aa66a28a5d38f434cee078f4d3fab0d374773a4d544b75", 
         "cc74ae2b43899342f79f044d8bf91b90d35066fbdb1f0a48da3d286676e99e53")
    
    Q = ("26825a078e1a228eae4fa9999ab3d5e8a454362cb88fc7fe793b05fec60c50ce", 
         "c19edc26a26c43efb00f2691e9966978cee423d0f081c75999c90b0588a8e041", 
         "4e1e5438255f1c937e2d9684e09d9f4761f3709c84ec8c265ffddfd860f8764a")
    
    # Tính toán ECPA
    X3, Y3, Z3 = ECPA(p, P[0], P[1], P[2], Q[0], Q[1], Q[2])
    
    print("KQ Jacobian:")
    print("X3 =", X3)
    print("Y3 =", Y3)
    print("Z3 =", Z3)
