from ecdsa.curves import SECP256k1
from ecdsa.ellipticcurve import Point
from ecdsa.numbertheory import inverse_mod

# ===== INPUT (CỐ ĐỊNH) =====
d_hex = "3E9F128209B8F412C2874E2F6656446BE30138B748B9E18401EE9BABC5CE923F"
z_hex = "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"
k_hex = "43F86641A085AF50C1293D806FBFC66FF4FA3EFC54F91FEBB8A87F6A379DF8CF"

d = int(d_hex, 16)
z = int(z_hex, 16)
k = int(k_hex, 16)

# ===== CURVE SETUP =====
curve = SECP256k1.curve
G = SECP256k1.generator
n = SECP256k1.order

print("=== ECDSA Intermediate Steps ===")
print("Private key d:", hex(d))
print("Message hash z:", hex(z))
print("Random k:", hex(k))
print("Curve order n:", hex(n))
print("Generator G.x =", hex(G.x()))
print("Generator G.y =", hex(G.y()))

# ===== Step 1: R = k * G =====
R: Point = k * G
x1 = R.x()
y1 = R.y()
r = x1 % n

print("\nStep 1: R = k * G")
print("  R.x =", hex(x1))
print("  R.y =", hex(y1))
print("  r   =", hex(r))

# ===== Step 2: s = k⁻¹ (z + r*d) mod n =====
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
print("\n=== Signature ===")
print("r =", hex(r))
print("s =", hex(s))
