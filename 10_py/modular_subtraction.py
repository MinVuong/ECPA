def modular_subtraction(a, b, modulus):
    return (a - b) % modulus

if __name__ == "__main__":
    a    = int("0x25738ad301228a1922c7d0cee9a6843be7143d0a0c752a58205de16744345b3e", 16)  # Giá trị a có thể là số hex
    b    = int("0xbc3a37694b6840274e30efe1d454f62b578ca8bc9917be05bd16b17d8e348984", 16)  # Giá trị b có thể là số hex
    modulus  = int("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F", 16)  # Giá trị modulus dưới dạng hex
    
    result = modular_subtraction(a, b, modulus)
    print("Ket qua (a - b) mod modulus:", hex(result))