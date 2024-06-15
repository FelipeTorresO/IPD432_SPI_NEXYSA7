///////////////////////////////////////////////////////////////////////////////////
// Afiliacion: UTFSM
// Autor: Felipe Torres
// Nombre del modulo: Decoder_AN
// Descripcion: 
//				Se encarga de dar las senales correspondientes al anodo del display.
// Commentarios adicionales:
//				Base utilizada de los codigos del ramo IPD432, ademas de los repositorios
//				https://github.com/gcarvajalb/IPD432-reference-modules
//////////////////////////////////////////////////////////////////////////////////


module Decoder_AN
	(
    input logic [2:0] cuenta,
    output logic [7:0] decoder_out
	);

	always_comb begin
		   case(cuenta)
			   3'd0 : decoder_out = ~8'b00000001;
			   3'd1 : decoder_out = ~8'b00000010;
			   3'd2 : decoder_out = ~8'b00000100;
			   3'd3 : decoder_out = ~8'b00001000;
			   3'd4 : decoder_out = ~8'b00010000;
			   3'd5 : decoder_out = ~8'b00100000;
			   3'd6 : decoder_out = ~8'b01000000;
			   3'd7 : decoder_out = ~8'b10000000;
			   default : decoder_out = ~8'b00000000;
		   endcase
	end
	endmodule