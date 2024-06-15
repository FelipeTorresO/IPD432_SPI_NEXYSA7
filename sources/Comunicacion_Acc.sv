///////////////////////////////////////////////////////////////////////////////////
// Afiliacion: UTFSM
// Autor: Felipe Torres
// Nombre del modulo: Comunicacion_Acc
// Descripcion: 
//				Modulo encargado de generar las señales necesarias para que el Master_SPI pueda comunicarse
//				correctamente con el acelerometro de la NexysA7. Ademas, guarda la informacion que el Master_SPI
//				lee proveniente del acelerometro ADXL362.
// Parametros: 
//				MAX_WAIT - Maximo tiempo de espera para la maquina temporizada.
//				SIX_MS - Parametro de tiempo, para un reloj de 100MHz corresponde a seis milisegundos.
//				TEN_MS - Parametro de tiempo, para un reloj de 100MHz corresponde a diez milisegundos.
//				FOURTY_MS - Parametro de tiempo, para un reloj de 100MHz corresponde a cuarenta milisegundos.
//              MAX_BYTES_PER_CS - Configurado al numero maximo de bytes que
//              se enviaran durante un solo pulso CS bajo.
// Commentarios adicionales:
//				Base utilizada de los codigos del ramo IPD432, ademas de los repositorios
//				https://github.com/gcarvajalb/IPD432-reference-modules
//				https://github.com/FPGADude/Digital-Design/tree/main/FPGA%20Projects/Nexys%20A7%203-Axis%20Accelerometer%20SPI
//				https://github.com/nandland/spi-master/tree/master
//////////////////////////////////////////////////////////////////////////////////


//Timed Moore machine 

// Module header:-----------------------------
module Comunicacion_Acc
    #(
    parameter MAX_WAIT = 5000000,      					   		 
    parameter SIX_MS = 600000,        						   // Parametros de tiempo:
    parameter TEN_MS = 1000000,        					  	   // 		Estos variaran dependiendo del reloj de entrada y lo que dija la hoja de datos,
    parameter FOURTY_MS = 4000000,    					       // 		de momento estan calculados para un reloj de entrada de 100MHz.
    parameter MAX_BYTES_PER_CS = 2      					   // Debe ser el mismo valor que en el modulo de Master_SPI
    )
    (
	input logic clk, rst, TX_Ready, RX_DV,
	input logic [$clog2(MAX_BYTES_PER_CS+1)-1:0] RX_Count,
	input logic [7:0]  RX_Byte,
	output logic TX_DV, CPOL, CPHA,
	output logic [7:0]  TX_Byte,
	output  logic [$clog2(MAX_BYTES_PER_CS+1)-1:0] TX_Count,   
	output logic [47:0] To_Seven_Seg
	);

 //Declarations:------------------------------
logic TX_DV_next, CPOL_next, CPHA_next;
logic [7:0] TX_Byte_next;
logic [$clog2(MAX_BYTES_PER_CS+1)-1:0] TX_Count_next;
logic [47:0] To_Seven_Seg_next;

 //FSM states type:
 typedef enum logic [17:0] {IDLE, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P} state;
 state pr_state, nx_state;

  //Timer-related declarations:
 const logic [22:0] tmax = MAX_WAIT ;//tmax ? max(T1,T2,...)-1
 logic [22:0] t;

 //Part 3: Statements:---------------------------------------

 //Timer :
 always_ff @(posedge clk, posedge rst)
	if (rst) t <= 0;
	else if (pr_state != nx_state) t <= 0; //reset the timer when state changes
	else if (t != tmax) t <= t + 1;

 //FSM state register:
 always_ff @(posedge clk, posedge rst)
	if (rst) pr_state <= IDLE;
	else pr_state <= nx_state;
 
 //FSM combinational logic:
always_comb begin
nx_state = pr_state;
TX_DV_next = TX_DV;
CPOL_next = CPOL;
CPHA_next = CPHA;
TX_Byte_next = TX_Byte;
TX_Count_next = TX_Count;
To_Seven_Seg_next = To_Seven_Seg;
    
	case (pr_state)
		IDLE: begin
		    TX_Byte_next = 8'h00;
		    CPOL_next = 'b0;
		    CPHA_next = 'b0;
		    TX_DV_next = 'b0;
		    TX_Count_next = 'd0;
			if ( t >= (SIX_MS - 1) ) nx_state = A;
		end
		A: begin
			TX_Byte_next = 8'h0A;
		    TX_DV_next = 'b1;
		    TX_Count_next = 'd3;
			nx_state = B;
		end
		B: begin
		    TX_DV_next = 'b0;
		    if ( TX_Ready ) nx_state = C;
		end
		C: begin
		    TX_Byte_next = 8'h2D;
		    TX_DV_next = 'b1;
			nx_state = D;
		end
		D: begin
		    TX_DV_next = 'b0;
			if ( TX_Ready ) nx_state = E;
		end
        E: begin
		    TX_Byte_next = 8'h02;
		    TX_DV_next = 'b1;
			nx_state = F;
		end
		F: begin
		    TX_DV_next = 'b0;
			if ( t >= (FOURTY_MS - 1) ) nx_state = G;
		end
		G: begin
		    TX_Byte_next = 8'h0B;
		    TX_DV_next = 'b1;
		    TX_Count_next = 'd8;
			nx_state = H;
		end
		H: begin
		    TX_DV_next = 'b0;
			if ( TX_Ready ) nx_state = I;
		end
		I: begin
		    TX_Byte_next = 8'h0E;
		    TX_DV_next = 'b1;
			nx_state = J;
		end
		J: begin
		    TX_DV_next = 'b0;
		    if ( TX_Ready && (RX_Count < 3) ) nx_state = I;
			else if ( TX_Ready && (RX_Count == 3) ) nx_state = K;
			else if ( TX_Ready && (RX_Count == 4) ) nx_state = L;
			else if ( TX_Ready && (RX_Count == 5) ) nx_state = M;
			else if ( TX_Ready && (RX_Count == 6) ) nx_state = N;
			else if ( TX_Ready && (RX_Count == 7) ) nx_state = O;
			else if ( RX_Count == 8 ) nx_state = P;
		end
		K: begin
            To_Seven_Seg_next[7:0] = RX_Byte;
			nx_state = I;
		end
		L: begin
            To_Seven_Seg_next[15:8] = RX_Byte;
			nx_state = I;
		end
		M: begin
            To_Seven_Seg_next[23:16] = RX_Byte;
			nx_state = I;
		end
		N: begin
            To_Seven_Seg_next[31:24] = RX_Byte;
			nx_state = I;
		end
		O: begin
            To_Seven_Seg_next[39:32] = RX_Byte;
			nx_state = I;
		end
		P: begin
            To_Seven_Seg_next[47:40] = RX_Byte;
			if ( t >= (TEN_MS - 1) ) nx_state = G;
		end
		
	endcase
end

 //Optional output register (if required). Adds a FF at the output to prevent the propagation of glitches from comb. logic.
	always_ff @(posedge clk, posedge rst)
		if (rst) begin                //rst might be not needed here
			TX_DV <= 'b0;
			CPOL <= 'b0;
			CPHA <= 'b0;
            TX_Byte <= 8'h00;
            TX_Count <= 'd0;
            To_Seven_Seg <= 'd0;
		end
		else begin
			TX_DV <= TX_DV_next;
			CPOL <= CPOL_next;
			CPHA <= CPHA_next;
            TX_Byte <= TX_Byte_next;
            TX_Count <= TX_Count_next;
            To_Seven_Seg <= To_Seven_Seg_next;
		end

 endmodule