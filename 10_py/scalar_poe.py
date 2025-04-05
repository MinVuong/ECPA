class ECPoint:
    def __init__(self, x, y, z, curve):
        self.x = x  # Tọa độ x
        self.y = y  # Tọa độ y
        self.z = z  # Tọa độ z
        self.curve = curve  # Đường cong elliptic

    def __add__(self, other):
        """Phép cộng hai điểm trong hệ Jacobian."""
        if self.z == 0:
            return other
        if other.z == 0:
            return self
        
        # Chuyển đổi các tọa độ sang hệ tọa độ đồng nhất
        u1 = self.x * (other.z ** 2) % self.curve.p
        u2 = other.x * (self.z ** 2) % self.curve.p
        s1 = self.y * (other.z ** 3) % self.curve.p
        s2 = other.y * (self.z ** 3) % self.curve.p

        # Tính toán các giá trị cần thiết
        h = (u2 - u1) % self.curve.p
        r = (s2 - s1) % self.curve.p

        if h == 0:
            if r == 0:
                return self.double()  # Nếu hai điểm giống nhau, nhân đôi điểm
            else:
                return ECPoint(0, 0, 0, self.curve)  # Điểm vô cùng

        # Tính toán các tọa độ mới
        h2 = (h ** 2) % self.curve.p
        h3 = (h * h2) % self.curve.p
        u1h2 = (u1 * h2) % self.curve.p
        x3 = (r ** 2 - h3 - 2 * u1h2) % self.curve.p
        y3 = (r * (u1h2 - x3) - s1 * h3) % self.curve.p
        z3 = (h * self.z * other.z) % self.curve.p

        return ECPoint(x3, y3, z3, self.curve)

    def double(self):
        """Nhân đôi điểm trong hệ Jacobian."""
        if self.z == 0:
            return self
        
        # Tính toán các giá trị cần thiết
        y2 = (self.y ** 2) % self.curve.p
        a = (self.x ** 2) % self.curve.p
        z2 = (self.z ** 2) % self.curve.p
        s = (2 * self.x * y2) % self.curve.p
        m = (3 * a + self.curve.a * z2 ** 2) % self.curve.p
        x3 = (m ** 2 - 2 * s) % self.curve.p
        y3 = (m * (s - x3) - 8 * y2 ** 2) % self.curve.p
        z3 = (2 * self.y * self.z) % self.curve.p

        return ECPoint(x3, y3, z3, self.curve)

    def __mul__(self, k):
        """Phép nhân vô hướng với điểm."""
        R0 = ECPoint(0, 0, 0, self.curve)  # Điểm vô cùng
        R1 = self  # Điểm ban đầu

        for bit in bin(k)[2:]:
            if bit == '0':
                R1 = R0 + R1
                R0 = R0.double()
            else:
                R0 = R0 + R1
                R1 = R1.double()

        return R0

class Secp256k1:
    def __init__(self):
        self.p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F  # Mô-đun
        self.a = 0  # Hệ số a
        self.b = 7  # Hệ số b
        self.G = ECPoint(
            x=0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
            y=0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8,
            z=1,
            curve=self
        )
        self.n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8D0364141  # Độ dài của nhóm

# Gán giá trị sẵn cho điểm và hệ số
x_input = 0x2230E9BB9A661A80FC7D9BEE960E53B6AA54C23FFE9937202F47331A75B968D7
y_input = 0x42F6683C0EF050B0370287BB2C87035978224601DA557C0FD1BBD34582ED19E7
z_input = 0x1  # Tọa độ z (số hex)
k = 0xd83715f87b79685cdc41927073554fa5d6ddc3d8e9327ee7ac9fc6a0eed765ed # Hệ số k (số hex)

curve = Secp256k1()  # Khởi tạo đường cong Secp256k1
P = ECPoint(x=x_input, y=y_input, z=z_input, curve=curve)  # Điểm trên đường cong

result = P * k  # Nhân điểm P với k
print(f"Kết quả: ({result.x:#x}, {result.y:#x}, {result.z:#x})")  # Xuất kết quả dưới dạng hex