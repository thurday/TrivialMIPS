`include "cpu_defs.svh"

module id_ex(
	input  clk, rst,

	input  PipelineData_t id_data_a,
	input  PipelineData_t id_data_b,
	input  PipelineReq_t  id_req_a,
	input  PipelineReq_t  id_req_b,

	output PipelineData_t ex_data_a,
	output PipelineData_t ex_data_b,
	output PipelineReq_t  ex_req_a,
	output PipelineReq_t  ex_req_b,

	input  logic [7:0] id_interrupt_flag,
	output logic [7:0] ex_interrupt_flag,

	input  Bit_t      inst2_taken,
	input  Stall_t    stall,
	input  Bit_t      flush
);

`define RST_DATA_IDEX(d) \
	d.op   <= OP_NOP; \
	d.fpu_op <= FPU_OP_NOP; \
	d.pc   <= `ZERO_WORD; \
	d.inst <= `ZERO_WORD; \
	d.reg1 <= `ZERO_WORD; \
	d.reg2 <= `ZERO_WORD; \
	d.reg_addr1 <= 5'b0; \
	d.reg_addr2 <= 5'b0; \
	d.fpu_raddr1 <= 5'b0; \
	d.fpu_raddr2 <= 5'b0; \
	d.imm  <= `ZERO_WORD; \
	d.delayslot   <= 1'b0;

`define RST_REQ_IDEX(q) \
	q.reg_wr.we    <= 1'b0; \
	q.reg_wr.waddr <= 5'b0; \
	q.freg_wr.we    <= 1'b0;        \
	q.freg_wr.waddr <= `ZERO_WORD;  \
	q.freg_wr.wdata <= {$bits(FPUReg_t){1'b0}};  \
	q.fcsr_we       <= 1'b0;           \
	q.fcsr          <= `ZERO_WORD;     \
	q.except        <= {$bits(ExceptInfo_t){1'b0}};

always @(posedge clk)
begin
	if(rst || flush || (stall.stall_id && ~stall.stall_ex))
	begin
		`RST_DATA_IDEX(ex_data_a)
		`RST_DATA_IDEX(ex_data_b)
		`RST_REQ_IDEX(ex_req_a)
		`RST_REQ_IDEX(ex_req_b)
		ex_interrupt_flag  <= 8'b0;
	end else if(~stall.stall_id) begin
		ex_data_a <= id_data_a;
		ex_req_a  <= id_req_a;
		ex_interrupt_flag <= id_interrupt_flag;
		if(inst2_taken)
		begin
			ex_data_b <= id_data_b;
			ex_req_b  <= id_req_b;
		end else begin
			`RST_DATA_IDEX(ex_data_b)
			`RST_REQ_IDEX(ex_req_b)
		end
	end
end

endmodule
