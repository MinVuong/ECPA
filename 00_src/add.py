def add(a_hex, b_hex, p_hex):
    # Chuyển đổi giá trị hex sang số nguyên
    a = int(a_hex, 16)
    b = int(b_hex, 16)
    p = int(p_hex, 16)
    
    # Tính tổng
    sum_ab = a + b
    
    # Tính kết quả với modulo
    if sum_ab >= p:
        result_add = sum_ab - p
    else:
        result_add = sum_ab

    # In giá trị trung gian sum_ab
    print("Tong (sum_ab):", hex(sum_ab)[2:].zfill(64))

    # Trả về kết quả dạng hex
    return hex(result_add)[2:].zfill(64)

if __name__ == "__main__":
    # Gán giá trị mặc định
    a_hex = "0x456789abcdef0123456789abcdef0123456789abcdef0"
    b_hex = "0x888888888888888888888888888888888888888888888"
    p_hex = "0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadb"

    # Tính kết quả
    result = add(a_hex, b_hex, p_hex)
    print("Ket qua (result_add):", result)