def modular_addition(a, b, modulus):
    return (a + b) % modulus

if __name__ == "__main__":
    a    = int("0x394d08c2da90b115cc97acc9dd0328484a210666575651ad8de7998d34a4b145", 16)  # Giá trị a có thể là số hex
    b    = int("0xd7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592", 16)  # Giá trị b có thể là số hex
    modulus  = int("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", 16)  # Giá trị modulus dưới dạng hex
    
    result = modular_addition(a, b, modulus)
    print("Ket qua (a + b) mod modulus:", hex(result))