def modular_addition(a, b, modulus):
    return (a + b) % modulus

if __name__ == "__main__":
    a    = int("0xd7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592", 16)  # Giá trị a có thể là số hex
    b    = int("0x44dea1e38f252b5d0e0d9ddb5403dd2ea4fe6d89b66f551d4d81eeb73f08d08c", 16)  # Giá trị b có thể là số hex
    modulus  = int("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", 16)  # Giá trị modulus dưới dạng hex
    
    result = modular_addition(a, b, modulus)
    print("Ket qua (a + b) mod modulus:", hex(result))