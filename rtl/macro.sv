`ifndef MACRO_SV
`define MACRO_SV

`define OP_NOP   4'b0000 // 空操作
`define OP_ADD   4'b0001 // 加法
`define OP_SUB   4'b0010 // 减法
`define OP_AND   4'b0011 // 与
`define OP_INC   4'b0100 // 加一
`define OP_LD    4'b0101 // 从内存加载
`define OP_ST    4'b0110 // 存储到内存
`define OP_JC    4'b0111 // 进位跳转
`define OP_JZ    4'b1000 // 零跳转
`define OP_JMP   4'b1001 // 无条件跳转
`define OP_OUT   4'b1010 // 输出，不带暂停
`define OP_NOT   4'b1011 // 非
`define OP_MOV   4'b1100 // 移动
`define OP_IN    4'b1101 // 输入，不带暂停
`define OP_STP   4'b1110 // 停止
`define OP_CMP   4'b1111 // 比较

`define MODE_FETCH_EXEC 3'b000 // 取指执行
`define MODE_WRITE_MEM  3'b001 // 写存储器
`define MODE_READ_MEM   3'b010 // 读存储器
`define MODE_READ_REG   3'b011 // 读寄存器
`define MODE_WRITE_REG  3'b100 // 写寄存器

`endif
