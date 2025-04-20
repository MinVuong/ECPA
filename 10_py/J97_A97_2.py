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
Xj = 0xee7731d57fb0e3300be67ef67b711111f38b90df5866d36859cb95ef97823715
Yj = 0x6a928f83e18d362142e6e4053e86e6625cf15ea1443e6bcfc1332ac934cba2b6
Zj = 0xcb593f4209d7afd44db336060352bbced87b9fb5a8e5aeb98b988b8416b9f7ec # Z = 1






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
