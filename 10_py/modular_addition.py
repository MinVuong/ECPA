def modular_addition(a, b, modulus):
    return (a + b) % modulus

if __name__ == "__main__":
    a = int("0x00000000000000000000000000000000fffffffffffffffffffffffffffffff1", 16)  # Giá trị a có thể là số hex
    b = int("0x000000000000000000000000000000000000000000000000000000000000000e", 16)  # Giá trị b có thể là số hex
    modulus = int("0x000000000000000000000000000000000000000000000000fffffffefffffc2f", 16)  # Giá trị modulus dưới dạng hex
    
    result = modular_addition(a, b, modulus)
    print("Ket qua (a + b) mod modulus:", hex(result))