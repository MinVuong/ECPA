1. ECPD v ECPA phải thực hiện đồng thời nếu kh đồng thời phải lưu R0 và R1 vào 1 thanh ghi nào trước vì nếu không lưu, giá trị bị cập nhật
--> tới ECPD sẽ bị sai kết quả
--> thêm X0_adding,X1_adding,Y0_adding,Y1_adding ...
2.
R_SQ_add_G bị final
--> có thể do bộ cộng
--> ecPa verilog khác ecpa python
đáp án cộng điểm còn lớn hơn p ?????
-->check lại bộ cộng modulo 
--->sai bộ trừ 1-0 mà nó lấy 1+p mới ra kết quả
--> hình như sai thuật toán

Algorithm 1 Left-to-right Montgomery ladder [52]
Input: P = (x, y), k = (1, kn−2, . . . , k1, k0)2
Output: Q = kP
1: R0 ← P; R1 ← 2P;
2: for i = n − 2 downto 0 do
3: if ki = 1 then
4: R0 ← R0 + R1; R1 ← 2R1
5: else
6: R1 ← R0 + R1; R0 ← 2R0
7: end if
8: end for
9: return Q = R0

3/4/2025
1. ECPD.sv lệch sv ECPD.py
