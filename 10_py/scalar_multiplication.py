import ecdsa
from ecdsa import SECP256k1
from ecdsa.ellipticcurve import Point

# Định nghĩa hệ số nhân k (dạng hex)
k_hex = "3E9F128209B8F412C2874E2F6656446BE30138B748B9E18401EE9BABC5CE923F"
k = int(k_hex, 16)  # Chuyển từ hex sang int

# Lấy đường cong secp256k1 và điểm cơ sở G
curve = SECP256k1.curve
G = SECP256k1.generator

# Thực hiện phép nhân scalar: Q = k * G
Q = k * G

# Lấy tọa độ x, y của điểm Q
x_Q = Q.x()
y_Q = Q.y()

# In kết quả
print("Điểm cơ sở G:")
print(f"x = {hex(G.x())[2:].zfill(64)}")
print(f"y = {hex(G.y())[2:].zfill(64)}")
print("\nHệ số nhân k:")
print(f"k = {hex(k)[2:].zfill(64)}")
print("\nKết quả Q = k * G:")
print(f"x_Q = {hex(x_Q)[2:].zfill(64)}")
print(f"y_Q = {hex(y_Q)[2:].zfill(64)}")