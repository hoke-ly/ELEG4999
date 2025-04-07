module vga(

    input     wire                    clk,
    input     wire                    rst_n,
	 input     wire                    show_cl,
	 input	  wire 					     plus_thick,
	 input	  wire 					     minus_thick,
	 output    wire       [23:0]       vga_rgb,
    output    wire                    vga_hs,
    output    wire                    vga_vs,
	 output    wire                    vga_clk,
    output    wire                    vga_blank_n,
    output    wire                    vga_sync_n
);

    wire                    clk_25m;
    wire                    pll_locked;
    
    pll pll_inst (
    
        .rst             		(~rst_n),
        .refclk         		(clk),
        .outclk_0    			(clk_25m),
        .locked       			(pll_locked)
    );

    vga_ctrl vga_ctrl_inst (

        .clk                 	(clk_25m),
        .rst_n               	(pll_locked),
                         
        .vga_rgb             	(vga_rgb),
        .vga_hs              	(vga_hs),
        .vga_blanck_n        	(vga_blank_n),
        .vga_vs              	(vga_vs)
    );

//If not IOG, Sync input should be tied to 0;
assign vga_sync_n=1'b0;    
assign vga_clk=clk_25m;
 
endmodule