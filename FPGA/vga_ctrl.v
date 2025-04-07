// choose different video standard,revise PLL clk ,alter cnt WIDTH//`define VGA_640X480X75
//`define VGA_800X600X60
`define VGA_640x480x60 
//`define VGA_800X600X75
//`define VGA_1024X768X60
//`define VGA_1024X768X75
//`define VGA_1280X1024X60
//`define VGA_1280X800X60
//`define VGA_1440X900X60

module vga_ctrl (

    input        wire                clk,
    input        wire                rst_n,
	 input		  wire					 show_cl,
	 input		  wire 					 plus_thick,
	 input		  wire 					 minus_thick,

    output    reg        [23:0]      vga_rgb,
	 output    reg                    vga_hs,
	 output    reg                    vga_vs,
    output    wire                   vga_blanck_n
);

//================ VGA_640X480X60 =========================================================

`ifdef VGA_640x480x60                                			// PLL clk = 25M = 640x480x60

    localparam            HS_A    =    96;                	// synchronous pulse, horizontal
    localparam            HS_B    =    48;                	// back porch pulse
    localparam            HS_C    =    640;                	// display interval
    localparam            HS_D    =    16;                	// Front porch
    localparam            HS_E    =    800;                	// horizontal cycles

    localparam            VS_A    =    2;                   // synchronous pulse, vertical
    localparam            VS_B    =    33;						// back porch pulse
    localparam            VS_C    =    480; 						// display interval   
    localparam            VS_D    =    10;    					// Top porch
    localparam            VS_E    =    525;    					// vertical cycles
    
    localparam            HS_WIDTH    =    10;
    localparam            VS_WIDTH    =    10;
	 localparam 			  CENTER_LINE =    VS_C / 2 + 50;


`endif


    parameter            CNT_VS_R    = 195;                	// 195 = 2+33+160, 35~195 is red
    parameter            CNT_VS_G    = 355;                	// 195~355 is green
    
    reg        [HS_WIDTH - 1:0]        cnt_hs;              // counter for vertical synchronous signal
    reg        [VS_WIDTH - 1:0]        cnt_vs;              // counter for horizontal synchrous signal
    
    wire                    en_hs;                         	// dsiplay horizontal enable
    wire                    en_vs;                          // display vertical enable
    wire                    en;                             // effective display zone
    
    wire                    en_vs_r;                        // red stripe enable
    wire                    en_vs_g;                        // green stripe enable

	// Parameters for sine wave
	parameter AMPLITUDE = 50;  // Amplitude of sine wave

	// Calculate sine wave position
	wire [9:0] x_scaled;
	assign x_scaled = (cnt_hs * 256) / HS_C;  // Scale x to 0-255

	reg signed [15:0] sine_table [0:255];
	reg show_central_line;
	reg thickness;

