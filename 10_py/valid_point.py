import random
from ecdsa import SECP256k1
from ecdsa.ellipticcurve import Point

# secp256k1 parameters
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8

def is_on_curve(x, y, p):
    """Check if point (x, y) lies on the secp256k1 curve."""
    return (y * y - (x * x * x + 7)) % p == 0

def affine_to_jacobian(x, y, Z, p):
    """Convert Affine (x, y) to Jacobian (X, Y, Z) with given Z."""
    X = (x * Z * Z) % p
    Y = (y * Z * Z * Z) % p
    return X, Y, Z

def jacobian_to_affine(X, Y, Z, p):
    """Convert Jacobian (X, Y, Z) to Affine (x, y)."""
    if Z == 0:
        return None
    Z_inv = pow(Z, p - 2, p)
    x = (X * Z_inv * Z_inv) % p
    y = (Y * Z_inv * Z_inv * Z_inv) % p
    return x, y

# Initialize curve and base point
curve = SECP256k1.curve
G = Point(curve, Gx, Gy)

# Generate two random valid points P1 = k1*G, P2 = k2*G
k1 = random.randint(1, n-1)
k2 = random.randint(1, n-1)
P1 = k1 * G
P2 = k2 * G

# Affine coordinates
x1, y1 = P1.x(), P1.y()
x2, y2 = P2.x(), P2.y()

# Verify points are on curve
assert is_on_curve(x1, y1, p), "P1 not on curve"
assert is_on_curve(x2, y2, p), "P2 not on curve"

# Choose random Z values for Jacobian (to simulate Z != 1)
Z1 = random.randint(1, p-1)
Z2 = random.randint(1, p-1)

# Convert to Jacobian
X1, Y1, Z1 = affine_to_jacobian(x1, y1, Z1, p)
X2, Y2, Z2 = affine_to_jacobian(x2, y2, Z2, p)

# Verify equivalence by converting Jacobian back to Affine
x1_check, y1_check = jacobian_to_affine(X1, Y1, Z1, p)
x2_check, y2_check = jacobian_to_affine(X2, Y2, Z2, p)

# Display results and check equivalence
print("Point P1:")
if (x1_check, y1_check) == (x1, y1):
    print("  Affine and Jacobian are equivalent")
else:
    print("  Error: Affine and Jacobian are NOT equivalent")
print(f"  Affine:   x1 = {hex(x1)}")
print(f"            y1 = {hex(y1)}")
print(f"  Jacobian: X1 = {hex(X1)}")
print(f"            Y1 = {hex(Y1)}")
print(f"            Z1 = {hex(Z1)}")

print("\nPoint P2:")
if (x2_check, y2_check) == (x2, y2):
    print("  Affine and Jacobian are equivalent")
else:
    print("  Error: Affine and Jacobian are NOT equivalent")
print(f"  Affine:   x2 = {hex(x2)}")
print(f"            y2 = {hex(y2)}")
print(f"  Jacobian: X2 = {hex(X2)}")
print(f"            Y2 = {hex(Y2)}")
print(f"            Z2 = {hex(Z2)}")