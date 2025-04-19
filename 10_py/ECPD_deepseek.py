def jacobian_ecpd(X, Y, Z, p):
    # Tính các giá trị trung gian
    A = (4 * X * pow(Y, 2, p)) % p
    B = (3 * pow(X, 2, p)) % p  # secp256k1 có a=0 nên bỏ qua aZ^4
    
    # Tính tọa độ mới
    X_new = (pow(B, 2, p) - 2 * A) % p
    Y_new = (B * (A - X_new) - 8 * pow(Y, 4, p)) % p
    Z_new = (2 * Y * Z) % p
    
    return (X_new, Y_new, Z_new)

# Thông số đường cong secp256k1
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F

# Điểm G của secp256k1 trong tọa độ Jacobian (Z=1)
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
Gz = 1

# Nhân đôi điểm G
G_doubled = jacobian_ecpd(Gx, Gy, Gz, p)

# Xuất kết quả dưới dạng hex
print("2G (Jacobian Coordinates - HEX):")
print(f"X: {hex(G_doubled[0])}")
print(f"Y: {hex(G_doubled[1])}")
print(f"Z: {hex(G_doubled[2])}")

# (Optional) Chuyển về Affine để kiểm tra
def jacobian_to_affine(X, Y, Z, p):
    if Z == 0:
        return (0, 0)
    Z_inv = pow(Z, p-2, p)
    Z_inv_sq = (Z_inv * Z_inv) % p
    Z_inv_cu = (Z_inv_sq * Z_inv) % p
    x = (X * Z_inv_sq) % p
    y = (Y * Z_inv_cu) % p
    return (x, y)

x_2G, y_2G = jacobian_to_affine(*G_doubled, p)
print("\n2G (Affine Coordinates - HEX):")
print(f"x: {hex(x_2G)}")
print(f"y: {hex(y_2G)}")