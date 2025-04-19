def modular_subtraction(a, b, modulus):
    return (a - b) % modulus

if __name__ == "__main__":
   a    = int("0x123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0", 16)  # Giá trị a có thể là số hex
   b    = int("0xFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210", 16)  # Giá trị b có thể là số hex
   modulus  = int("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F", 16)  # Giá trị modulus dưới dạng hex
    
   result = modular_subtraction(a, b, modulus)
   print("Ket qua (a - b) mod modulus:", hex(result))