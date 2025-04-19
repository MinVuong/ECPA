def jacobian_to_affine(x_j, y_j, z_j, p):
    """
    Convert a point from Jacobian coordinates (x_j, y_j, z_j) to Affine coordinates (x_a, y_a)
    for ECDSA over a prime field with modulus p.
    
    Args:
        x_j: x-coordinate in Jacobian form
        y_j: y-coordinate in Jacobian form
        z_j: z-coordinate in Jacobian form
        p: Prime modulus of the finite field
    
    Returns:
        tuple: (x_a, y_a) in Affine coordinates, or None if z_j is 0
    """
    if z_j == 0:
        return None  # Point at infinity or invalid
    
    # Compute z^(-1) mod p using Fermat's little theorem: z^(-1) = z^(p-2) mod p
    z_inv = pow(z_j, p - 2, p)
    
    # x_a = x_j * (z^(-1))^2 mod p
    x_a = (x_j * (z_inv * z_inv)) % p
    
    # y_a = y_j * (z^(-1))^3 mod p
    y_a = (y_j * (z_inv * z_inv * z_inv)) % p
    
    return (x_a, y_a)

# Example usage
if __name__ == "__main__":
    # Example parameters (secp256k1 curve)
    p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
    
    # Sample Jacobian point (x_j, y_j, z_j)
    x_j = 0x62FF48001431D09BC235E4DC04CC5CA2A71B5D52CE1A65E386F00A1E41C7EE7
    y_j = 0x34A50BEA68919A46575EB50C1475BB743B43773B805762428465B2DBE4481A2B
    z_j = 0x83DE73BF7CE8E1F43ECF69964FAB91FC5FA9BAB75E2023F50727E4C69C736B03
    
    result = jacobian_to_affine(x_j, y_j, z_j, p)
    if result:
        x_a, y_a = result
        print(f"Affine coordinates: x_a = {hex(x_a)}, y_a = {hex(y_a)}")
    else:
        print("Point at infinity or invalid")