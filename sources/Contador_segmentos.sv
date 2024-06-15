`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Afiliacion: UTFSM
// Autor: Felipe Torres
// Nombre del modulo: Decoder_AN
// Descripcion: 
//				Contador simple.
// Commentarios adicionales:
//				Base utilizada de los codigos del ramo IPD432, ademas de los repositorios
//				https://github.com/gcarvajalb/IPD432-reference-modules
//////////////////////////////////////////////////////////////////////////////////

module Contador_segmentos(
    input logic clk, reset,
    output logic [2:0] cuenta 
    );

always_ff @(posedge clk or posedge reset) begin

        if (reset)begin
            cuenta  <= 3'b0;
        end
        
        else begin
        cuenta <= cuenta + 1;
        end
        
end

endmodule
