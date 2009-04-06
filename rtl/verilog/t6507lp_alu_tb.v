`include "timescale.v"
module t6507lp_alu_tb;

`include  "t6507lp_package.v"

reg         clk;
reg         reset_n;
reg         alu_enable;
wire [7:0]  alu_result;
wire [7:0]  alu_status;
reg  [7:0]  alu_opcode;
reg  [7:0]  alu_a;
wire [7:0]  alu_x;
wire [7:0]  alu_y;
reg  [31:0] i;

reg [7:0] alu_result_expected;
reg [7:0] alu_status_expected;
reg [7:0] alu_x_expected;
reg [7:0] alu_y_expected;

reg C_in;
reg [7:0] temp;
reg sign;
reg [3:0] AL;
reg [3:0] AH;
reg [3:0] BL;
reg [3:0] BH;
reg [7:0] alu_result_expected_temp;

t6507lp_alu DUT (
			.clk		(clk),
			.reset_n	(reset_n),
			.alu_enable	(alu_enable),
			.alu_result	(alu_result),
			.alu_status	(alu_status),
			.alu_opcode	(alu_opcode),
			.alu_a		(alu_a),
			.alu_x		(alu_x),		
			.alu_y		(alu_y)
		);


localparam period = 10;

task check;
	begin
		$display("               RESULTS       EXPECTED");
		$display("alu_result       %h             %h   ", alu_result, alu_result_expected);
		$display("alu_status    %b       %b   ", alu_status, alu_status_expected);
		$display("alu_x            %h             %h   ", alu_x,      alu_x_expected     );
		$display("alu_y            %h             %h   ", alu_y,      alu_y_expected     );
		if ((alu_result_expected == alu_result) && (alu_status_expected == alu_status) && (alu_x_expected == alu_x) && (alu_y_expected == alu_y))
		begin
			$display("Instruction %h... OK!", alu_opcode);
		end
		else
		begin
			$display("ERROR at instruction %h",alu_opcode);
			$finish;
		end
	end
endtask


always begin
	#(period/2) clk = ~clk;
end

