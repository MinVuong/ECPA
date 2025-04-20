def modular_multiplication(a_hex, b_hex, p_hex):
    # Chuyển đổi từ hex sang số nguyên
    a = int(a_hex, 16)
    b = int(b_hex, 16)
    p = int(p_hex, 16)
    
    # Tính toán modular multiplication
    result = (a * b) % p
    
    # Chuyển kết quả về dạng hex
    return hex(result)

# Ví dụ
a_hex = "0x545e999a89efad89bf4bfe6d4021e019cda465fb28bbd36e05be5ca2f146238"
b_hex = "0x3E9F128209B8F412C2874E2F6656446BE30138B748B9E18401EE9BABC5CE923F"
p_hex = "0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141"  # Số nguyên tố lớn

result_hex = modular_multiplication(a_hex, b_hex, p_hex)
print("Ketqua:", result_hex)