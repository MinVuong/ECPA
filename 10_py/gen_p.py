import random
from sympy import isprime

def random_prime_256bit():
    while True:
        num = random.getrandbits(256)  # Tạo số ngẫu nhiên 256-bit
        if isprime(num):  # Kiểm tra số nguyên tố
            return num

# Lấy 4 số nguyên tố 256-bit ngẫu nhiên và sắp xếp
random_primes = sorted([random_prime_256bit() for _ in range(4)])

# Chuyển về dạng hex
random_prime_hex = [hex(p).upper()[2:] for p in random_primes]
print(random_prime_hex)