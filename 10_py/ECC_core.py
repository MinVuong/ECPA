from sympy import mod_inverse

def ecc_core_operation(a, b, prime, n, ecc_sel):
    """
    Thực hiện các phép toán ECC tương tự như ECC_core.
    :param a: Số nguyên đầu vào a (256-bit)
    :param b: Số nguyên đầu vào b (256-bit)
    :param prime: Số nguyên tố prime (256-bit)
    :param n: Giá trị n (256-bit)
    :param ecc_sel: Lựa chọn phép toán (3-bit)
    :return: Kết quả của phép toán
    """
    # Chọn giá trị p_or_n dựa trên ecc_sel[0]
    if ecc_sel & 0b001:  # ecc_sel[0] = 1
        p_or_n = n
    else:  # ecc_sel[0] = 0
        p_or_n = prime

    # Thực hiện phép toán dựa trên ecc_sel[2:1]
    if ecc_sel >> 1 == 0b00:  # ADD
        return (a + b) % p_or_n
    elif ecc_sel >> 1 == 0b01:  # SUB
        return (a - b) % p_or_n
    elif ecc_sel >> 1 == 0b10:  # MULT
        return (a * b) % p_or_n
    elif ecc_sel >> 1 == 0b11:  # INV
        return mod_inverse(b, p_or_n)  # Tính nghịch đảo modular của b mod p_or_n
    else:
        raise ValueError("Invalid ECC selection")

def main():
    # Danh sách các test case
    test_cases = [
        {"a": 0x23, "b": 0x19, "prime": 0x7F, "n": 0xFF45, "ecc_sel": 0b001},  # ADD với p_or_n = n
        {"a": 0x5A, "b": 0x3C, "prime": 0x7F, "n": 0xFF45, "ecc_sel": 0b010},  # SUB với p_or_n = prime
        {"a": 0x5, "b": 0x7, "prime": 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5, "n": 0xFF45, "ecc_sel": 0b011},  # MULT với p_or_n = prime
        {"a": 0x1, "b": 0x3, "prime": 0x7, "n": 0xFF45, "ecc_sel": 0b100},  # INV với p_or_n = prime
    ]

    # Kiểm tra từng test case
    for i, test in enumerate(test_cases, start=1):
        a = test["a"]
        b = test["b"]
        prime = test["prime"]
        n = test["n"]
        ecc_sel = test["ecc_sel"]

        try:
            result = ecc_core_operation(a, b, prime, n, ecc_sel)
            print(f"Testcase {i}:")
            print(f"  ECC_SEL = {bin(ecc_sel)}")
            print(f"  A = {hex(a)}")
            print(f"  B = {hex(b)}")
            print(f"  PRIME = {hex(prime)}")
            print(f"  N = {hex(n)}")
            print(f"  RESULT = {hex(result)}\n")
        except Exception as e:
            print(f"Testcase {i} failed with error: {e}\n")

if __name__ == "__main__":
    main()