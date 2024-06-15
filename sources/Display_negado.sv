`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Afiliacion: UTFSM
// Autor: Felipe Torres
// Nombre del modulo: Display_negado
// Descripcion:
//				Modulo que traduce algun digito en formato BCD a las
//				senales requeridas para mostrar ese digito en el display.		
// Commentarios adicionales:
//				Base utilizada de los codigos del ramo IPD432, ademas de los repositorios
//				https://github.com/gcarvajalb/IPD432-reference-modules
//////////////////////////////////////////////////////////////////////////////////


module Display_negado
	(
    input logic [3:0] BCD,
    output logic [6:0] Seven
    );
    
    always_comb begin
        case(BCD)
       4'd0  : Seven = 7'b1000000;//0
       4'd1  : Seven = 7'b1111001;//1
       4'd2  : Seven = 7'b0100100;//2
       4'd3  : Seven = 7'b0110000;//3
       4'd4  : Seven = 7'b0011001;//4
       4'd5  : Seven = 7'b0010010;//5
       4'd6  : Seven = 7'b0000010;//6
       4'd7  : Seven = 7'b1111000;//7
       4'd8  : Seven = 7'b0000000;//8
       4'd9  : Seven = 7'b0010000;//9 
       default : Seven = 7'b1111111;//todo apagado
        
       endcase
    end
        
endmodule
