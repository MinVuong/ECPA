def modular_inverse(a, p):
    """Tính nghịch đảo modular của a theo modulo p bằng thuật toán Euclid mở rộng"""
    return pow(a, -1, p)

def jacobian_to_affine(p, X_jac, Y_jac, Z_jac):
    p = int(p, 16)
    X_jac, Y_jac, Z_jac = int(X_jac, 16), int(Y_jac, 16), int(Z_jac, 16)
    
    # Tính nghịch đảo của Z^2 và Z^3
    Z_inv = modular_inverse(Z_jac, p)
    Z2_inv = (Z_inv * Z_inv) % p  # Z^(-2) mod p
    Z3_inv = (Z2_inv * Z_inv) % p  # Z^(-3) mod p
    
    # Chuyển đổi về hệ tọa độ Affine
    X_affine = (X_jac * Z2_inv) % p
    Y_affine = (Y_jac * Z3_inv) % p
    
    return hex(X_affine)[2:].zfill(64), hex(Y_affine)[2:].zfill(64)

if __name__ == '__main__':
    # Modulo p (256-bit hex)
    p = "D4E6F8A1B3C5D7E9F2A4C6D8E1B3F5A7C9D2E4F6A8B1C3D5E7F9A2B4C6D8E1F3"
    
    # Điểm Jacobian (X3, Y3, Z3) từ kết quả ECPA
    X3 = "827F8DA5B3C4E6F1D2A7C9E8B6D4F3A1C5E2F7D9B8A6C3E5F2D7B9A4C1E6F3D8"
    Y3 = "91A3B5C7D9E2F4A6C8D1E3F5B7A9C2D4E6F8B1A3D5C7E9F2B4A6D8C1E3F5B7A9"
    Z3 = "0000000000000000000000000000000000000000000000000000000000000001"
    
    # Chuyển đổi sang hệ tọa độ Affine
    X_aff, Y_aff = jacobian_to_affine(p, X3, Y3, Z3)
    
    print("Tọa độ Affine:")
    print("X =", X_aff)
    print("Y =", Y_aff)
