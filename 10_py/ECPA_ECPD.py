from ecdsa import SECP256k1
from ecdsa.ellipticcurve import Point

# SECP256k1 curve parameters
curve = SECP256k1.curve

# Define two points using hexadecimal coordinates
# Example points (you can change these to any valid points on the curve)
point1_x = int("79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798", 16)  # Example: x-coordinate of G
point1_y = int("483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8", 16)  # Example: y-coordinate of G
point2_x = int("79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798", 16)  # Example: x-coordinate of G
point2_y = int("483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8", 16)  # Example: y-coordinate of G

# Create Point objects
point1 = Point(curve, point1_x, point1_y)
point2 = Point(curve, point2_x, point2_y)

# Add the two points
result_point = point1 + point2

# Print the affine coordinates of the resulting point in hex
print(hex(result_point.x()), hex(result_point.y()))