from ecdsa.curves import SECP256k1
from ecdsa.ellipticcurve import CurveFp
from ecdsa.numbertheory import inverse_mod

curve = SECP256k1.curve
generator = SECP256k1.generator

print("=== SECP256k1 Curve Parameters ===")
print("Field Prime p     =", hex(curve.p()))
print("Curve Coefficient a =", hex(curve.a()))
print("Curve Coefficient b =", hex(curve.b()))
print("Order n           =", hex(SECP256k1.order))
print("Generator G:")
print("  Gx =", hex(generator.x()))
print("  Gy =", hex(generator.y()))

# ===== INPUT (CỐ ĐỊNH) =====
d_hex = "3E9F128209B8F412C2874E2F6656446BE30138B748B9E18401EE9BABC5CE923F"
z_hex = "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"
k_hex = "43F86641A085AF50C1293D806FBFC66FF4FA3EFC54F91FEBB8A87F6A379DF8CF"

d = int(d_hex, 16)
z = int(z_hex, 16)
k = int(k_hex, 16)

# ===== CURVE SETUP =====
curve = SECP256k1.curve
p = curve.p()
a = curve.a()
b = curve.b()
n = SECP256k1.order
Gx = SECP256k1.generator.x()
Gy = SECP256k1.generator.y()

print("=== ECDSA with Jacobian Scalar Multiplication ===")

# ===== Jacobian Point Operations =====
def jacobian_double(X1, Y1, Z1):
    if Y1 == 0:
        return (1, 1, 0)
    S = (4 * X1 * pow(Y1, 2, p)) % p
    M = (3 * pow(X1, 2, p) + a * pow(Z1, 4, p)) % p
    X3 = (pow(M, 2, p) - 2 * S) % p
    Y3 = (M * (S - X3) - 8 * pow(Y1, 4, p)) % p
    Z3 = (2 * Y1 * Z1) % p
    return (X3, Y3, Z3)

def jacobian_add(X1, Y1, Z1, X2, Y2, Z2):
    if Z1 == 0:
        return (X2, Y2, Z2)
    if Z2 == 0:
        return (X1, Y1, Z1)
    U1 = (X1 * pow(Z2, 2, p)) % p
    U2 = (X2 * pow(Z1, 2, p)) % p
    S1 = (Y1 * pow(Z2, 3, p)) % p
    S2 = (Y2 * pow(Z1, 3, p)) % p
    if U1 == U2:
        if S1 != S2:
            return (1, 1, 0)
        else:
            return jacobian_double(X1, Y1, Z1)
    H = (U2 - U1) % p
    R = (S2 - S1) % p
    H2 = (H * H) % p
    H3 = (H * H2) % p
    U1H2 = (U1 * H2) % p
    X3 = (R * R - H3 - 2 * U1H2) % p
    Y3 = (R * (U1H2 - X3) - S1 * H3) % p
    Z3 = (H * Z1 * Z2) % p
    return (X3, Y3, Z3)

def jacobian_multiply(k, X, Y, Z=1):
    k_bin = bin(k)[2:]
    Q = (1, 1, 0)  # Point at infinity
    for bit in k_bin:
        Q = jacobian_double(*Q)
        if bit == '1':
            Q = jacobian_add(*Q, X, Y, Z)
    return Q

def jacobian_to_affine(X, Y, Z):
    if Z == 0:
        return (0, 0)
    Z2 = pow(Z, 2, p)
    Z3 = (Z2 * Z) % p
    x = (X * pow(Z2, -1, p)) % p
    y = (Y * pow(Z3, -1, p)) % p
    return (x, y)

# ===== Step 1: R = k * G (Jacobian) =====
Xj, Yj, Zj = jacobian_multiply(k, Gx, Gy)
x1, y1 = jacobian_to_affine(Xj, Yj, Zj)
r = x1 % n

print("Step 1: R = k * G (Jacobian)")
print("  R (Jacobian):")
print("    X =", hex(Xj))
print("    Y =", hex(Yj))
print("    Z =", hex(Zj))
print("  R (Affine):")
print("    x1 =", hex(x1))
print("    y1 =", hex(y1))
print("  r =", hex(r))

# ===== Step 2: s = k^(-1) * (z + r*d) mod n =====
rd = (r * d) % n
sum_ = (z + rd) % n
k_inv = inverse_mod(k, n)
s = (k_inv * sum_) % n

print("\nStep 2: s = k^(-1) * (z + r*d) mod n")
print("  r * d     =", hex(rd))
print("  z + r*d   =", hex(sum_))
print("  k^(-1)    =", hex(k_inv))
print("  s         =", hex(s))

# ===== Final Output =====
print("\n=== ECDSA Signature ===")
print("r =", hex(r))
print("s =", hex(s))
