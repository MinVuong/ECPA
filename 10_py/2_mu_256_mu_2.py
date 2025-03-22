import sys

def hex_mod_exp(base, exponent, modulus_hex):
    modulus = int(modulus_hex, 16)
    
    # Tính (base^exponent) mod modulus
    value = pow(base, exponent, modulus)
    
    # Tính bình phương của kết quả trên mod modulus
    result = pow(value, 2, modulus)
    
    return hex(result)

if __name__ == "__main__":
    base = 2  # Giá trị cơ số cố định
    exponent = 256  # Giá trị số mũ cố định
    modulus_hex = "0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed"  # Giá trị modulus cố định dưới dạng hex
    
    result = hex_mod_exp(base, exponent, modulus_hex)
    print("Ket qua (hex):", result)
# chươnng trìng đúng để chuyển R^2 mod modulus