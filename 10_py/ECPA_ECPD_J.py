from ecdsa import SECP256k1
from ecdsa.ellipticcurve import Point

# SECP256k1 curve parameters
curve = SECP256k1.curve
p = curve.p()  # Prime modulus of the finite field

# Function to convert Jacobian to Affine coordinates
def jacobian_to_affine(x_j, y_j, z_j):
    if z_j == 0:
        raise ValueError("Invalid point: Z coordinate is zero")
    z_inv = pow(z_j, -1, p)  # Modular inverse of Z
    z_inv_sq = (z_inv * z_inv) % p  # Z^-2
    x_a = (x_j * z_inv_sq) % p  # x = X / Z^2
    z_inv_cube = (z_inv_sq * z_inv) % p  # Z^-3
    y_a = (y_j * z_inv_cube) % p  # y = Y / Z^3
    return x_a, y_a

# Function to convert Affine to Jacobian coordinates
def affine_to_jacobian(x_a, y_a, z=1):
    x_j = (x_a * z * z) % p  # X = x * Z^2
    y_j = (y_a * z * z * z) % p  # Y = y * Z^3
    z_j = z % p  # Z
    return x_j, y_j, z_j

# Input: Jacobian coordinates for two points (example points)
# Point 1 (X1, Y1, Z1) - Using G's Affine coordinates converted to Jacobian
point1_x_j = int("e9cb21aec1679b6f6f2a847bf473d65d26e904335c18e4bfefd52ed5aeec36ff", 16)  # X = x
point1_y_j = int("2b0d925eb5c54dc5cc76c0729079551031a686fcc7c350659de3dad85e56b8d0", 16)  # Y = y
point1_z_j = int("433d230bf66fdb0046115aae771ce032b037a823612cec636107814d83907982", 16)

# Point 2 (X2, Y2, Z2) - Using G's Affine coordinates converted to Jacobian
point2_x_j = int("b86fd6b80ab0685a810a932298e80ab9e3c65c715b9c121af9f5730639d76fdc", 16)  # X = x
point2_y_j = int("4b8c3c9f5e50232496caa9f3aa682b9091a5755977e0717e38bcd91c59d041b2", 16)  # Y = y
point2_z_j = int("f7d03c2832df6c93871fc86c2e27ab6c02ebdee34c7529cca318dea124ca6b0b", 16)  # Z = 1 (simple case)

# Convert Jacobian to Affine for both points
point1_x_a, point1_y_a = jacobian_to_affine(point1_x_j, point1_y_j, point1_z_j)
point2_x_a, point2_y_a = jacobian_to_affine(point2_x_j, point2_y_j, point2_z_j)

# Create Point objects using Affine coordinates
point1 = Point(curve, point1_x_a, point1_y_a)
point2 = Point(curve, point2_x_a, point2_y_a)

# Add the two points
result_point = point1 + point2

# Get Affine coordinates of the result
result_x_a = result_point.x()
result_y_a = result_point.y()

# Convert result to Jacobian coordinates (using Z=1 for simplicity)
result_x_j, result_y_j, result_z_j = affine_to_jacobian(result_x_a, result_y_a, z=1)

# Print results
print("Result in Affine coordinates:")
print(f"x: {hex(result_x_a)}")
print(f"y: {hex(result_y_a)}")
print("\nResult in Jacobian coordinates:")
print(f"X: {hex(result_x_j)}")
print(f"Y: {hex(result_y_j)}")
print(f"Z: {hex(result_z_j)}")