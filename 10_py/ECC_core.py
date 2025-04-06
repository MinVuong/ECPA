from sympy import mod_inverse

def ecc_core_operation(a, b, prime, alu_sel):
    """
    Thực hiện các phép toán ECC tương tự như ECC_core.
    :param a: Số nguyên đầu vào a (256-bit)
    :param b: Số nguyên đầu vào b (256-bit)
    :param prime: Số nguyên tố prime (256-bit)
    :param alu_sel: Lựa chọn phép toán (3-bit)
    :return: Kết quả của phép toán
    """
    if alu_sel == 0b001:  # ADD
        return (a + b) % prime
    elif alu_sel == 0b010:  # SUB
        return (a - b) % prime
    elif alu_sel == 0b011:  # MULT
        return (a * b) % prime
    elif alu_sel == 0b100:  # INV
        return mod_inverse(b, prime)  # Tính nghịch đảo modular của b mod prime
    else:
        raise ValueError("Invalid ALU selection")

def main():
    # Danh sách các test case
    test_cases = [
        {"a": 0x23, "b": 0x19, "prime": 0x7F, "alu_sel": 0b001},  # ADD
        {"a": 0x5A, "b": 0x3C, "prime": 0x7F, "alu_sel": 0b010},  # SUB
        {"a": 0x5, "b": 0x7, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "alu_sel": 0b011},  # MULT
        {"a": 0x1, "b": 0x3, "prime": 0x7, "alu_sel": 0b100},  # INV
        {"a": 0xF1234567890AB, "b": 0xABCDE1234567, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "alu_sel": 0b011},  # MULT
        {"a": 0x1, "b": 0xA1B2C3D4E5F60, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "alu_sel": 0b100},  # INV
        {"a": 0xFFFFFFFFFFFFE1, "b": 0xE, "prime": 0xFFFFFFFFFFFFF7, "alu_sel": 0b001},  # ADD
        {"a": 0xFFFFFFFFFFFFDA, "b": 0x123456789ABCD, "prime": 0xFFFFFFFFFFFFEF, "alu_sel": 0b010},  # SUB
        {"a": 0x37, "b": 0x19, "prime": 0xA7, "alu_sel": 0b001},  # ADD
        {"a": 0x89, "b": 0x45, "prime": 0xC1, "alu_sel": 0b010},  # SUB
        {"a": 0xC, "b": 0x9, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "alu_sel": 0b011},  # MULT
        {"a": 0x1, "b": 0xB, "prime": 0x1F, "alu_sel": 0b100},  # INV
        {"a": 0x59A3B, "b": 0x7C2D, "prime": 0xFFFFFFFFFFFFFD, "alu_sel": 0b001},  # ADD
        {"a": 0x29D1, "b": 0x53C7, "prime": 0xFFFFFFFFFFFFF1, "alu_sel": 0b010},  # SUB
        {"a": 0xABCDE, "b": 0x12345, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "alu_sel": 0b011},  # MULT
        {"a": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE, "b": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "alu_sel": 0b001},  # ADD
        {"a": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC, "b": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "alu_sel": 0b010},  # SUB
        {"a": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8, "b": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "alu_sel": 0b011},  # MULT
        {"a": 0x1, "b": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "alu_sel": 0b100},  # INV
    ]

    # Kiểm tra từng test case
    for i, test in enumerate(test_cases, start=1):
        a = test["a"]
        b = test["b"]
        prime = test["prime"]
        alu_sel = test["alu_sel"]

        try:
            result = ecc_core_operation(a, b, prime, alu_sel)
            print(f"Testcase {i}:")
            print(f"  ALU_SEL = {bin(alu_sel)}")
            print(f"  A = {hex(a)}")
            print(f"  B = {hex(b)}")
            print(f"  PRIME = {hex(prime)}")
            print(f"  RESULT = {hex(result)}\n")
        except Exception as e:
            print(f"Testcase {i} failed with error: {e}\n")

if __name__ == "__main__":
    main()