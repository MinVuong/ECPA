import math

def modular_add(a, b, prime):
    return (a + b) % prime

def modular_sub(a, b, prime):
    return (a - b) % prime

def modular_mult(a, b, prime):
    return (a * b) % prime

def modular_inv(a, prime):
    if math.gcd(a, prime) != 1:
        raise ValueError("Inverse does not exist")
    return pow(a, -1, prime)

def main():
    testcases = [
        ("ADD", 0x23, 0x19, 0x7F),
        ("SUB", 0x5A, 0x3C, 0x7F),
        ("MULT", 0x5, 0x7, 0xD),
        ("INV", 0x3, None, 0x7),
        ("MULT", 0xF1234567890ABCDEF1234567890ABCDE, 0xABCDE1234567890F1234567890ABCDE1, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF61),
        ("INV", 0xA1B2C3D4E5F60718293A4B5C6D7E8F90, None, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB3),
        ("ADD", 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1, 0xE, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB3),
        ("SUB", 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE, 0x123456789ABCDEF0123456789ABCDEF0, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB3)
    ]
    
    for op, a, b, prime in testcases:
        try:
            if op == "ADD":
                result = modular_add(a, b, prime)
            elif op == "SUB":
                result = modular_sub(a, b, prime)
            elif op == "MULT":
                result = modular_mult(a, b, prime)
            elif op == "INV":
                result = modular_inv(a, prime)
            else:
                continue
            
            print(f"{op}: a = {hex(a)}, b = {hex(b) if b is not None else 'N/A'}, prime = {hex(prime)} => Result = {hex(result)}")
        except ValueError as e:
            print(f"{op}: a = {hex(a)}, prime = {hex(prime)} => Error: {e}")

if __name__ == "__main__":
    main()
