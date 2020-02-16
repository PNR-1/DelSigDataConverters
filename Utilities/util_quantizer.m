function [y_out,overload,Qmin,Qmax] = util_quantizer(y_in,Delta,NumLevels,Type)

%% %%%%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT VARIABLES
%yout       -> Quantised Version of y_in
%overload   -> If=1, value was clipped because it was OUT-OF-BOUNDS for
                                                             %Quantiser
%Qmin       -> Lower Limit of Quantiser Input Linear Range
%Qmax       -> Upper Limit of Quantiser Input Linear Range
%% INPUT VARIABLES
%y_in       -> analog input, either variable or (1xn)array
%Delta      -> Quantization step size (LSB size)
%NumLevels  -> Number of levels of the Quantizer
%Type       -> 'MidRise', 'MidTread'
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y_in = -10:0.01:10;
Delta = 1;
NumLevels = 8;
Type = 'MidRise';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creating Limits for Quantiser
M = NumLevels - 1;
correctionF = Delta/2;
x_lowLimVariables = -(M+1)*(Delta/2):Delta:(M+1)*(Delta/2);
if(strcmp(Type,'MidRise') && ~(ismember(0,x_lowLimVariables)))
        x_lowLimVariables = x_lowLimVariables - Delta/2;
end

if(strcmp(Type,'MidTread') && ismember(0,x_lowLimVariables))
        x_lowLimVariables = x_lowLimVariables - Delta/2;
end


tempVar = 0;

y_out = (x_lowLimVariables(1)*1e2)*ones(1,length(y_in));
overload = zeros(1,length(y_in));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% START QUANTIZATION
Qmin = x_lowLimVariables(1);
Qmax = x_lowLimVariables(end);
for i=1:length(y_in)
    if(y_in(i) >= x_lowLimVariables(end))
        overload(i) = 1;
        y_out(i) = x_lowLimVariables(end-1)+correctionF;
    elseif(y_in(i) <= x_lowLimVariables(1))
            overload(i) = 1;
            y_out(i) = x_lowLimVariables(1)+correctionF;
    else
        tempVar = floor( (y_in(i) - x_lowLimVariables(1))/Delta) + 1;
        y_out(i) = x_lowLimVariables(tempVar)+correctionF;
    end  %if   
end %end for
clear tempVar;
end% END FUNCTION