import math
import random
import sys
p =0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
# Số nguyên tố p (modulo)
cons = 0 
def decimalToBinary(n):
    binary = bin(n & (2**256 - 1))[2:]  # Convert decimal to binary, truncate to 256 bits
    return binary.zfill(256)  # Pad with leading zeros to make it 256 bits long.
def p_doubling(xG,yG,zG):
    s = (((4*xG) % p)*((yG**2)%p)) % p
    t = (((yG**2) % p) * ((yG**2) % p)) % p
    pre = (((zG**2) % p) * ((zG**2) % p)) % p
    pre_1 = (cons * pre) % p
    m = (((3*(xG**2)%p) % p) + (pre_1)) % p
    x2= ((m**2)%p - (2*s)%p) % p
    y2= (((m*(s-x2))%p)%p - (8*t)%p) % p
    z2= (2*((yG*zG) %p)) % p
    return (x2,y2,z2)

def p_adding(x1,y1,z1,x2,y2,z2):
    u1 = (x1 * (z2**2 % p)) %p
    u2 = (x2 * (z1**2 % p)) %p
    h = (u1 - u2) %p
    s2 = (y2 * (((z1**2 % p) * z1) %p)) %p
    s1 = (y1 * (((z2**2 % p) * z2) %p)) %p
    v = (u1 * (h**2 % p )) %p
    g = ((h**2 %p) * h) %p
    r = (s1 - s2) %p
    x3 = (((r**2 %p + g) %p) - (2*v %p)) %p
    y3 = (((r * (((v - x3) %p)) %p) )) %p # moi bo - ((s1 * g) %p)
    z3 = (((z1 * z2) %p) * h) %p
    return (x3,y3,z3)
def scalar_mul(n, xG, yG, zG):
    G = [xG, yG, zG]
    arr_k = []
    k = decimalToBinary(n)
    for c in k:
        arr_k.append(c)  # Thụt lề đúng cách
    [x0, y0, z0] = [xG, yG, zG]
    [x1, y1, z1] = p_doubling(xG, yG, zG)

    # Mở tệp để ghi kết quả
    with open("output.txt", "w") as f:
        f.write(f"Initial values:\n")
        f.write(f"x0: {hex(x0)[2:].zfill(64)}, y0: {hex(y0)[2:].zfill(64)}, z0: {hex(z0)[2:].zfill(64)}\n")
        f.write(f"x1: {hex(x1)[2:].zfill(64)}, y1: {hex(y1)[2:].zfill(64)}, z1: {hex(z1)[2:].zfill(64)}\n")

        for i in range(1, len(arr_k)):
            f.write(f"\nStage {255 - i}: Processing bit {arr_k[i]} (bit index {255 - i})\n")
            if arr_k[i] == "1":
                [x0, y0, z0] = p_adding(x0, y0, z0, x1, y1, z1)
                [x1, y1, z1] = p_doubling(x1, y1, z1)
            elif arr_k[i] == "0":
                [x1, y1, z1] = p_adding(x0, y0, z0, x1, y1, z1)
                [x0, y0, z0] = p_doubling(x0, y0, z0)

            f.write(f"x0: {hex(x0)[2:].zfill(64)}, y0: {hex(y0)[2:].zfill(64)}, z0: {hex(z0)[2:].zfill(64)}\n")
            f.write(f"x1: {hex(x1)[2:].zfill(64)}, y1: {hex(y1)[2:].zfill(64)}, z1: {hex(z1)[2:].zfill(64)}\n")

    return (x0, y0, z0)

if __name__ == "__main__":
    # Giá trị đầu vào
    scalar = 0x43F86641A085AF50C1293D806FBFC66FF4FA3EFC54F91FEBB8A87F6A379DF8CF # Thay bằng giá trị scalar mong muốn
   


# Điểm cơ sở G (tọa độ Affine)
    xG = 0x981862A18D2F3391A5BD8ACB7DB6CE5EEEDBC2E38DF59600C6EC94DBB4A2D55B
    yG = 0xA82576ADB5EA5015343D863C9AA585FF8AD2B4FDF9D7A703F0CB6F69C92513C3
    zG = 0x0000000000000000000000000000000000000000000000000000000000000001


    # Gọi hàm scalar_mul
    x_result, y_result, z_result = scalar_mul(scalar, xG, yG, zG)

    # Xuất kết quả dưới dạng số hex 256-bit
    print("Kết quả của Scalar Multiplication đã được lưu vào tệp output.txt")
    print(f"X: {hex(x_result)[2:].zfill(64)}")  # Định dạng thành 256-bit hex
    print(f"Y: {hex(y_result)[2:].zfill(64)}")  # Định dạng thành 256-bit hex
    print(f"Z: {hex(z_result)[2:].zfill(64)}")  # Định dạng thành 256-bit hex