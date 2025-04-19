# Python program to perform point addition in Jacobian coordinates for ECDSA
# Curve parameters for secp256k1 (commonly used in ECDSA)
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F  # Prime field modulus
a = 0  # Curve parameter a for secp256k1
b = 7  # Curve parameter b for secp256k1

def mod_inverse(a, p):
    """Compute the modular inverse of a modulo p using extended Euclidean algorithm."""
    def extended_gcd(a, b):
        if a == 0:
            return b, 0, 1
        gcd, x1, y1 = extended_gcd(b % a, a)
        x = y1 - (b // a) * x1
        y = x1
        return gcd, x, y
    
    _, x, _ = extended_gcd(a, p)
    return (x % p + p) % p

def jacobian_add(P, Q, p):
    """Add two points P and Q in Jacobian coordinates on an elliptic curve."""
    # P and Q are tuples (X, Y, Z)
    if P is None:  # P is point at infinity
        return Q
    if Q is None:  # Q is point at infinity
        return P
    
    X1, Y1, Z1 = P
    X2, Y2, Z2 = Q
    
    # Check if P = Q (point doubling case)
    if X1 * Z2**2 % p == X2 * Z1**2 % p and Y1 * Z2**3 % p == Y2 * Z1**3 % p:
        return jacobian_double(P, p)
    
    # Compute intermediate values
    Z1Z1 = Z1 * Z1 % p
    Z2Z2 = Z2 * Z2 % p
    U1 = X1 * Z2Z2 % p
    U2 = X2 * Z1Z1 % p
    S1 = Y1 * Z2 * Z2Z2 % p
    S2 = Y2 * Z1 * Z1Z1 % p
    
    # If U1 == U2 and S1 != S2, return point at infinity
    if U1 == U2 and S1 != S2:
        return None
    
    H = (U2 - U1) % p
    R = (S2 - S1) % p
    
    # Compute H^2 and H^3
    HH = H * H % p
    HHH = HH * H % p
    
    # Compute intermediate values
    V = U1 * HH % p
    X3 = (R * R - HHH - 2 * V) % p
    Y3 = (R * (V - X3) - S1 * HHH) % p
    Z3 = (Z1 * Z2 * H) % p
    
    return (X3, Y3, Z3)

def jacobian_double(P, p):
    """Double a point P in Jacobian coordinates."""
    if P is None:
        return None
    
    X1, Y1, Z1 = P
    
    # If Y1 = 0, return point at infinity
    if Y1 == 0:
        return None
    
    # Compute intermediate values
    YY = Y1 * Y1 % p
    YYYY = YY * YY % p
    XX = X1 * X1 % p
    ZZ = Z1 * Z1 % p
    
    # Compute S = 4 * X1 * Y1^2
    S = (4 * X1 * YY) % p
    
    # Compute M = 3 * X1^2 + a * Z1^4
    M = (3 * XX + a * ZZ * ZZ) % p
    
    # Compute X3 = M^2 - 2 * S
    X3 = (M * M - 2 * S) % p
    
    # Compute Y3 = M * (S - X3) - 8 * Y1^4
    Y3 = (M * (S - X3) - 8 * YYYY) % p
    
    # Compute Z3 = 2 * Y1 * Z1
    Z3 = (2 * Y1 * Z1) % p
    
    return (X3, Y3, Z3)

# Example usage
if __name__ == "__main__":
    # Example points in Jacobian coordinates (X, Y, Z)
    P = (0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8, 1)  # Z=1 means affine point scaled
    Q = (0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8, 1)
    
    # Perform point addition
    result = jacobian_add(P, Q, p)
    
    # Print result
    if result is None:
        print("Result is the point at infinity")
    else:
        X3, Y3, Z3 = result
        print(f"Resulting point: X={X3}, Y={Y3}, Z={Z3}")
        
        # Convert back to affine coordinates (if needed)
        if Z3 != 0:
            Z3_inv = mod_inverse(Z3, p)
            X_affine = (X3 * Z3_inv**2) % p
            Y_affine = (Y3 * Z3_inv**3) % p
            print(f"Affine coordinates: X={X_affine}, Y={Y_affine}")