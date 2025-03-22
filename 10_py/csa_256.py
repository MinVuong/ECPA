def csa256csa256(a, b, c):
    # Tính toán tổng và carry cho từng cặp
    sum_ab = a ^ b  # Phép XOR cho tổng
    carry_ab = a & b  # Phép AND cho carry

    # Tính toán tổng và carry giữa sum_ab và c
    sum_abc = sum_ab ^ c  # Phép XOR cho tổng
    carry_abc = carry_ab | (sum_ab & c)  # Phép OR cho carry

    # Tính tổng cuối cùng
    final_sum = sum_abc + (carry_abc << 1)  # Chuyển carry sang trái 1 bit

    # Tính carry out
    cout = 1 if final_sum >= (1 << 256) else 0

    return final_sum % (1 << 256), cout  # Trả về tổng cuối cùng và carry out

# Chuyển đổi từ hex sang int
a = int("1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF", 16)
b = int("FEDCBA0987654321FEDCBA0987654321FEDCBA0987654321FEDCBA0987654321", 16)
c = int("1111111111111111111111111111111100000000000000000000000000000000", 16)

# Tính toán
result, carry_out = csa256csa256(a, b, c)

# In kết quả
print(f"Ket qua: {result:064X}")  # In kết quả dưới dạng hex 256-bit
print(f"Carry out: {carry_out}")  # In carry out