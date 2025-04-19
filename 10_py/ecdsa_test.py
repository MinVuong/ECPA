from ecdsa import SigningKey, VerifyingKey, SECP256k1
from ecdsa.numbertheory import inverse_mod
import binascii

# Hàm chuyển đổi số nguyên thành hex 256-bit
def to_hex_256bit(n):
    return format(n, '064x')

# Lớp mô phỏng tọa độ Jacobian
class JacobianPoint:
    def __init__(self, x, y, z, curve=SECP256k1):
        self.x = x
        self.y = y
        self.z = z
        self.curve = curve
        self.p = curve.curve.p()  # Số nguyên tố của trường hữu hạn

    def to_affine(self):
        if self.z == 0:
            raise ValueError("Point at infinity")
        z_inv = inverse_mod(self.z, self.p)
        z_inv_2 = (z_inv * z_inv) % self.p
        z_inv_3 = (z_inv_2 * z_inv) % self.p
        x_affine = (self.x * z_inv_2) % self.p
        y_affine = (self.y * z_inv_3) % self.p
        return x_affine, y_affine

    def __str__(self):
        return f"x: {to_hex_256bit(self.x)}, y: {to_hex_256bit(self.y)}, z: {to_hex_256bit(self.z)}"

# Hàm nhân điểm trong tọa độ Jacobian (hỗ trợ cả điểm Jacobian đầu vào)
def multiply_point_jacobian(point, k, curve=SECP256k1):
    print(f"Multiplying point with k: {to_hex_256bit(k)}")
    if isinstance(point, JacobianPoint):
        P_jacobian = point
    else:
        P_x, P_y = point.x(), point.y()
        P_jacobian = JacobianPoint(P_x, P_y, 1, curve)
    
    result = JacobianPoint(1, 1, 0, curve)
    
    for bit in bin(k)[2:]:
        if result.z != 0:
            x, y, z = result.x, result.y, result.z
            T1 = (3 * x * x) % curve.curve.p()
            T2 = (4 * x * y * y) % curve.curve.p()
            T3 = (8 * y * y * y * y) % curve.curve.p()
            T4 = (2 * y * z) % curve.curve.p()
            new_x = (T1 * T1 - 2 * T2) % curve.curve.p()
            new_y = (T1 * (T2 - new_x) - T3) % curve.curve.p()
            new_z = T4
            result = JacobianPoint(new_x, new_y, new_z, curve)
        
        if bit == '1':
            if result.z == 0:
                result = JacobianPoint(P_jacobian.x, P_jacobian.y, P_jacobian.z, curve)
            else:
                x1, y1, z1 = result.x, result.y, result.z
                x2, y2, z2 = P_jacobian.x, P_jacobian.y, P_jacobian.z
                if z1 == 0:
                    result = JacobianPoint(x2, y2, z2, curve)
                    continue
                if z2 == 0:
                    continue
                z2_2 = (z2 * z2) % curve.curve.p()
                U1 = (x1 * z2_2) % curve.curve.p()
                z1_2 = (z1 * z1) % curve.curve.p()
                U2 = (x2 * z1_2) % curve.curve.p()
                S1 = (y1 * z2_2 * z2) % curve.curve.p()
                S2 = (y2 * z1_2 * z1) % curve.curve.p()
                H = (U2 - U1) % curve.curve.p()
                R = (S2 - S1) % curve.curve.p()
                H_2 = (H * H) % curve.curve.p()
                H_3 = (H_2 * H) % curve.curve.p()
                new_x = (R * R - H_3 - 2 * U1 * H_2) % curve.curve.p()
                new_y = (R * (U1 * H_2 - new_x) - S1 * H_3) % curve.curve.p()
                new_z = (z1 * z2 * H) % curve.curve.p()
                result = JacobianPoint(new_x, new_y, new_z, curve)

    return result

