import ecdsa
from ecdsa import ellipticcurve, numbertheory

# Define the curve parameters (using secp256k1 as an example)
curve = ecdsa.curves.SECP256k1.curve
p = curve.p()

# Define the scalar and point (replace these with your actual values)
k = int("d83715f87b79685cdc41927073554fa5d6ddc3d8e9327ee7ac9fc6a0eed765ed", 16)
X = int("4b82bf5f6655ac6be5f66fc070f0f31838cb375027040d0ab1b5680c84f43127", 16)
Y = int("01c08b7d0e94c0dcb7defda9224f53e61e47fe20ad2420a71de13d393f2b9399", 16)
Z = int("1", 16)  # Replace with your actual Z value if different
print(f"Curve prime modulus p: {hex(p)}")
# Point doubling in Jacobian coordinates
def point_double(X1, Y1, Z1, p):
    if Y1 == 0:
        return (0, 0, 0)
    S = (4 * X1 * Y1**2) % p
    M = (3 * X1**2) % p
    X3 = (M**2 - 2 * S) % p
    Y3 = (M * (S - X3) - 8 * Y1**4) % p
    Z3 = (2 * Y1 * Z1) % p
    return (X3, Y3, Z3)

# Point addition in Jacobian coordinates
def point_add(X1, Y1, Z1, X2, Y2, Z2, p):
    if Z1 == 0:
        return (X2, Y2, Z2)
    if Z2 == 0:
        return (X1, Y1, Z1)
    U1 = (X1 * Z2**2) % p
    U2 = (X2 * Z1**2) % p
    S1 = (Y1 * Z2**3) % p
    S2 = (Y2 * Z1**3) % p
    if U1 == U2:
        if S1 != S2:
            return (0, 0, 0)
        return point_double(X1, Y1, Z1, p)
    H = (U2 - U1) % p
    R = (S2 - S1) % p
    H2 = (H * H) % p
    H3 = (H * H2) % p
    X3 = (R**2 - H3 - 2 * U1 * H2) % p
    Y3 = (R * (U1 * H2 - X3) - S1 * H3) % p
    Z3 = (H * Z1 * Z2) % p
    return (X3, Y3, Z3)

# Scalar multiplication in Jacobian coordinates
def scalar_mult(k, X, Y, Z, p):
    X0, Y0, Z0 = 0, 1, 0  # Neutral point in Jacobian coordinates
    X1, Y1, Z1 = X, Y, Z
    for bit in reversed(bin(k)[2:]):
        if bit == '1':
            X0, Y0, Z0 = point_add(X0, Y0, Z0, X1, Y1, Z1, p)
            X1, Y1, Z1 = point_double(X1, Y1, Z1, p)
        else:
            X1, Y1, Z1 = point_add(X0, Y0, Z0, X1, Y1, Z1, p)
            X0, Y0, Z0 = point_double(X0, Y0, Z0, p)
    return (X0, Y0, Z0)

# Perform scalar multiplication
X_out, Y_out, Z_out = scalar_mult(k, X, Y, Z, p)

# Print the result
print(f"X_out: {hex(X_out)}")
print(f"Y_out: {hex(Y_out)}")
print(f"Z_out: {hex(Z_out)}")