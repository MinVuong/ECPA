def modular_multiplication(a, b, m):
    # Chuyển đổi a và b thành kiểu số nguyên
    a = int(a)  # Đã là số nguyên, không cần chuyển đổi từ hex
    b = int(b)
    m = int(m)

    # Khởi tạo các biến
    u = a
    s = 0

    # Thực hiện thuật toán
    for cnt in range(257):  # Kiểm tra từng bit trong 257 bit
        # Kiểm tra bit hiện tại của b
        if (b >> cnt) & 1:  # Nếu bit cnt của b là 1
            s = (s + u) % m  # Cập nhật s

        # Nhân đôi u
        u = (u * 2) % m  # 2u

        # Kiểm tra nếu u >= m
        if u >= m:
            u -= m  # 2u - m

    return s

# Giá trị a, b, m
# a = 2^256, b = 2^256, m = 419 (257-bit input, giá trị nhỏ hơn 2^257)
a = 797
b = 13
m = 419

# Đảm bảo a và b nhỏ hơn m (không cần kiểm tra vì bài toán đã đảm bảo điều kiện này)


# Tính toán p
p = modular_multiplication(a, b, m)

# Hiển thị kết quả
print(f"p = {a} * {b} mod {m} = {p}")
