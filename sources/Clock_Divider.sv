///////////////////////////////////////////////////////////////////////////////////
// Afiliacion: UTFSM
// Autor: Felipe Torres
// Nombre del modulo: Clock_Divider
// Descripcion: 
//				A partir de un reloj de entrada se genera un reloj de salida.
// Commentarios adicionales:
//				Base utilizada de los codigos del ramo IPD432, ademas de los repositorios
//				https://github.com/gcarvajalb/IPD432-reference-modules
//////////////////////////////////////////////////////////////////////////////////

module Clock_Divider
    #(parameter f_in=100000000
    ,parameter f_out=1000)
    (input logic clk_in,
     input logic reset,
     output logic clk_out);
 
localparam COUNTER_MAX = (f_in/(2*f_out)) - 1;
localparam DELAY_WIDTH = $clog2(COUNTER_MAX);
logic [DELAY_WIDTH-1:0] counter = 'd0;

always_ff @(posedge clk_in) begin

    if(reset==1'b1)begin							// Reset sincrónico, setea el contador y la salida a un valor conocido
        counter<= 'd0;
        clk_out<= 0;
        end 
    else 
        if (counter==COUNTER_MAX-1)begin			// Resetea el contador e invierte la salida
            counter<='d0;
            clk_out<=~clk_out;
        end

        else begin 									// Incrementa el contador y mantiene la salida
            counter <= counter + 'd1;
            clk_out <= clk_out;
        end
end
endmodule