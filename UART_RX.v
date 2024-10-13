module UART_RX
#(
	parameter	integer	BPS		= 9_600		,		//波特率
	parameter 	integer	CLK_FRE	= 96_000_000		//时钟频率
)	
(	

	input 				sys_clk			,			
	input 				sys_rst_n		,			
	
	input 				uart_rxd		,			
	
	output reg 			uart_rx_done	,			
	output reg [7:0]	uart_rx_data				
);
 parameter integer BPS_CNT = CLK_FRE/BPS;
 
 reg uart_rx_d1;
 reg uart_rx_d2;
 reg uart_rx_d3;
 wire neg_uart_rxd;
 reg rx_en; 
 reg[3:0] bit_cnt;
 reg[31:0] clk_cnt;
 reg[7:0] uart_rx_data_reg;
 reg bps_clk;
 
assign	neg_uart_rxd = uart_rx_d3 & (~uart_rx_d2);	
 

always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		uart_rx_d1 <= 1'b0;
		uart_rx_d2 <= 1'b0;
		uart_rx_d3 <= 1'b0;
	end
	else begin
		uart_rx_d1 <= uart_rxd;
		uart_rx_d2 <= uart_rx_d1;
		uart_rx_d3 <= uart_rx_d2;
	end		
end


always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		rx_en <= 1'b0;
	else begin 
		if(neg_uart_rxd )								
			rx_en <= 1'b1;
		
		else if((bit_cnt == 4'd9) && (clk_cnt == BPS_CNT >> 1'b1) && (uart_rx_d3 == 1'b1) )
			rx_en <= 1'b0;
		else 
			rx_en <= rx_en;			
	end
end


always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		uart_rx_done <= 1'b0;
		uart_rx_data <= 8'd0;
	end	

	else if((bit_cnt == 4'd9) && (clk_cnt == BPS_CNT >> 1'd1) && (uart_rx_d3 == 1'b1))begin		
		uart_rx_done <= 1'b1;									
		uart_rx_data <= uart_rx_data_reg;	
	end							
	else begin					
		uart_rx_done <= 1'b0;									
		uart_rx_data <= uart_rx_data;
	end
end
 

always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		bit_cnt <= 4'd0;
		clk_cnt <= 32'd0;
		bps_clk <= 1;
	end
	else if(rx_en)begin					            			        
		if (clk_cnt == BPS_CNT/2 - 1)begin         
		  bps_clk <= ~bps_clk;
		  clk_cnt <= clk_cnt + 1'b1;              			
			bit_cnt <= bit_cnt;
		end
		else if(clk_cnt < BPS_CNT - 1'b1)begin       
			bps_clk <= bps_clk;
			clk_cnt <= clk_cnt + 1'b1;              			
			bit_cnt <= bit_cnt;                     			
		end                                         			
		else begin                                  				
			bps_clk <= ~bps_clk;
			clk_cnt <= 32'd0;                       			
			bit_cnt <= bit_cnt + 1'b1;              			
		end                                         			
	end                                             			
	else begin                                  			
			bps_clk <= 1;
			bit_cnt <= 4'd0;                        			
			clk_cnt <= 32'd0;                       			
	end		
end
 

always @(posedge sys_clk or negedge sys_rst_n)begin
  if(!sys_rst_n)begin
		uart_rx_data_reg <= 8'd0;
	end
	else if(rx_en)begin
	  if(bps_clk)begin
	   case(bit_cnt)
	    4'd0:uart_rx_data_reg <= uart_rx_data_reg;
	    4'd1:uart_rx_data_reg <= {uart_rx_data_reg[7],uart_rx_data_reg[6],uart_rx_data_reg[5],uart_rx_data_reg[4],uart_rx_data_reg[3],uart_rx_data_reg[2],uart_rx_data_reg[1],uart_rx_d2};
	    4'd2:uart_rx_data_reg <= {uart_rx_data_reg[7],uart_rx_data_reg[6],uart_rx_data_reg[5],uart_rx_data_reg[4],uart_rx_data_reg[3],uart_rx_data_reg[2],uart_rx_d2,uart_rx_data_reg[0]};
	    4'd3:uart_rx_data_reg <= {uart_rx_data_reg[7],uart_rx_data_reg[6],uart_rx_data_reg[5],uart_rx_data_reg[4],uart_rx_data_reg[3],uart_rx_d2,uart_rx_data_reg[1],uart_rx_data_reg[0]};
	    4'd4:uart_rx_data_reg <= {uart_rx_data_reg[7],uart_rx_data_reg[6],uart_rx_data_reg[5],uart_rx_data_reg[4],uart_rx_d2,uart_rx_data_reg[2],uart_rx_data_reg[1],uart_rx_data_reg[0]};
	    4'd5:uart_rx_data_reg <= {uart_rx_data_reg[7],uart_rx_data_reg[6],uart_rx_data_reg[5],uart_rx_d2,uart_rx_data_reg[3],uart_rx_data_reg[2],uart_rx_data_reg[1],uart_rx_data_reg[0]};
	    4'd6:uart_rx_data_reg <= {uart_rx_data_reg[7],uart_rx_data_reg[6],uart_rx_d2,uart_rx_data_reg[4],uart_rx_data_reg[3],uart_rx_data_reg[2],uart_rx_data_reg[1],uart_rx_data_reg[0]};
	    4'd7:uart_rx_data_reg <= {uart_rx_data_reg[7],uart_rx_d2,uart_rx_data_reg[5],uart_rx_data_reg[4],uart_rx_data_reg[3],uart_rx_data_reg[2],uart_rx_data_reg[1],uart_rx_data_reg[0]};
	    4'd8:uart_rx_data_reg <= {uart_rx_d2,uart_rx_data_reg[6],uart_rx_data_reg[5],uart_rx_data_reg[4],uart_rx_data_reg[3],uart_rx_data_reg[2],uart_rx_data_reg[1],uart_rx_data_reg[0]};
      4'd9:uart_rx_data_reg <= uart_rx_data_reg;
      default:uart_rx_data_reg <= uart_rx_data_reg;
     endcase
    end
    else uart_rx_data_reg <= uart_rx_data_reg;
  end
  else begin
    uart_rx_data_reg <= uart_rx_data_reg;
  end
end  
 
 
 
endmodule 