# Hàm cộng điểm trong tọa độ Jacobian (mô phỏng)
def add_points_jacobian(P1, P2, curve=SECP256k1):
    print("Adding points in Jacobian coordinates")
    if P1.z == 0:
        return P2
    if P2.z == 0:
        return P1
    
    x1, y1, z1 = P1.x, P1.y, P1.z
    x2, y2, z2 = P2.x, P2.y, P2.z
    
    U1 = (x1 * z2 * z2) % curve.curve.p()
    U2 = (x2 * z1 * z1) % curve.curve.p()
    S1 = (y1 * z2 * z2 * z2) % curve.curve.p()
    S2 = (y2 * z1 * z1 * z1) % curve.curve.p()
    H = (U2 - U1) % curve.curve.p()
    R = (S2 - S1) % curve.curve.p()
    
    H_2 = (H * H) % curve.curve.p()
    H_3 = (H_2 * H) % curve.curve.p()
    new_x = (R * R - H_3 - 2 * U1 * H_2) % curve.curve.p()
    new_y = (R * (U1 * H_2 - new_x) - S1 * H_3) % curve.curve.p()
    new_z = (z1 * z2 * H) % curve.curve.p()
    
    return JacobianPoint(new_x, new_y, new_z, curve)

# Hàm ký ECDSA với các bước trung gian trong tọa độ Jacobian
def signECDSAsecp256k1_with_jacobian(msg_hash, priv_key):
    print("=== Signing Process ===")
    
    try:
        msg_hash_bytes = binascii.unhexlify(msg_hash)
        if len(msg_hash_bytes) != 32:
            raise ValueError("Hash phải là chuỗi hex 256-bit (64 ký tự, 32 byte).")
    except binascii.Error:
        raise ValueError("Hash không phải là chuỗi hex hợp lệ.")
    
    hash_m = int.from_bytes(msg_hash_bytes, 'big')
    print(f"hash_m (message hash):")
    print(f"  Hex: {to_hex_256bit(hash_m)}")

    d = priv_key
    print(f"d (private key):")
    print(f"  Hex: {to_hex_256bit(d)}")

    G = SECP256k1.generator
    G_jacobian = JacobianPoint(G.x(), G.y(), 1)
    print(f"G (base point, Jacobian):")
    print(f"  {G_jacobian}")

    Q_jacobian = multiply_point_jacobian(G, d)
    print(f"Q (public key, Q = d*G, Jacobian):")
    print(f"  {Q_jacobian}")
    
    Q_affine = Q_jacobian.to_affine()
    print(f"Q (public key, affine for reference):")
    print(f"  x: {to_hex_256bit(Q_affine[0])}, y: {to_hex_256bit(Q_affine[1])}")

    k = int.from_bytes(SigningKey.generate(curve=SECP256k1).to_string(), 'big')
    print(f"k (random nonce):")
    print(f"  Hex: {to_hex_256bit(k)}")
    
    P_jacobian = multiply_point_jacobian(G, k)
    print(f"P (point P = k*G, Jacobian):")
    print(f"  {P_jacobian}")

    P_affine = P_jacobian.to_affine()
    n = SECP256k1.order
    r = P_affine[0] % n
    print(f"r (r = xP mod n):")
    print(f"  Hex: {to_hex_256bit(r)}")

    k_inv = inverse_mod(k, n)
    print(f"k^(-1) (inverse of k mod n):")
    print(f"  Hex: {to_hex_256bit(k_inv)}")
    
    s = (k_inv * (hash_m + r * d)) % n
    print(f"s (s = k^(-1)*(hash_m + r*d) mod n):")
    print(f"  Hex: {to_hex_256bit(s)}")

    return (r, s), Q_jacobian

