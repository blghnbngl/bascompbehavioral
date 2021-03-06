`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ceng232 Summer Project
// Engineer: Bilgehan
// 
// Create Date:    17:53:29 07/10/2016 
// Design Name: 
// Module Name:    control 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: The longest and most difficult module of all, the control module. This is the
//	brain of Basic Computer.
//
//	Be aware that in this part there are many parts that are taken into comments. One reason is that behavioral
// modeling in Verilog can get quite confusing in large modules. Another reason is, since this is the most 
//	complex part of the Basic Computer I tried different approaches and then I decided to dump some of them. 
//	But to be prepared if I ever changed my mind and wanted to use some of these approaches, I took these parts 
//	into comments rather than erasing them. 
//
//////////////////////////////////////////////////////////////////////////////////
module control(
    input [15:0] ir_outdata,
    input [7:0] opcode,
    input [15:0] times,
    input reset,
    input start,
	 input clk, 
	 input [15:0] dr_outdata,
	 input [15:0] ac_outdata,
	 input e_outdata,
	 input fgi_outdata,
	 input fgo_outdata,
	 input ien_outdata,
	 input r_outdata,
    output reg [2:0] bus_code,
    output reg ar_load,
    output reg ar_inc,
    output reg ar_clr,
    output reg pc_load,
    output reg pc_inc,
    output reg pc_clr,
    output reg dr_load,
    output reg dr_inc,
    output reg dr_clr,
    output reg ac_load,
    output reg ac_inc,
    output reg ac_clr,
    output reg ir_load,
	 output reg ir_inc,
	 output reg ir_clr,
    output reg tr_load,
    output reg tr_inc,
    output reg tr_clr,
	 output reg mem_write,
	 output reg mem_read,			
	 output reg mem_clr,
	 output reg e_reset,
    output reg outr_load,
    output reg [3:0] alu_code,
	 output reg seq_clr,
	 output reg seq_inc,
	 output reg control_fgi_indata,
	 output reg control_fgo_indata,
	 output reg ien_indata,
	 output reg inpr_clr,
	 output reg outr_clr,
	 output reg	fgi_clr,
	 output reg	fgo_clr,
	 output reg	ien_clr,
	 output reg r_clr,
	 output reg io_clr,
	 output reg halted
    );
	 
	
reg indirect;						// To indicate indirect memory operations
integer opcode_errorchecker;	// To see if there is an error in operation code
integer registerreference_errorchecker;	//To see if there is an error in register reference command


/*
assign too_late= times[15] & times[14] & times[13] & times[12] & times[11] & times[10] & times[9]
						& times[8] & times[7]
*/
/*
always @(times)
	begin
		sequence_count<=15*times[15]+14*times[14]+13*times[13]+12*times[12]+11*times[11]+10*times[10]+9*times[9]+
		8*times[8]+7*times[7]+6*times[6]+5*times[5]+4*times[4]+3*times[3]+2*times[2]+1*times[1];
	end
*/
/*	 
initial
	begin

		sequence_count<=15*times[15]+14*times[14]+13*times[13]+12*times[12]+11*times[11]+10*times[10]+9*times[9]+
		8*times[8]+7*times[7]+6*times[6]+5*times[5]+4*times[4]+3*times[3]+2*times[2]+1*times[1];
		bus_code<=3'b000;
		ar_load<=0;
		ar_inc<=0;
		ar_clr<=0;
		pc_load<=0;
		pc_inc<=0;
      pc_clr<=0;
		dr_load<=0;
		dr_inc<=0;
		dr_clr<=0;
		ac_load<=0;
		ac_inc<=0;
		ac_clr<=0;
		ir_load<=0;
		ir_inc<=0;
		ir_clr<=0;
		tr_load<=0;
		tr_inc<=0;
		tr_clr<=0;
		outr_load<=0;
		alu_code<=4'b0000;
		seq_clr<=0;
		halted<=0;
	end
*/

always @(posedge clk)
	begin
		if (reset==1)				
			begin		
				ar_load<=0;		//After reset, we want computer to be totally clear, ie no data or 
				ar_inc<=0;		//instructions remaining from the past.	
				pc_load<=0;		//Since this module is behavioral, all outputs are of form output reg. 	
				pc_inc<=0;		//Reg means they can hold values, so we should manually
				dr_load<=0;		//make sure that after a reset all unused outputs are clear, ie 0. 	
				dr_inc<=0;
				ac_load<=0;
				ac_inc<=0;
				ir_load<=0;
				ir_inc<=0;
				tr_load<=0;
				tr_inc<=0;
				mem_write<=0;
				mem_read<=0;			
				outr_load<=0;
				seq_inc<=0;
				control_fgi_indata<=0;
				control_fgo_indata<=0;
				ien_indata<=0;
				halted<=0;
				mem_clr<=1;						//Actually, this does nothing and can be taken away.						
				inpr_clr<=1;
				outr_clr<=1;
				ar_clr<=1;
				pc_clr<=1;
				dr_clr<=1;
				ac_clr<=1;
				ir_clr<=1;
				tr_clr<=1;
				alu_code<=4'b0000;
				seq_clr<=1;
				bus_code<=3'b000;
				e_reset<=1;
				fgi_clr<=1;
				fgo_clr<=1;
				ien_clr<=1;
				io_clr<=1;
				r_clr<=1;
			end
		else if (times<=7)						//This means we are in the first 4 clock cycle
			begin										//Common parts for all operations
				case(times[3:0])
					4'b0001:							//Fetch part
						begin
						/*	mem_clr<=0; 			//The part below, until the if condition is to clear
							inpr_clr<=0;			//the effects of any possible prior reset operation.
							outr_clr<=0;
							ar_clr<=0;
							pc_clr<=0;
							dr_clr<=0;
							ac_clr<=0;
							ir_clr<=0;
							tr_clr<=0;
							seq_clr<=0;
							e_reset<=0;
							fgi_clr<=0;
							fgo_clr<=0;
							ien_clr<=0;
							r_clr<=0;*/
							if (r_outdata != 1)	//R'T0 in our lecture notes
								begin
									pc_load<=0;
									dr_load<=0;
									ac_load<=0;
									ir_load<=0;
									tr_load<=0;
									r_clr<=0;
									outr_load<=0;
									pc_inc<=0;
									mem_write<=0;
									mem_read<=0;
									seq_clr<=0;
									control_fgi_indata<=0;
									control_fgo_indata<=0;
									bus_code<=3'b010;
									ar_load<=1;
									seq_inc<=1;
								end
							else						//RT0 in our lecture notes
								begin					//This R means system is interrupted by I/O system and it is
									pc_load<=0;		//assigned in the main module.
									dr_load<=0;
									ac_load<=0;
									ir_load<=0;
									tr_load<=0;
									outr_load<=0;
									r_clr<=0;
									pc_inc<=0;
									mem_write<=0;
									mem_read<=0;
									seq_clr<=0;
									control_fgi_indata<=0;
									control_fgo_indata<=0;
									bus_code<=3'b010;
									tr_load<=1;
									ar_clr<=1;
									seq_inc<=1;
								end
						end  
					4'b0010:
						begin
							if (r_outdata != 1)			//R'T1
								begin
									ar_load<=0;
									mem_read<=1;
									bus_code<=3'b111;
									ir_load<=1;
									pc_inc<=1;
									seq_inc<=1;
								end
							else								//RT1
								begin
									tr_load<=0;
									ar_clr<=0;
									mem_read<=0;
									bus_code<=3'b110;
									mem_write<=1;
									pc_clr<=1;
									seq_inc<=1;
								end
						end
					4'b0100:
						begin
							if (r_outdata != 1)		//R'T2
								begin
									// Decoding of opcodes is done in the threebitdecoder module.
									mem_read<=0;
									ir_load<=0;
									pc_inc<=0;
									bus_code<=3'b101;
									ar_load<=1;
									indirect<=ir_outdata[15];						
									opcode_errorchecker=opcode[7]+opcode[6]+opcode[5]+opcode[4]+opcode[3]
														+opcode[2]+opcode[1]+opcode[0]; //That's for checking errors.
									registerreference_errorchecker = 11*ir_outdata[11]+10*ir_outdata[10]+9*ir_outdata[9]
									+8*ir_outdata[8] +7*ir_outdata[7]+6*ir_outdata[6]+5*ir_outdata[5]+4*ir_outdata[4]
									+3*ir_outdata[3]	+2*ir_outdata[2]+1*ir_outdata[1]+0*ir_outdata[0];
									seq_inc<=1;
								end
							else								//RT2
								begin
									bus_code<=3'b000;
									mem_write<=0;
									pc_clr<=0;
									seq_inc<=0;
									pc_inc<=1;
									ien_indata<=0;
									r_clr<=1;
									seq_clr<=1;
								end
						end
					4'b0000:								//The very beginning where sequence count is 0.
						begin								//All outputs are 0, except incrementing the clock.
							seq_inc<=1;
							bus_code<=0;
							ar_load<=0;
							ar_inc<=0;
							ar_clr<=0;
							pc_load<=0;
							pc_inc<=0;
							pc_clr<=0;
							dr_load<=0;
							dr_inc<=0;
							dr_clr<=0;
							ac_load<=0;
							ac_inc<=0;
							ac_clr<=0;
							ir_load<=0;
							ir_inc<=0;
							ir_clr<=0;
							tr_load<=0;
							tr_inc<=0;
							tr_clr<=0;
							mem_write<=0;
							mem_read<=0;			
							mem_clr<=0;
							e_reset<=0;
							outr_load<=0;
							alu_code<=0;
							seq_clr<=0;
							control_fgi_indata<=0;
							control_fgo_indata<=0;
							ien_indata<=0;
							inpr_clr<=0;
							outr_clr<=0;
							fgi_clr<=0;
							fgo_clr<=0;
							ien_clr<=0;
							r_clr<=0;
							io_clr<=0;
						end
					default:						//If there is a timing in error, start again
						begin
							seq_clr<=1;
						end
				endcase	
			end
		else 										//Now we have past the first 3 clock cycles
			begin 								//Here, operations differ
				if (opcode_errorchecker!=1)
					$display("Error in decoding operation code, in control unit");
				else if (opcode[0]==1)			//And operation of Accumulator and Memory data
					begin
						case(times)
							16'b0000000000001000:	//D0T3
								begin 
									if (indirect==1)
										begin
											//ar_load<=0;				
											//seq_inc<=1;
											
											bus_code<=3'b111;
											mem_read<=1;
											ar_load<=1;
											seq_inc<=1;
										end
									else
										begin
											bus_code<=3'b000;
											ar_load<=0;
											seq_inc<=1;
										end
								end
							16'b0000000000010000:		//D0T4
								begin
									ar_load<=0;				
									bus_code<=3'b111;
									mem_read<=1;
									dr_load<=1;
									seq_inc<=1;
								end
							16'b0000000000100000:		//D0T5
								begin
									dr_load<=0;
									bus_code<=3'b000;
									mem_read<=0;
									alu_code<=4'b0001;
									ac_load<=1;
									seq_inc<=0;
									seq_clr<=1;
								end
							default:							//A security measure in case that somehow we go to a higher
								begin							//clock cycle count
									seq_clr<=1;
									seq_inc<=0;
									ac_load<=0;
								end
						endcase
					end
				else if(opcode[1]==1)	//Sum operation of Accumulator and Memory data
					begin
						case (times)
							16'b0000000000001000:				//D1T3
								begin 
									if (indirect==1)
										begin
											bus_code<=3'b111;		
											mem_read<=1;
											ar_load<=1;
											seq_inc<=1;
										end
									else
										begin
											bus_code<=3'b000;
											ar_load<=0;
											seq_inc<=1;	
										end
								end
							16'b0000000000010000:			//D1T4
								begin
									ar_load<=0;
									bus_code<=3'b111;
									mem_read<=1;
									dr_load<=1;
									seq_inc<=1;			
								end
							16'b0000000000100000:
								begin
									dr_load<=0;
									bus_code<=3'b000;
									mem_read<=0;
									alu_code<=4'b0010;
									ac_load<=1;
									seq_inc<=0;
									seq_clr<=1;									
								end
							default:
								begin
									seq_inc<=0;
									ac_load<=0;
									seq_clr<=1;
								end
						endcase
					end
				else if (opcode[2]==1)	//Load memory data to AC
					begin
						case (times)
							16'b0000000000001000:		//D2T3
								begin 
									if (indirect==1)
										begin
											bus_code<=3'b111;
											mem_read<=1;
											ar_load<=1;
											seq_inc<=1;
										end
									else
										begin
										bus_code<=3'b000;
										ar_load<=0;
										seq_inc<=1;
										end
								end
							16'b0000000000010000:		//D2T4
								begin
									ar_load<=0;
									bus_code<=3'b111;
									mem_read<=1;
									dr_load<=1;
									seq_inc<=1;	
								end
							16'b0000000000100000:		//D2T5
								begin
									dr_load<=0;
									mem_read<=0;
									bus_code<=3'b000;
									alu_code<=4'b0011;
									ac_load<=1;
									seq_inc<=0;
									seq_clr<=1;
								end
							default:
								begin
									seq_inc<=0;
									 
									seq_clr<=1;
								end
						endcase
					end
				else if (opcode[3]==1)	//Store AC to memory
					begin
						case(times)
							16'b0000000000001000:		//D3T3
								begin 
									if (indirect==1)
										begin
											bus_code<=3'b111;
											mem_read<=1;
											ar_load<=1;
											seq_inc<=1;
										end
									else
										begin
											bus_code<=3'b000;
											ar_load<=0;
											seq_inc<=1;	
										end	
								end
							16'b0000000000010000:		//D3T4
								begin
									ar_load<=0;
									mem_read<=0;
									bus_code<=3'b100;
									mem_write<=1;
									seq_inc<=0;
									seq_clr<=1;
								end
							default:
								begin
									mem_write<=0;
									seq_clr<=1;
								end
						endcase
					end
				else if (opcode[4]==1)	//Branch unconditionally
					begin
						case(times)
							16'b0000000000001000:		//D4T3
								begin 
									if (indirect==1)
										begin
											bus_code<=3'b111;
											mem_read<=1;
											ar_load<=1;
											seq_inc<=1;
										end
									else
										begin
											bus_code<=3'b000;
											ar_load<=0;
											seq_inc<=1;	
										end	
								end
							16'b0000000000010000:		//D4T4
								begin
									ar_load<=0;
									mem_read<=0;
									bus_code<=3'b001;
									pc_load<=1;
									seq_inc<=0;
									seq_clr<=1;
								end
							default:
								begin
									seq_inc<=0;
									pc_load<=0;
									seq_clr<=1;
								end
						endcase
					end
				else if (opcode[5]==1)		//Branch to subroutine
					begin
						case (times)		
							16'b0000000000001000:				//D5T3
								begin 
									if (indirect==1)
										begin
											bus_code<=3'b111;
											mem_read<=1;
											ar_load<=1;
											seq_inc<=1;
										end
									else
										begin
											bus_code<=3'b000;
											ar_load<=0;
											seq_inc<=1;	
										end
								end
							16'b0000000000010000:			//D5T4
								begin
									ar_load<=0;
									mem_read<=0;
									bus_code<=3'b010;
									mem_write<=1;
									ar_inc<=1;
									seq_inc<=1;
								end
							16'b0000000000100000:			//D5T5
								begin
									mem_write<=0;
									ar_inc<=0;
									bus_code<=3'b001;
									pc_load<=1;
									seq_inc<=0;
									seq_clr<=1;
								end
							default:
								begin
									pc_load<=0;
									seq_clr<=1;
								end
						endcase
					end
				else if (opcode[6]==1)	// Increment and skip if zero
					begin
						case(times)
							16'b0000000000001000:		//D6T3
								begin 
									if (indirect==1)
										begin
											bus_code<=3'b111;
											mem_read<=1;
											ar_load<=1;
											seq_inc<=1;
										end
									else
										begin
											bus_code<=3'b000;
											ar_load<=0;
											seq_inc<=1;	
										end	
								end
							16'b0000000000010000:		//D6T4
								begin
									ar_load<=0;
									bus_code<=3'b111;
									mem_read<=1;
									dr_load<=1;
									seq_inc<=1;	
								end
							16'b0000000000100000:		//D6T5
								begin
									dr_load<=0;
									mem_read<=0;
									bus_code<=3'b000;
									dr_inc<=1;
									seq_inc<=1;
								end
							16'b0000000001000000:		//D6T6
								begin
									dr_inc<=0;
									bus_code<=3'b011;
									mem_write<=1;
									seq_inc<=0;
									if (dr_outdata==16'b0000000000000000)
										begin
											pc_inc<=1;
											seq_clr<=1;
										end			
									else
										seq_clr<=1;									
								end
							default:
								begin
									mem_write<=0;
									pc_inc<=0;
									seq_clr<=1;
								end
						endcase
					end
				else //if (opcode[7]==1)
					begin
						if (times==16'b0000000000001000) // To avoid any wrong-timed operations
								begin
									if (indirect==0)			//Below here, there are REGISTER REFERENCE instructions
										begin
											if (ir_outdata[11]==1 && registerreference_errorchecker==11)	//Clear AC
											//errochecker is to check errors, multiple 1's in 12 command bits
												begin
													bus_code<=3'b000;
													ar_load<=0;
													seq_inc<=0;
													ac_clr<=1;
													seq_clr<=1;
												end
											else if (ir_outdata[10]==1 && registerreference_errorchecker==10)	//Clear E 
												begin
													bus_code<=3'b000;
													ar_load<=0;
													seq_inc<=0;
													e_reset<=1;
													seq_clr<=1;
												end
											else if (ir_outdata[9]==1 && registerreference_errorchecker==9)	//Complement AC	
												begin
													bus_code<=3'b000;
													ar_load<=0;
													seq_inc<=0;
													alu_code<=4'b1001;
													ac_load<=1;
													seq_clr<=1;												
												end
											else if (ir_outdata[8]==1 && registerreference_errorchecker==8)	//Complement E
												begin
													bus_code<=3'b000;
													ar_load<=0;											
													seq_inc<=0;
													alu_code<=4'b1010;
													seq_clr<=1;
												end
											else if (ir_outdata[7]==1 && registerreference_errorchecker==7)	//Circular Shift to Right
												begin
													bus_code<=3'b000;
													ar_load<=0;											
													seq_inc<=0;
													alu_code<=4'b1011;
													ac_load<=1;
													seq_clr<=1;
												end
											else if (ir_outdata[6]==1 && registerreference_errorchecker==6)	//Circular Shift to Left
												begin
													bus_code<=3'b000;
													ar_load<=0;											
													seq_inc<=0;
													alu_code<=4'b1100;
													ac_load<=1;
													seq_clr<=1;
												end
											else if (ir_outdata[5]==1 && registerreference_errorchecker==5)	//Increment AC
												begin
													bus_code<=3'b000;
													ar_load<=0;											
													seq_inc<=0;
													ac_inc<=1;
													seq_clr<=1;
												end
											else if (ir_outdata[4]==1 && registerreference_errorchecker==4)	//Skip if positive
												begin
													if (ac_outdata[15]==0)
														begin
															bus_code<=3'b000;
															ar_load<=0;											
															seq_inc<=0;
															pc_inc<=1;
															seq_clr<=1;
														end
													else
														begin
															bus_code<=3'b000;
															ar_load<=0;											
															seq_inc<=0;
															seq_clr<=1;
														end
												end
											else if (ir_outdata[3]==1 && registerreference_errorchecker==3)	//Skip if negative
												begin
													if (ac_outdata[15]==1)
														begin
															bus_code<=3'b000;
															ar_load<=0;											
															seq_inc<=0;
															pc_inc<=1;
															seq_clr<=1;
														end
													else
														begin
															bus_code<=3'b000;
															ar_load<=0;											
															seq_inc<=0;
															seq_clr<=1;
														end
												end
											else if (ir_outdata[2]==1 && registerreference_errorchecker==2)	//Skip if zero
												begin
													if (ac_outdata==0)
														begin
															bus_code<=3'b000;
															ar_load<=0;											
															seq_inc<=0;
															pc_inc<=1;
															seq_clr<=1;
														end
													else
														begin
															bus_code<=3'b000;
															ar_load<=0;											
															seq_inc<=0;
															seq_clr<=1;
														end
												end
											else if (ir_outdata[1]==1 && registerreference_errorchecker==1)	//Skip if E is 0
												begin
													if (e_outdata==0)
														begin
															bus_code<=3'b000;
															ar_load<=0;											
															seq_inc<=0;
															pc_inc<=1;
															seq_clr<=1;
														end
													else
														begin
															bus_code<=3'b000;
															ar_load<=0;											
															seq_inc<=0;
															seq_clr<=1;
														end
												end
											else //if (ir_outdata[0]==1 && registerreference_errorchecker==0)	//Halt
												begin
													bus_code<=3'b000;
													ar_load<=0;											
													seq_inc<=0;
													halted<=1;		
													seq_clr<=1;
												end				
										end
									else //if (indirect==1)		//Below here, there are INPUT/OUTPUT instructions
										begin
												if (ir_outdata[11]==1 && registerreference_errorchecker==11)	//Input character to AC
													begin
														bus_code<=3'b000;
														ar_load<=0;
														seq_inc<=0;
														alu_code<=4'b1101;
														ac_load<=1;	
														control_fgi_indata<=1;		//I make interrupt impossible since input register is empty.
														seq_clr<=1;
													end
												else if (ir_outdata[10]==1 && registerreference_errorchecker==10)	//Output character from AC
													begin
														ar_load<=0;
														seq_inc<=0;
														bus_code<=3'b100;
														outr_load<=1;
														control_fgo_indata<=1;		//I make interrupt impossible since output register is not sent yet.
														seq_clr<=1;											
													end
												else if (ir_outdata[9]==1 && registerreference_errorchecker==9)	//Skip on input flag.
													begin
														if (fgi_outdata==1)
															begin
																bus_code<=3'b000;
																ar_load<=0;											
																seq_inc<=0;
																pc_inc<=1;
																seq_clr<=1;
															end
														else
															begin
																bus_code<=3'b000;
																ar_load<=0;											
																seq_inc<=0;
																seq_clr<=1;
															end
													end
												else if (ir_outdata[8]==1 && registerreference_errorchecker==8)	//Skip on output flag.
													begin
														if (fgo_outdata==1)
															begin
																bus_code<=3'b000;
																ar_load<=0;											
																seq_inc<=0;
																pc_inc<=1;
																seq_clr<=1;
															end
														else
															begin
																bus_code<=3'b000;
																ar_load<=0;											
																seq_inc<=0;
																seq_clr<=1;
															end
													end
												else if (ir_outdata[7]==1 && registerreference_errorchecker==7)	//Interrupt enable on
													begin
														ien_indata<=1;
													end
												else if (ir_outdata[6]==1 && registerreference_errorchecker==6)	//Interrupt enable off
													begin
														ien_indata<=0;
													end
												else 
													begin
														bus_code<=3'b000;
														ar_load<=0;											
														seq_inc<=0;
														seq_clr<=1;
													end
													
										end
								end
							end
						end
					end
endmodule