initial begin
		  show_central_line = 1;
		  thickness = 2;
        sine_table[0] = 0;
        sine_table[1] = 16;
        sine_table[2] = 31;
        sine_table[3] = 47;
        sine_table[4] = 63;
        sine_table[5] = 78;
        sine_table[6] = 94;
        sine_table[7] = 109;
        sine_table[8] = 125;
        sine_table[9] = 140;
        sine_table[10] = 156;
        sine_table[11] = 171;
        sine_table[12] = 186;
        sine_table[13] = 201;
        sine_table[14] = 216;
        sine_table[15] = 230;
        sine_table[16] = 245;
        sine_table[17] = 259;
        sine_table[18] = 274;
        sine_table[19] = 288;
        sine_table[20] = 302;
        sine_table[21] = 315;
        sine_table[22] = 329;
        sine_table[23] = 342;
        sine_table[24] = 356;
        sine_table[25] = 369;
        sine_table[26] = 381;
        sine_table[27] = 394;
        sine_table[28] = 406;
        sine_table[29] = 418;
        sine_table[30] = 430;
        sine_table[31] = 441;
        sine_table[32] = 453;
        sine_table[33] = 464;
        sine_table[34] = 474;
        sine_table[35] = 485;
        sine_table[36] = 495;
        sine_table[37] = 505;
        sine_table[38] = 514;
        sine_table[39] = 523;
        sine_table[40] = 532;
        sine_table[41] = 541;
        sine_table[42] = 549;
        sine_table[43] = 557;
        sine_table[44] = 564;
        sine_table[45] = 572;
        sine_table[46] = 579;
        sine_table[47] = 585;
        sine_table[48] = 591;
        sine_table[49] = 597;
        sine_table[50] = 603;
        sine_table[51] = 608;
        sine_table[52] = 612;
        sine_table[53] = 617;
        sine_table[54] = 621;
        sine_table[55] = 624;
        sine_table[56] = 628;
        sine_table[57] = 631;
        sine_table[58] = 633;
        sine_table[59] = 635;
        sine_table[60] = 637;
        sine_table[61] = 638;
        sine_table[62] = 639;
        sine_table[63] = 640;
        sine_table[64] = 640;
        sine_table[65] = 640;
        sine_table[66] = 639;
        sine_table[67] = 638;
        sine_table[68] = 637;
        sine_table[69] = 635;
        sine_table[70] = 633;
        sine_table[71] = 631;
        sine_table[72] = 628;
        sine_table[73] = 624;
        sine_table[74] = 621;
        sine_table[75] = 617;
        sine_table[76] = 612;
        sine_table[77] = 608;
        sine_table[78] = 603;
        sine_table[79] = 597;
        sine_table[80] = 591;
        sine_table[81] = 585;
        sine_table[82] = 579;
        sine_table[83] = 572;
        sine_table[84] = 564;
        sine_table[85] = 557;
        sine_table[86] = 549;
        sine_table[87] = 541;
        sine_table[88] = 532;
        sine_table[89] = 523;
        sine_table[90] = 514;
        sine_table[91] = 505;
        sine_table[92] = 495;
        sine_table[93] = 485;
        sine_table[94] = 474;
        sine_table[95] = 464;
        sine_table[96] = 453;
        sine_table[97] = 441;
        sine_table[98] = 430;
        sine_table[99] = 418;
        sine_table[100] = 406;
        sine_table[101] = 394;
        sine_table[102] = 381;
        sine_table[103] = 369;
        sine_table[104] = 356;
        sine_table[105] = 342;
        sine_table[106] = 329;
        sine_table[107] = 315;
        sine_table[108] = 302;
        sine_table[109] = 288;
        sine_table[110] = 274;
        sine_table[111] = 259;
        sine_table[112] = 245;
        sine_table[113] = 230;
        sine_table[114] = 216;
        sine_table[115] = 201;
        sine_table[116] = 186;
        sine_table[117] = 171;
        sine_table[118] = 156;
        sine_table[119] = 140;
        sine_table[120] = 125;
        sine_table[121] = 109;
        sine_table[122] = 94;
        sine_table[123] = 78;
        sine_table[124] = 63;
        sine_table[125] = 47;
        sine_table[126] = 31;
        sine_table[127] = 16;
        sine_table[128] = 0;
        sine_table[129] = -16;
        sine_table[130] = -31;
        sine_table[131] = -47;
        sine_table[132] = -63;
        sine_table[133] = -78;
        sine_table[134] = -94;
        sine_table[135] = -109;
        sine_table[136] = -125;
        sine_table[137] = -140;
        sine_table[138] = -156;
        sine_table[139] = -171;
        sine_table[140] = -186;
        sine_table[141] = -201;
        sine_table[142] = -216;
        sine_table[143] = -230;
        sine_table[144] = -245;
        sine_table[145] = -259;
        sine_table[146] = -274;
        sine_table[147] = -288;
        sine_table[148] = -302;
        sine_table[149] = -315;
        sine_table[150] = -329;
        sine_table[151] = -342;
        sine_table[152] = -356;
        sine_table[153] = -369;
        sine_table[154] = -381;
        sine_table[155] = -394;
        sine_table[156] = -406;
        sine_table[157] = -418;
        sine_table[158] = -430;
        sine_table[159] = -441;
        sine_table[160] = -453;
        sine_table[161] = -464;
        sine_table[162] = -474;
        sine_table[163] = -485;
        sine_table[164] = -495;
        sine_table[165] = -505;
        sine_table[166] = -514;
        sine_table[167] = -523;
        sine_table[168] = -532;
        sine_table[169] = -541;
        sine_table[170] = -549;
        sine_table[171] = -557;
        sine_table[172] = -564;
        sine_table[173] = -572;
        sine_table[174] = -579;
        sine_table[175] = -585;
        sine_table[176] = -591;
        sine_table[177] = -597;
        sine_table[178] = -603;
        sine_table[179] = -608;
        sine_table[180] = -612;
        sine_table[181] = -617;
        sine_table[182] = -621;
        sine_table[183] = -624;
        sine_table[184] = -628;
        sine_table[185] = -631;
        sine_table[186] = -633;
        sine_table[187] = -635;
        sine_table[188] = -637;
        sine_table[189] = -638;
        sine_table[190] = -639;
        sine_table[191] = -640;
        sine_table[192] = -640;
        sine_table[193] = -640;
        sine_table[194] = -639;
        sine_table[195] = -638;
        sine_table[196] = -637;
        sine_table[197] = -635;
        sine_table[198] = -633;
        sine_table[199] = -631;
        sine_table[200] = -628;
        sine_table[201] = -624;
        sine_table[202] = -621;
        sine_table[203] = -617;
        sine_table[204] = -612;
        sine_table[205] = -608;
        sine_table[206] = -603;
        sine_table[207] = -597;
        sine_table[208] = -591;
        sine_table[209] = -585;
        sine_table[210] = -579;
        sine_table[211] = -572;
        sine_table[212] = -564;
        sine_table[213] = -557;
        sine_table[214] = -549;
        sine_table[215] = -541;
        sine_table[216] = -532;
        sine_table[217] = -523;
        sine_table[218] = -514;
        sine_table[219] = -505;
        sine_table[220] = -495;
        sine_table[221] = -485;
        sine_table[222] = -474;
        sine_table[223] = -464;
        sine_table[224] = -453;
        sine_table[225] = -441;
        sine_table[226] = -430;
        sine_table[227] = -418;
        sine_table[228] = -406;
        sine_table[229] = -394;
        sine_table[230] = -381;
        sine_table[231] = -369;
        sine_table[232] = -356;
        sine_table[233] = -342;
        sine_table[234] = -329;
        sine_table[235] = -315;
        sine_table[236] = -302;
        sine_table[237] = -288;
        sine_table[238] = -274;
        sine_table[239] = -259;
        sine_table[240] = -245;
        sine_table[241] = -230;
        sine_table[242] = -216;
        sine_table[243] = -201;
        sine_table[244] = -186;
        sine_table[245] = -171;
        sine_table[246] = -156;
        sine_table[247] = -140;
        sine_table[248] = -125;
        sine_table[249] = -109;
        sine_table[250] = -94;
        sine_table[251] = -78;
        sine_table[252] = -63;
        sine_table[253] = -47;
        sine_table[254] = -31;
        sine_table[255] = -16;
    end
	
	wire [7:0] sine_index;
	assign sine_index = (cnt_hs * 256) / HS_C;
	
	
	
	reg [9:0] wave_y;


	always @(*) begin
    if (sine_table[sine_index] >= 0)
        wave_y = CENTER_LINE - ((sine_table[sine_index] * AMPLITUDE) >> 8);
    else
        wave_y = CENTER_LINE - ((sine_table[sine_index] * AMPLITUDE) >> 8);
	 