# Hàm xác minh ECDSA với các bước trung gian trong tọa độ Jacobian
def verifyECDSAsecp256k1_with_jacobian(msg_hash, signature, Q_jacobian):
    print("\n=== Verification Process ===")
    
    try:
        msg_hash_bytes = binascii.unhexlify(msg_hash)
        if len(msg_hash_bytes) != 32:
            raise ValueError("Hash phải là chuỗi hex 256-bit (64 ký tự, 32 byte).")
    except binascii.Error:
        raise ValueError("Hash không phải là chuỗi hex hợp lệ.")
    
    hash_m = int.from_bytes(msg_hash_bytes, 'big')
    print(f"hash_m (message hash):")
    print(f"  Hex: {to_hex_256bit(hash_m)}")

    r, s = signature
    print(f"r:")
    print(f"  Hex: {to_hex_256bit(r)}")
    print(f"s:")
    print(f"  Hex: {to_hex_256bit(s)}")

    n = SECP256k1.order
    s_inv = inverse_mod(s, n)
    print(f"s^(-1) (inverse of s mod n):")
    print(f"  Hex: {to_hex_256bit(s_inv)}")
    
    u1 = (hash_m * s_inv) % n
    print(f"u1 (u1 = hash_m * s^(-1) mod n):")
    print(f"  Hex: {to_hex_256bit(u1)}")

    u2 = (r * s_inv) % n
    print(f"u2 (u2 = r * s^(-1) mod n):")
    print(f"  Hex: {to_hex_256bit(u2)}")

    G = SECP256k1.generator
    G_jacobian = JacobianPoint(G.x(), G.y(), 1)
    print(f"G (base point, Jacobian):")
    print(f"  {G_jacobian}")

    u1G = multiply_point_jacobian(G, u1)
    print(f"u1*G (point u1*G, Jacobian):")
    print(f"  {u1G}")

    u2Q = multiply_point_jacobian(Q_jacobian, u2)
    print(f"u2*Q (point u2*Q, Jacobian):")
    print(f"  {u2Q}")

    TP = add_points_jacobian(u1G, u2Q)
    print(f"TP (point TP = u1*G + u2*Q, Jacobian):")
    print(f"  {TP}")

    TP_affine = TP.to_affine()
    rTP = TP_affine[0] % n
    print(f"rTP (rTP = xTP mod n):")
    print(f"  Hex: {to_hex_256bit(rTP)}")

    print(f"Verification result: rTP == r? {rTP == r}")
    return rTP == r

# Tùy chỉnh khóa bí mật và hash thông điệp
custom_priv_key_hex = "3E9F128209B8F412C2874E2F6656446BE30138B748B9E18401EE9BABC5CE923F"  # 256-bit
custom_msg_hash_hex = "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"  # 256-bit

try:
    print("Starting program...")
    # Chuyển khóa bí mật từ hex thành số nguyên
    priv_key_bytes = binascii.unhexlify(custom_priv_key_hex)
    priv_key = int.from_bytes(priv_key_bytes, byteorder='big')
    print(f"Private key (integer): {priv_key}")

    if priv_key >= SECP256k1.order:
        raise ValueError(f"Khóa bí mật phải nhỏ hơn n = {to_hex_256bit(SECP256k1.order)}")

    # Ký với các bước trung gian
    signature, Q_jacobian = signECDSAsecp256k1_with_jacobian(custom_msg_hash_hex, priv_key)
    r, s = signature
    print("\nFinal Signature:")
    print(f"r (hex): {to_hex_256bit(r)}")
    print(f"s (hex): {to_hex_256bit(s)}")

    # Xác minh với các bước trung gian
    valid = verifyECDSAsecp256k1_with_jacobian(custom_msg_hash_hex, signature, Q_jacobian)
    print(f"Signature valid? {valid}")

    # Xác minh với hash giả mạo
    print("\n=== Verification with Tampered Hash ===")
    tampered_msg_hash_hex = "1111111111111111111111111111111111111111111111111111111111111111"
    valid = verifyECDSAsecp256k1_with_jacobian(tampered_msg_hash_hex, signature, Q_jacobian)
    print(f"Signature (tampered msg hash) valid? {valid}")

except ValueError as e:
    print("ValueError:", e)
except Exception as e:
    print("Other error:", e)