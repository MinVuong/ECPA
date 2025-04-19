import math
import random
import sys

curve_sel = 1

if curve_sel == 0:
    print("Secp256k1")
    # secp256k1
    p = 1157920892373161954235709850086879078532699846656405640394575840079088346713663
    n = 115792089237316195423570985008687907852837564279074904382605163141518161494337
    xG = 55066263022277343669578718895168534326250603453777594175500187360389116729240
    yG = 32670510020758816978083085130507043184471273380659243275938904335757337482424
    zG = 1
    cons = 0
else:
    print("Secp256r1")
    # secp256r1
    p = 115792089210356248762697446949407573530086143415290314195533631308867097853951
    n = 115792089210356248762697446949407573529996955224135760342422259061068512044369
    xG = 48439561293906451759052585252797914202762949526041747995844080717082404635286
    yG = 36134250956749795798585127919587881956611106672985015071877198253568414405109
    zG = 1
    cons = 115792089210356248762697446949407573530086143415290314195533631308867097853948

# Define the maximum value for a 256-bit integer
max_256_bit = p - 1

# Generate a random number within the 256-bit range
k = random.randint(1, max_256_bit - 1)
print("Random nonce value: k = ", k)

d = random.randint(1, max_256_bit - 1)
print("Private key value : d = ", d)

hash_m = 76394218023947102839471028394710283947102839471028394710283947102839471028394

def decimalToBinary(n):
    binary = bin(n & (2**256 - 1))[2:]  # Convert decimal to binary, truncate to 256 bits
    return binary.zfill(256)  # Pad with leading zeros to make it 256 bits long.

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m

def p_doubling(xG, yG, zG):
    s = (((4 * xG) % p) * ((yG**2) % p)) % p
    t = (((yG**2) % p) * ((yG**2) % p)) % p
    pre = (((zG**2) % p) * ((zG**2) % p)) % p
    pre_1 = (cons * pre) % p
    m = (((3 * (xG**2) % p) % p) + (pre_1)) % p
    x2 = ((m**2) % p - (2 * s) % p) % p
    y2 = (((m * (s - x2)) % p) % p - (8 * t) % p) % p
    z2 = (2 * ((yG * zG) % p)) % p
    return (x2, y2, z2)

def p_adding(x1, y1, z1, x2, y2, z2):
    u1 = (x1 * (z2**2 % p)) % p
    u2 = (x2 * (z1**2 % p)) % p
    h = (u1 - u2) % p
    s2 = (y2 * (((z1**2 % p) * z1) % p)) % p
    s1 = (y1 * (((z2**2 % p) * z2) % p)) % p
    v = (u1 * (h**2 % p)) % p
    g = ((h**2 % p) * h) % p
    r = (s1 - s2) % p
    x3 = (((r**2 % p + g) % p) - (2 * v % p)) % p
    y3 = (((r * (((v - x3) % p)) % p) - ((s1 * g) % p))) % p
    z3 = (((z1 * z2) % p) * h) % p
    return (x3, y3, z3)

def scalar_mul(n, xG, yG, zG):
    G = [xG, yG, zG]
    arr_k = []
    k = decimalToBinary(n)
    for c in k:
        arr_k.append(c)
    [x0, y0, z0] = [xG, yG, zG]
    [x1, y1, z1] = p_doubling(xG, yG, zG)
    for i in range(1, len(arr_k)):
        if arr_k[i] == "1":
            [x0, y0, z0] = p_adding(x0, y0, z0, x1, y1, z1)
            [x1, y1, z1] = p_doubling(x1, y1, z1)
        elif arr_k[i] == "0":
            [x1, y1, z1] = p_adding(x0, y0, z0, x1, y1, z1)
            [x0, y0, z0] = p_doubling(x0, y0, z0)
    return (x0, y0, z0)

# Generate signature (r, s)
[x3, y3, z3] = scalar_mul(k, xG, yG, zG)
tmp = z3**2 % p
tx = modinv(tmp, p)
x = (x3 * tx) % p
r = x % n
inv_k = modinv(k, n)
tmp_1 = (r * d) % n
tmp_2 = hash_m % n
tmp_s = (tmp_1 + tmp_2) % n
s = (inv_k * tmp_s) % n

[xq, yq, zq] = scalar_mul(d, xG, yG, zG)
tmp = zq**2 % p
tx = modinv(tmp, p)
xq1 = (xq * tx) % p
tmp1 = tmp * zq % p
ty = modinv(tmp1, p)
yq1 = (yq * ty) % p

print("Public Key Generation:")
print("affine coordinate of xq:", xq1)
print("affine coordinate of yq:", yq1)
print("Signature Pair Generation:")
print("r =", r)
print("s =", s)

# Verify signature
c = modinv(s, n)
u1 = hash_m * c % n
u2 = r * c % n
[xu1, yu1, zu1] = scalar_mul(u1, xG, yG, zG)
[xu2, yu2, zu2] = scalar_mul(u2, xq, yq, zq)
[xp, yp, zp] = p_adding(xu1, yu1, zu1, xu2, yu2, zu2)
tmp = zp**2 % p
tx = modinv(tmp, p)
xp = (xp * tx) % p
r_tp = xp % n

if r == r_tp:
    print("signature is verified!")
else:
    print("signature is invalid!")

r_xor_s = r ^ s
r_xor_s_hex = hex(r_xor_s)
print("signature compressed xor:", r_xor_s_hex)