end 

    always @ (posedge clk, negedge rst_n)
        if (!rst_n)
            cnt_hs <= 0;
        else
            if (cnt_hs < HS_E - 1)
                cnt_hs <= cnt_hs + 1'b1;
            else
                cnt_hs <= 0;
                
    always @ (posedge clk, negedge rst_n)
        if (!rst_n)
            cnt_vs <= 0;
        else
            if (cnt_hs == HS_E - 1)
                if (cnt_vs < VS_E - 1)
                    cnt_vs <= cnt_vs + 1'b1;
                else
                    cnt_vs <= 0;
            else
                cnt_vs <= cnt_vs;
                
    always @ (posedge clk, negedge rst_n)
        if (!rst_n)
            vga_hs <= 1'b1;
        else
            if (cnt_hs < HS_A - 1) 
                vga_hs <= 1'b0;
            else
                vga_hs <= 1'b1;
                
    always @ (posedge clk, negedge rst_n)
        if (!rst_n)
            vga_vs <= 1'b1;
        else
            if (cnt_vs < VS_A - 1) 
                vga_vs <= 1'b0;
            else
                vga_vs <= 1'b1;
       
    assign en_hs = (cnt_hs > HS_A + HS_B - 1)&&(cnt_hs < HS_E - HS_D);
    assign en_vs = (cnt_vs > VS_A + VS_B - 1)&&(cnt_vs < VS_E - VS_D);
    assign en_vs_r = (cnt_vs > VS_A + VS_B - 1)&&(cnt_vs < CNT_VS_R);
    assign en_vs_g = (cnt_vs > CNT_VS_R  - 1)&&(cnt_vs < CNT_VS_G);   
    assign en = en_hs && en_vs;
	 assign vga_blanck_n = en;
	 
    always @ (posedge clk, negedge rst_n)
    if (!rst_n)
        vga_rgb <= 24'b0;
    else if (en) begin
        // Draw central horizontal line
        if (cnt_vs == CENTER_LINE && show_central_line == 1)
            vga_rgb <= 24'b111111111111111111111111;  // White line
        // Draw sine wave
        else if (cnt_vs >= wave_y - 5 && cnt_vs <= wave_y + 5)
            vga_rgb <= 24'b000000111111111111111111;  // yellow wave
        else
            vga_rgb <= 24'b0;  // Black background
    end else
        vga_rgb <= 24'b0;
	
		 
endmodule