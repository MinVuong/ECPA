def decimalToBinary(n):
    return bin(n)[2:]  # Chuyển số nguyên thành chuỗi nhị phân (loại bỏ '0b')

def p_doubling(xG, yG, zG, p, cons):
    s = (((4 * xG) % p) * ((yG ** 2) % p)) % p
    t = (((yG ** 2) % p) * ((yG ** 2) % p)) % p
    pre = (((zG ** 2) % p) * ((zG ** 2) % p)) % p
    pre_1 = (cons * pre) % p
    m = (((3 * (xG ** 2) % p) % p) + pre_1) % p
    x2 = ((m ** 2) % p - (2 * s) % p) % p
    y2 = (((m * (s - x2)) % p) % p - (8 * t) % p) % p
    z2 = (2 * ((yG * zG) % p)) % p
    return (x2, y2, z2)

def p_adding(x1, y1, z1, x2, y2, z2, p):
    u1 = (x1 * (z2 ** 2 % p)) % p
    u2 = (x2 * (z1 ** 2 % p)) % p
    h = (u1 - u2) % p
    s2 = (y2 * (((z1 ** 2 % p) * z1) % p)) % p
    s1 = (y1 * (((z2 ** 2 % p) * z2) % p)) % p
    v = (u1 * (h ** 2 % p)) % p
    g = ((h ** 2 % p) * h) % p
    r = (s1 - s2) % p
    x3 = (((r ** 2 % p + g) % p) - (2 * v % p)) % p
    y3 = (((r * ((v - x3) % p)) % p) - ((s1 * g) % p)) % p
    z3 = (((z1 * z2) % p) * h) % p
    return (x3, y3, z3)

def scalar_mul(n, xG, yG, zG, p, cons):
    k = decimalToBinary(n)
    x0, y0, z0 = xG, yG, zG
    x1, y1, z1 = p_doubling(xG, yG, zG, p, cons)

    for i in range(1, len(k)):
        if k[i] == "1":
            x0, y0, z0 = p_adding(x0, y0, z0, x1, y1, z1, p)
            x1, y1, z1 = p_doubling(x1, y1, z1, p, cons)
        else:
            x1, y1, z1 = p_adding(x0, y0, z0, x1, y1, z1, p)
            x0, y0, z0 = p_doubling(x0, y0, z0, p, cons)

    return x0, y0, z0