initial
begin
	// Reset
	clk = 0;
	reset_n = 0;
	@(negedge clk);
	//@(negedge clk);
	reset_n = 1;
	alu_enable = 1;
	alu_result_expected = 8'h00;
	alu_status_expected = 8'b00100010;
	alu_x_expected = 8'h00;
	alu_y_expected = 8'h00;

	// LDA
	alu_a = 0;
	alu_opcode = LDA_IMM;
        //$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
	//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
	@(negedge clk);
	alu_result_expected = 8'h00;
	//                       NV1BDIZC
    alu_status_expected = 8'b00100010;
	check();

	// ADC
	alu_opcode = ADC_IMM;
	alu_a = 1;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = $random;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], DUT.result);
		sign = alu_result_expected[7];
		{alu_status_expected[C], alu_result_expected} = alu_a + alu_result_expected + alu_status_expected[C];
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		alu_status_expected[V] = ((alu_a[7] == sign) && (alu_a[7] != alu_result_expected[7]));
		check();
	end

	// BCD
	// LDA
	alu_a = 0;
	alu_opcode = LDA_IMM;
        //$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
	//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
	@(negedge clk);
	alu_result_expected = 8'h00;
	//                       NV1BDIZC
	alu_status_expected[N] = 0;
	alu_status_expected[Z] = 1;
	check();
	// SED
	alu_opcode = SED_IMP;
	@(negedge clk);
	alu_status_expected[D] = 1;
	check();

	// ADC
	alu_opcode = ADC_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = $random;
		@(negedge clk);
		$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], DUT.result);
		sign = alu_result_expected[7];
		AL = alu_a[3:0];
		AH = alu_a[7:4];
		BL = alu_result_expected[3:0];
		BH = alu_result_expected[7:4];
		if ( AL > 9 ) begin
			AL = AL - 10;
			AH = AH + 1;
		end
		if (AH > 9) begin
			AH = AH - 10;
		end
		if ( BL > 9 ) begin
			BL = BL - 10;
			BH = BH + 1;
		end
		if ( BH > 9 ) begin
			BH = BH - 10;
		end
		{C_in,alu_result_expected[3:0]} = AL + BL + alu_status_expected[C];
		{alu_status_expected[C],alu_result_expected[7:4]} = AH + BH + C_in;
		if ( alu_result_expected[3:0] > 9 ) begin
			alu_result_expected[3:0] = alu_result_expected[3:0] - 10;
			alu_result_expected[7:4] = alu_result_expected[7:4] + 1;
		end
		if ( alu_result_expected[7:4] > 9 ) begin
			alu_result_expected[7:4] = alu_result_expected[7:4] - 10;
			alu_status_expected[C] = 1;
		end
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		alu_status_expected[V] = ((alu_a[7] == sign) && (alu_a[7] != alu_result_expected[7]));
		check();
	end	

		
	// ASL
	alu_opcode = ASL_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		{alu_status_expected[C], alu_result_expected} = {alu_a,1'b0};
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check();
	end

	// LDA
	alu_a = 137;
	alu_opcode = LDA_IMM;
    //$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
	//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
	@(negedge clk);
	alu_result_expected = 8'd137;
	//                       NV1BDIZC
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check();
	
	// EOR
	alu_opcode = EOR_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		$display("result_expected = %d",alu_result_expected);
		alu_result_expected = alu_a ^ alu_result_expected;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		$display("result_expected = %d", alu_result_expected);
		check();
	end

	// LDA
	alu_a = 0;
	alu_opcode = LDA_IMM;
    //$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
	//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
	@(negedge clk);
	alu_result_expected = 8'h00;
	//                       NV1BDIZC
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check();

	// SBC
	alu_opcode = SBC_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = 1;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		sign = alu_result_expected[7];
		{alu_status_expected[C], alu_result_expected} = alu_result_expected - alu_a - ( 1 - alu_status_expected[C]);
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		alu_status_expected[V] = ((alu_a[7] == sign) && (alu_a[7] != alu_result_expected[7]));
		check();
	end

	// LDA
	alu_opcode = LDA_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_result_expected = i;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// LDX
	alu_opcode = LDX_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_x_expected = i;
		//alu_result_expected = i;
		alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_x_expected[7];
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// LDY
	alu_opcode = LDY_IMM;
	for (i = 0; i < 1001; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_y_expected = i;
		//alu_result_expected = i;
		alu_status_expected[Z] = (alu_y_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_y_expected[7];
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// STA
	alu_opcode = STA_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// STX
	alu_opcode = STX_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//alu_result_expected = i;
		//alu_x_expected = i;
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// STY
	alu_opcode = STY_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//alu_result_expected = i;
		//alu_y_expected = i;
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// CMP
	alu_opcode = CMP_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		temp = alu_result_expected - alu_a;
		alu_status_expected[Z] = (temp == 0) ? 1 : 0;
		alu_status_expected[N] = temp[7];
		alu_status_expected[C] = (alu_result_expected >= alu_a) ? 1 : 0;
		//alu_result_expected = i;
		//alu_y_expected = i;
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// CPX
	alu_opcode = CPX_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		temp = alu_x_expected - alu_a;
		alu_status_expected[Z] = (temp == 0) ? 1 : 0;
		alu_status_expected[N] = temp[7];
		alu_status_expected[C] = (alu_x_expected >= alu_a) ? 1 : 0;
		//alu_result_expected = i;
		//alu_y_expected = i;
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// CPY
	alu_opcode = CPY_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		temp = alu_y_expected - alu_a;
		alu_status_expected[Z] = (temp == 0) ? 1 : 0;
		alu_status_expected[N] = temp[7];
		alu_status_expected[C] = (alu_y_expected >= alu_a) ? 1 : 0;
		//alu_result_expected = i;
		//alu_y_expected = i;
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end
	

	// AND
	alu_opcode = AND_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_result_expected = alu_a & alu_result_expected;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// ASL
	alu_opcode = ASL_ACC;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_status_expected[C] = alu_result_expected[7];
		alu_result_expected[7:0] = alu_result_expected << 1;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		check();
	end

	// INC
	alu_opcode = INC_ZPG;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		alu_result_expected = alu_a + 1;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check();
	end

	// INX
	alu_opcode = INX_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		alu_x_expected = alu_x_expected + 1;
		alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_x_expected[7];
		check();
	end

	// INY
	alu_opcode = INY_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		alu_y_expected = alu_y_expected + 1;
		alu_status_expected[Z] = (alu_y_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_y_expected[7];
		check();
	end

	// DEC
	alu_opcode = DEC_ZPG;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		alu_result_expected = alu_a - 1;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check();
	end

	// DEX
	alu_opcode = DEX_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		alu_x_expected = alu_x_expected - 1;
		alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_x_expected[7];
		check();
	end

	// DEY
	alu_opcode = DEY_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		alu_y_expected = alu_y_expected - 1;
		alu_status_expected[Z] = (alu_y_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_y_expected[7];
		check();
	end


	// LDA
	alu_a = 0;
	alu_opcode = LDA_IMM;
        //$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
	//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
	@(negedge clk);
	alu_result_expected = 8'h00;
	//                       NV1BDIZC
        alu_status_expected = 8'b00100010;
	check();

	// BIT
	alu_opcode = BIT_ZPG;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		alu_status_expected[Z] = ((alu_a & alu_result_expected) == 0) ? 1 : 0;
		alu_status_expected[V] = alu_a[6];
		alu_status_expected[N] = alu_a[7];
		check();
	end

	// PHA
	alu_opcode = PHA_IMP;
	@(negedge clk);
	//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
	//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
	//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
	alu_result_expected = DUT.A;
	check();

	// PHP
	alu_opcode = PHP_IMP;
	@(negedge clk);
	//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
	//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
	//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
	alu_status_expected = DUT.STATUS;
	check();

	// BRK
	alu_opcode = BRK_IMP;
	@(negedge clk);
	alu_status_expected[B] = 1;
	check();
		
	// SEC
	alu_opcode = SEC_IMP;
	@(negedge clk);
	alu_status_expected[C] = 1;
	check();

	// SED
	alu_opcode = SED_IMP;
	@(negedge clk);
	alu_status_expected[D] = 1;
	check();

	// SEI
	alu_opcode = SEI_IMP;
	@(negedge clk);
	alu_status_expected[I] = 1;
	check();

	// CLC
	alu_opcode = CLC_IMP;
	@(negedge clk);
	alu_status_expected[C] = 0;
	check();

	// CLD
	alu_opcode = CLD_IMP;
	@(negedge clk);
	alu_status_expected[D] = 0;
	check();

	// CLI
	alu_opcode = CLI_IMP;
	@(negedge clk);
	alu_status_expected[I] = 0;
	check();

	// CLV
	alu_opcode = CLV_IMP;
	@(negedge clk);
	alu_status_expected[V] = 0;
	check();

	// LDA
	alu_opcode = LDA_IMM;
	alu_a = 8'h76;
	@(negedge clk);
	alu_result_expected = alu_a;
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check();

	// TAX
	alu_opcode = TAX_IMP;
	@(negedge clk);
	alu_x_expected = alu_result_expected;
	alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_x_expected[7];
	check();

	// TAY
	alu_opcode = TAY_IMP;
	@(negedge clk);
	alu_y_expected = alu_result_expected;
	alu_status_expected[Z] = (alu_y_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_y_expected[7];
	check();
	
	// TSX
	alu_opcode = TSX_IMP;
	@(negedge clk);
	alu_x_expected = alu_a;
	//alu_result_expected = alu_a;
	alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_x_expected[7];
	check();

	// TXA
	alu_opcode = TXA_IMP;
	@(negedge clk);
	alu_result_expected = alu_x_expected;
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check();

	// TXS
	alu_opcode = TXS_IMP;
	@(negedge clk);
	alu_result_expected = alu_x_expected;
	check();

	// TYA
	alu_opcode = TYA_IMP;
	@(negedge clk);
	alu_result_expected = alu_y_expected;
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check();

	// Nothing should happen
	// BCC
	alu_opcode = BCC_REL;
	@(negedge clk);
	check();

	// BCS
	alu_opcode = BCS_REL;
	@(negedge clk);
	check();

	// BEQ
	alu_opcode = BEQ_REL;
	@(negedge clk);
	check();

	// BMI
	alu_opcode = BMI_REL;
	@(negedge clk);
	check();

	// BNE
	alu_opcode = BNE_REL;
	@(negedge clk);
	check();

	// BPL
	alu_opcode = BPL_REL;
	@(negedge clk);
	check();

	// BVC
	alu_opcode = BVC_REL;
	@(negedge clk);
	check();

	// BVS
	alu_opcode = BVS_REL;
	@(negedge clk);
	check();
	
	// JMP
	alu_opcode = JMP_ABS;
	@(negedge clk);
	check();

	// JMP
	alu_opcode = JMP_IND;
	@(negedge clk);
	check();
	
	// JSR
	alu_opcode = JSR_ABS;
	@(negedge clk);
	check();
	
	// NOP
	alu_opcode = NOP_IMP;
	@(negedge clk);
	check();

	// RTS
	alu_opcode = RTS_IMP;
	@(negedge clk);
	check();
	
	$display("TEST PASSED");
	$finish;
end

endmodule

