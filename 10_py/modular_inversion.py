def inver(b, a, m):
    """
    Compute c = b * a^(-1) mod m using the extended Euclidean algorithm.
    
    Parameters:
        b (int): Multiplicand.
        a (int): Inverse of this number is calculated.
        m (int): Modulus.

    Returns:
        int: Result of the modular inversion.
    """
    if a == 0 or m <= 1:
        raise ValueError("Invalid inputs for modular inversion.")

    u, v = a, m
    x, y = b, 0

    while u != 1 and v != 1:
        # Reduce u while it's even
        while u % 2 == 0:
            u //= 2
            if x % 2 == 0:
                x //= 2
            else:
                x = (x + m) // 2

        # Reduce v while it's even
        while v % 2 == 0:
            v //= 2
            if y % 2 == 0:
                y //= 2
            else:
                y = (y + m) // 2

        # Update u, v, x, y based on comparison of u and v
        if u >= v:
            u -= v
            x -= y
        else:
            v -= u
            y -= x

    # Determine result based on whether u or v reached 1
    if u == 1:
        result = x
    else:
        result = y

    # Ensure result is in the range [0, m)
    if result < 0:
        result += m

    return result % m


# Test the function with hardcoded hex inputs
if __name__ == "__main__":
    # Gán cứng các giá trị đầu vào dưới dạng số hex
    a = 0xc845b856e0b321b35f8bc66d89cc34287f80ebe5355dbcd6bf16f55f76c628bf # Multiplicand
    b = 0xa3093da7fa407a51419601979dafe343b67c3e195b5f72c4079423b57d413c8d # Inverse of this number is calculated
    m = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141  # Modulus

    try:
        # Tính toán
        c = inver(b, a, m)

        # Xuất kết quả dưới dạng hex
        print(f"Kết quả của {hex(b)} * {hex(a)}^(-1) mod {hex(m)} là: {hex(c)[2:].zfill(64)}")
    except ValueError as e:
        print(f"Lỗi: {e}")