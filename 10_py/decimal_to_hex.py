def decimalToHex(n):
    hex_str = hex(n & (2**256 - 1))[2:]  # Chuyển từ decimal sang hex, bỏ '0x'
    return hex_str.zfill(64)            # Padding để đủ 64 hex chars (tức là 256 bit)

# Ví dụ: nhập tọa độ dưới dạng số nguyên decimal
x_dec = 97545829917274378450420493068633403634366097923610927113640139683520194405778
y_dec = 32670510020758816978083085130507043184471273380659243275938904335757337482424
z_dec = 115792089237316195423570985008687907852837564279074904382605163141518161494337

# Chuyển sang hex
x_hex = decimalToHex(x_dec)
y_hex = decimalToHex(y_dec)
z_hex = decimalToHex(z_dec)

# In kết quả
print("x (hex):", x_hex)
print("y (hex):", y_hex)
print("z (hex):", z_hex)
