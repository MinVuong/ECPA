def point_add_jacobian(P, Q, p):
    """Add two points P and Q in Jacobian coordinates."""
    if P is None:
        return Q
    if Q is None:
        return P
    
    x1, y1, z1 = P
    x2, y2, z2 = Q
    
    if z1 == 0:
        return Q
    if z2 == 0:
        return P
    
    z1z1 = pow(z1, 2, p)
    z2z2 = pow(z2, 2, p)
    u1 = (x1 * z2z2) % p
    u2 = (x2 * z1z1) % p
    s1 = (y1 * z2 * z2z2) % p
    s2 = (y2 * z1 * z1z1) % p
    
    if u1 == u2:
        if s1 != s2:
            return None  # Point at infinity
        return point_double_jacobian(P, p)
    
    h = (u2 - u1) % p
    i = pow(2 * h, 2, p)
    j = (h * i) % p
    r = (2 * (s2 - s1)) % p
    v = (u1 * i) % p
    
    x3 = (r * r - j - 2 * v) % p
    y3 = (r * (v - x3) - 2 * s1 * j) % p
    z3 = ((z1 + z2) ** 2 - z1z1 - z2z2) * h % p
    
    return (x3, y3, z3)


def point_double_jacobian(P, p):
    """Double a point in Jacobian coordinates."""
    if P is None:
        return None
    
    x, y, z = P
    if y == 0:
        return None
    
    y2 = (y * y) % p
    s = (4 * x * y2) % p
    m = (3 * x * x) % p  # Assuming a = 0 for simplicity
    t = (m * m - 2 * s) % p
    z3 = (2 * y * z) % p
    y3 = (m * (s - t) - 8 * (y2 * y2)) % p
    
    return (t, y3, z3)


def montgomery_ladder(k, P, p):
    """Perform scalar multiplication using Montgomery Ladder."""
    R0 = (0, 1, 0)  # Point at infinity
    R1 = P
    
    for i in reversed(range(k.bit_length())):
        if (k >> i) & 1:
            R0 = point_add_jacobian(R0, R1, p)
            R1 = point_double_jacobian(R1, p)
        else:
            R1 = point_add_jacobian(R0, R1, p)
            R0 = point_double_jacobian(R0, p)
    
    return R0  # Resulting point in Jacobian coordinates


# Example usage:
x = 0x4b82bf5f6655ac6be5f66fc070f0f31838cb375027040d0ab1b5680c84f43127  # Tọa độ x của điểm
y = 0x01c08b7d0e94c0dcb7defda9224f53e61e47fe20ad2420a71de13d393f2b9399  # Tọa độ y của điểm
z = 0x1  # Tọa độ z của điểm
p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f  # Số nguyên tố p (modulo)
k = 0xd83715f87b79685cdc41927073554fa5d6ddc3d8e9327ee7ac9fc6a0eed765ed  # Hệ số nhân scalar

result = montgomery_ladder(k, (x, y, z), p)
x_res, y_res, z_res = result
print("Result (Jacobian):")
print(f"X: {hex(x_res)[2:].zfill(64)}")  # Định dạng thành 256-bit hex
print(f"Y: {hex(y_res)[2:].zfill(64)}")  # Định dạng thành 256-bit hex
print(f"Z: {hex(z_res)[2:].zfill(64)}")  # Định dạng thành 256-bit hex
