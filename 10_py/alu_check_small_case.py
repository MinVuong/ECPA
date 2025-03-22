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
        result = (a - b + prime) % prime  # Đảm bảo không bị âm
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
        ("13", "07", "7F", 0b001),  # ADD
        ("2B", "11", "97", 0b010),  # SUB
        ("05", "03", "D3", 0b011),  # MULT
        ("01", "0F", "1D", 0b100),  # INV
        ("37", "23", "B5", 0b011),  # MULT
        ("01", "2D", "C1", 0b100),  # INV
        ("5F", "1B", "A3", 0b001),  # ADD
        ("61", "19", "B9", 0b010),  # SUB
        ("29", "17", "E7", 0b001),  # ADD
        ("41", "1D", "ED", 0b010),  # SUB
        ("07", "05", "F7", 0b011),  # MULT
        ("01", "13", "23", 0b100),  # INV
        ("67", "3F", "11B", 0b001),  # ADD
        ("53", "31", "13D", 0b010),  # SUB
        ("8F", "61", "17B", 0b011),  # MULT
        ("B3", "7D", "1C9", 0b001),  # ADD
        ("D7", "A1", "1E7", 0b010),  # SUB
        ("F5", "C3", "1F3", 0b011),  # MULT
        ("01", "E9", "1FD", 0b100),  # INV
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
output_python_file = "../00_src/output_python_small_case.txt"
process_testcases(output_python_file)
print(f"Results saved to {output_python_file}")
