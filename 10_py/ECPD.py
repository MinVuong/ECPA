# Định nghĩa các tham số của đường cong elliptic Secp256k1
cons = 0x0  # Hằng số a của đường cong Secp256k1

# Gán giá trị x1, y1, z1 (256-bit, giá trị hex)
x1 = 0x173821f778c640c503e347b4bc593574aef3fbd5935bfb5a27af375e4a6e0ce4
y1 = 0x9b62720289e7a45e23c0761be46347d4088d140ce8097142b21dfcd6acbb8704
z1 = 0x85ecd0781de0a1606e050f76590e06b2f0448c03b4aaf81fa377a68b05da33ce
p =  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F

# Hàm thực hiện phép nhân đôi điểm (point doubling)
def p_doubling(xG, yG, zG):
    with open("output.txt", "w") as f:  # Mở tệp để ghi kết quả
        s = (((4 * xG) % p) * ((yG**2) % p)) % p
        f.write(f"s = {hex(s)}\n")
        
        t = ((yG**2) % p) * ((yG**2) % p) % p
        f.write(f"t = {hex(t)}\n")
        
        pre = ((zG**2) % p) * ((zG**2) % p) % p
        f.write(f"pre = {hex(pre)}\n")
        
        pre_1 = (cons * pre) % p
        f.write(f"pre_1 = {hex(pre_1)}\n")
        
        m = ((3 * (xG**2) % p) + pre_1) % p
        f.write(f"m = {hex(m)}\n")
        
        m_2 = (m * m) % p
        f.write(f"m_2 = {hex(m_2)}\n")
        
        two_s = (2 * s) % p
        f.write(f"two_s = {hex(two_s)}\n")
        
        x2 = (m_2 - two_s) % p
        f.write(f"x2 = {hex(x2)}\n")
        
        y2 = ((m * (s - x2)) % p - (8 * t) % p) % p
        f.write(f"y2 = {hex(y2)}\n")
        
        z2 = (2 * (yG * zG) % p) % p
        f.write(f"z2 = {hex(z2)}\n")
        
    return (x2, y2, z2)

# Thực hiện phép nhân đôi điểm
x2, y2, z2 = p_doubling(x1, y1, z1)

# In kết quả ra màn hình
print("Kết quả phép nhân đôi điểm (Point Doubling):")
print(f"x2 = {hex(x2)}")
print(f"y2 = {hex(y2)}")
print(f"z2 = {hex(z2)}")