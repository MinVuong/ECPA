# Chuong trình thực hiện scalar multiplication trên đường cong secp256k1 trên hệ toạ độ Jacobian
# Montgomery Ladder for secp256k1 in Jacobian coordinates

# secp256k1 parameters
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F  # Prime modulus
a = 0  # Curve parameter a
b = 7  # Curve parameter b
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798  # Base point x
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8  # Base point y
Gz = 1  # Base point z (Jacobian)

def mod_inverse(a, p):
    """Compute modular inverse of a modulo p using extended Euclidean algorithm."""
    def extended_gcd(a, b):
        if a == 0:
            return b, 0, 1
        gcd, x1, y1 = extended_gcd(b % a, a)
        x = y1 - (b // a) * x1
        y = x1
        return gcd, x, y
    
    gcd, x, _ = extended_gcd(a % p, p)
    if gcd != 1:
        raise ValueError(f"No modular inverse for {a} mod {p}")
    return (x % p + p) % p

def is_point_on_curve(X, Y, Z):
    """Check if point [X:Y:Z] is on secp256k1 curve in Jacobian coordinates."""
    if Z == 0:
        return True  # Point at infinity
    Z2 = (Z * Z) % p
    Z3 = (Z2 * Z) % p
    x = (X * mod_inverse(Z2, p)) % p  # x = X / Z^2
    y = (Y * mod_inverse(Z3, p)) % p  # y = Y / Z^3
    left = (y * y) % p
    right = (x * x * x + a * x + b) % p
    return left == right

def point_add(X1, Y1, Z1, X2, Y2, Z2):
    """Point addition in Jacobian coordinates for secp256k1."""
    if Z1 == 0:
        return X2, Y2, Z2  # P1 is infinity
    if Z2 == 0:
        return X1, Y1, Z1  # P2 is infinity
    
    Z1Z1 = (Z1 * Z1) % p
    Z2Z2 = (Z2 * Z2) % p
    U1 = (X1 * Z2Z2) % p
    U2 = (X2 * Z1Z1) % p
    S1 = (Y1 * Z2Z2 * Z2) % p
    S2 = (Y2 * Z1Z1 * Z1) % p
    
    H = (U2 - U1) % p
    R = (S2 - S1) % p
    
    if H == 0:
        if R == 0:
            return point_double(X1, Y1, Z1)  # P1 = P2
        else:
            return 0, 1, 0  # P1 = -P2 (infinity)
    
    H2 = (H * H) % p
    H3 = (H2 * H) % p
    U1H2 = (U1 * H2) % p
    X3 = (R * R - H3 - 2 * U1H2) % p
    Y3 = (R * (U1H2 - X3) - S1 * H3) % p
    Z3 = (Z1 * Z2 * H) % p
    
    return X3, Y3, Z3

def point_double(X1, Y1, Z1):
    """Point doubling in Jacobian coordinates for secp256k1."""
    if Z1 == 0 or Y1 == 0:
        return 0, 1, 0  # Infinity
    
    Y1Y1 = (Y1 * Y1) % p
    S = (4 * X1 * Y1Y1) % p
    Z1Z1 = (Z1 * Z1) % p
    M = (3 * X1 * X1 + a * Z1Z1 * Z1Z1) % p  # a = 0 for secp256k1
    T = (M * M - 2 * S) % p
    X3 = T
    Y3 = (M * (S - T) - 8 * Y1Y1 * Y1Y1) % p
    Z3 = (2 * Y1 * Z1) % p
    
    return X3, Y3, Z3

def montgomery_ladder(k, X, Y, Z):
    """Montgomery Ladder for scalar multiplication kP in Jacobian coordinates."""
    if not is_point_on_curve(X, Y, Z):
        raise ValueError("Input point is not on secp256k1 curve")
    
    # Initialize R0 = P, R1 = 2P
    R0_X, R0_Y, R0_Z = X, Y, Z
    R1_X, R1_Y, R1_Z = point_double(X, Y, Z)
    
    # Convert k to binary and process from MSB to LSB
    k_bits = bin(k)[2:]  # Remove '0b' prefix
    for bit in k_bits:
        if bit == '0':
            # R1 = R0 + R1, R0 = 2R0
            R1_X, R1_Y, R1_Z = point_add(R0_X, R0_Y, R0_Z, R1_X, R1_Y, R1_Z)
            R0_X, R0_Y, R0_Z = point_double(R0_X, R0_Y, R0_Z)
        else:
            # R0 = R0 + R1, R1 = 2R1
            R0_X, R0_Y, R0_Z = point_add(R0_X, R0_Y, R0_Z, R1_X, R1_Y, R1_Z)
            R1_X, R1_Y, R1_Z = point_double(R1_X, R1_Y, R1_Z)
    
    return R0_X, R0_Y, R0_Z

def main():
    # Test with base point G and a sample scalar k
    k = 0x3E9F128209B8F412C2874E2F6656446BE30138B748B9E18401EE9BABC5CE923F  # Example scalar (can be 256-bit)
    X, Y, Z = Gx, Gy, Gz  # Base point G
    
    try:
        X_out, Y_out, Z_out = montgomery_ladder(k, X, Y, Z)
        print(f"Input point P: [{hex(X)}, {hex(Y)}, {hex(Z)}]")
        print(f"Scalar k: {hex(k)}")
        print(f"Result kP: [{hex(X_out)}, {hex(Y_out)}, {hex(Z_out)}]")
        
        # Convert to affine for verification (optional)
        if Z_out != 0:
            Z2 = (Z_out * Z_out) % p
            Z3 = (Z2 * Z_out) % p
            x_affine = (X_out * mod_inverse(Z2, p)) % p
            y_affine = (Y_out * mod_inverse(Z3, p)) % p
            print(f"Affine coordinates: ({hex(x_affine)}, {hex(y_affine)})")
        else:
            print("Result is point at infinity")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
