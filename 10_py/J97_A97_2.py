# Curve parameters for SECP256k1
p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f
# Tọa độ Jacobian: (X, Y, Z)
def jacobian_to_affine(X, Y, Z):
    """Chuyển đổi từ hệ tọa độ Jacobian sang hệ tọa độ Affine."""
    if Z == 0:
        return (0, 0)  # Điểm vô cùng
    # Tính Z^2 và Z^3
    Z2 = pow(Z, 2, p)
    Z3 = (Z2 * Z) % p
    # Chuyển từ Jacobian sang Affine (x, y)
    x = (X * pow(Z2, -1, p)) % p  # x = X / Z^2
    y = (Y * pow(Z3, -1, p)) % p  # y = Y / Z^3
    return (x, y)

# Ví dụ về tọa độ Jacobian
Xj = 0x79dc91def04d4fefb45d1892cc75ad6f1d105a57c5e6a8c1a6e66aabeb76b562
Yj = 0xf045c90493cbade96f06ee69c3651d68ee37cae4379009262cfcc7b96b63af09
Zj = 0xe7f928b2e2a3e71d07d5e10107cb1b7c9f459b7cb02909e102ace65dde8e3e14 # Z = 1





# Chuyển từ Jacobian sang Affine
x_affine, y_affine = jacobian_to_affine(Xj, Yj, Zj)

print("=== Jacobian to Affine ===")
print("  Tọa độ Jacobian:")
print("    X =", hex(Xj))
print("    Y =", hex(Yj))
print("    Z =", hex(Zj))
print("\n  Tọa độ Affine:")
print("    x =", hex(x_affine))
print("    y =", hex(y_affine))
