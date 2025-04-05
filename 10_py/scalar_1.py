class Point:
    def __init__(self, x: int, y: int, z: int, p: int):
        self.x = x
        self.y = y
        self.z = z
        self.p = p  # Modulo P for the elliptic curve

    # Nhân điểm với scalar
    def __rmul__(self, scalar: int) -> "Point":
        current = self
        result = Point(0, 1, 0, self.p)  # Identity point in Jacobian coordinates (x=0, y=1, z=0)
        while scalar:
            if scalar & 1:
                result = result + current  # Trong trường hợp này bạn cần định nghĩa phép cộng trong không gian Jacobian
            current = current + current  # Point doubling
            scalar >>= 1
        return result

# Hàm chính với input sẵn
def main():
    # Các giá trị input đã được định sẵn dưới dạng hex
    x = 0x4b82bf5f6655ac6be5f66fc070f0f31838cb375027040d0ab1b5680c84f43127  # Tọa độ x của điểm
    y = 0x01c08b7d0e94c0dcb7defda9224f53e61e47fe20ad2420a71de13d393f2b9399  # Tọa độ y của điểm
    z = 0x1  # Tọa độ z của điểm
    p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f  # Số nguyên tố p (modulo)
    scalar = 0xd83715f87b79685cdc41927073554fa5d6ddc3d8e9327ee7ac9fc6a0eed765ed  # Hệ số nhân scalar
    
    # Khởi tạo điểm và thực hiện phép nhân vô hướng
    point = Point(x, y, z, p)
    result = scalar * point  # Sử dụng __rmul__ để thực hiện phép nhân vô hướng
    
    # In kết quả ra dưới dạng hex
    print(f"KQ: ({hex(result.x)}, {hex(result.y)}, {hex(result.z)})")

if __name__ == "__main__":
    main()
