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
a_hex = "0xF7E75FDC469067FFDC439B16B7D2F0FBA2F3B5A6ABF5A7E7CE0F05EDDA3C339B"
b_hex = "0xE5A3B45D7F29DCE6E89E3F08A7F68DAE8B771B75D7422F9A63FA9D423D51D6E9"
p_hex = "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF43"  # Số nguyên tố lớn

result_hex = modular_multiplication(a_hex, b_hex, p_hex)
print("Ketqua:", result_hex)