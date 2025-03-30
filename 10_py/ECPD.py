# Định nghĩa các tham số của đường cong elliptic Secp256k1
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF43 # Số nguyên tố p
cons = 0x0  # Hằng số a của đường cong Secp256k1

# Gán giá trị x1, y1, z1 (256-bit, giá trị hex)
x1 = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
y1 = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
z1 = 0x0000000000000000000000000000000000000000000000000000000000000001

# Hàm thực hiện phép nhân đôi điểm (point doubling)
def p_doubling(xG, yG, zG) :
    s = (((4 * xG) % p) * ((yG**2) % p)) % p
    t = ((yG**2) % p) * ((yG**2) % p) % p
    pre = ((zG**2) % p) * ((zG**2) % p) % p
    pre_1 = (cons * pre) % p
    m = ((3 * (xG**2) % p) + pre_1) % p
    x2 = ((m**2) % p - (2 * s) % p) % p
    y2 = ((m * (s - x2)) % p - (8 * t) % p) % p
    z2 = (2 * (yG * zG) % p) % p
    return (x2, y2, z2)

# Thực hiện phép nhân đôi điểm
x2, y2, z2 = p_doubling(x1, y1, z1)

# In kết quả
print("Kết quả phép nhân đôi điểm (Point Doubling):")
print(f"x2 = {hex(x2)}")
print(f"y2 = {hex(y2)}")
print(f"z2 = {hex(z2)}")