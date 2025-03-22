import os

def mod_inv(b, prime):
    """Tính nghịch đảo modulo: b^-1 mod prime (Sử dụng thuật toán Euclid mở rộng)"""
    if b == 0:
        raise ValueError("Không thể tính nghịch đảo của 0")
    
    x0, x1, p = 0, 1, prime
    while b > 1:
        q = b // prime
        b, prime = prime, b % prime
        x0, x1 = x1 - q * x0, x0
    
    return x1 + p if x1 < 0 else x1  # Đảm bảo kết quả dương

def alu_compute(a, b, prime, alu_sel):
    """Mô phỏng hoạt động của ALU"""
    a, b, prime = int(a, 16), int(b, 16), int(prime, 16)  # Chuyển từ hex sang số nguyên

    if alu_sel == 0b001:  # ADD: (a + b) mod prime
        result = (a + b) % prime
    elif alu_sel == 0b010:  # SUB: (a - b) mod prime
        result = (a - b) % prime
    elif alu_sel == 0b011:  # MULT: (a * b) mod prime
        result = (a * b) % prime
    elif alu_sel == 0b100:  # INV: (b^-1) mod prime
        result = mod_inv(b, prime)
    else:
        raise ValueError(f"Không hỗ trợ alu_sel = {alu_sel}")

    return result

def process_testcases(output_path):
    """Chạy các test case và ghi kết quả vào file"""
    testcases = [
        ("23", "19", "7F", 0b001),  # ADD
        ("5A", "3C", "7F", 0b010),  # SUB
        ("5", "7", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5", 0b011),  # MULT
        ("1", "3", "7", 0b100),  # INV
        ("F1234567890AB", "ABCDE1234567", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5", 0b011),  # MULT
        ("1", "A1B2C3D4E5F60", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5", 0b100),  # INV
        ("FFFFFFFFFFFFE1", "E", "FFFFFFFFFFFFF7", 0b001),  # ADD
        ("FFFFFFFFFFFFDA", "123456789ABCD", "FFFFFFFFFFFFEF", 0b010),  # SUB
        ("37", "19", "A7", 0b001),  # ADD
        ("89", "45", "C1", 0b010),  # SUB
        ("C", "9", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5", 0b011),  # MULT
        ("1", "B", "1F", 0b100),  # INV
        ("59A3B", "7C2D", "FFFFFFFFFFFFFD", 0b001),  # ADD
        ("29D1", "53C7", "FFFFFFFFFFFFF1", 0b010),  # SUB
        ("ABCDE", "12345", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5", 0b011),  # MULT
        ("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5", 0b001),  # ADD
        ("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5", 0b010),  # SUB
        ("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5", 0b011),  # MULT
        ("1", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5", 0b100),  # INV
    ]

    with open(output_path, "w") as f:
        for i, (a, b, prime, alu_sel) in enumerate(testcases, start=1):
            result = alu_compute(a, b, prime, alu_sel)
            f.write(f"Testcase {i}:\n")
            f.write(f"alu_sel = {alu_sel:03b}\n")
            f.write(f"a = {int(a,16):064X}\n")
            f.write(f"b = {int(b,16):064X}\n")
            f.write(f"prime = {int(prime,16):064X}\n")
            f.write(f"Result: {result:064X}\n\n")

# Chạy chương trình
output_python_file = "../00_src/output_alu_py.txt"

# Tạo thư mục nếu chưa có
#os.makedirs(os.path.dirname(output_python_file), exist_ok=True)

process_testcases(output_python_file)
print(f"Results saved to {output_python_file}")
