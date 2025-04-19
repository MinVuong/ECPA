# Elliptic Curve Point Doubling (ECPD) for secp256k1 in Jacobian coordinates
# Outputs result in Jacobian coordinates (X, Y, Z) as hex

def point_double(P, p, a):
    """Double a point P = (X, Y, Z) in Jacobian coordinates for secp256k1."""
    if P is None or P[1] == 0 or P[2] == 0:
        return None  # Point at infinity or invalid
    
    X1, Y1, Z1 = P
    
    # Compute intermediate values (simplified for a = 0)
    W = (3 * X1 * X1) % p
    S = (Y1 * Z1) % p
    B = (X1 * Y1 * S) % p
    H = (W * W - 8 * B) % p
    
    # Compute output coordinates
    X3 = (2 * H) % p
    Y3 = (W * (4 * B - H) - 8 * Y1 * Y1 * S * S) % p
    Z3 = (8 * S * S * S) % p
    
    return (X3, Y3, Z3)

def to_hex(P):
    """Convert a Jacobian point (X, Y, Z) to hex format."""
    if P is None:
        return "Point at infinity"
    X, Y, Z = P
    return (
        f"X: {hex(X)[2:].zfill(64).upper()}\n"
        f"Y: {hex(Y)[2:].zfill(64).upper()}\n"
        f"Z: {hex(Z)[2:].zfill(64).upper()}"
    )

# secp256k1 parameters
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
a = 0
b = 7  # Not used directly, included for completeness

# Generator point G in affine coordinates
G_affine = (
    0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
    0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
)

# Example usage
if __name__ == "__main__":
    # Convert G to Jacobian coordinates: (X, Y, Z=1)
    x, y = G_affine
    P = (x, y, 1)
    
    # Compute 2P
    result = point_double(P, p, a)
    
    # Print result in Jacobian coordinates as hex
    print("Input point P (Jacobian):")
    print(to_hex(P))
    print("\nResult 2P (Jacobian):")
    print(to_hex(result))