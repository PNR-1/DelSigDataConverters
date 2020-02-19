%% %%%%%%%MOD 1
%
%   u ----> (+) --(er)--> (z^-1)/(1-z^-1) ---> y ---> (Quantizer) -----> v
%             ^ (-)                                                |
%             |                                                    |
%             |                                                    |
%             |                                                    |
%             ------------------------------------------------------
%% %%%%%%%%
Delta = 1;
NumLevels = 5;
Type = 'MidRise';

x = 1.5121+1/2^14;
yn = 0; yn_1 = 0;
ern = 0; ern_1 = 0;
v = zeros(1,1e6);

for i = 2:length(v)
    yn_1 = yn;
    ern_1 = ern;
    
    ern = x - v(i-1);
    yn = yn_1 + ern_1;
    
    [v(i),overload,Qmin,Qmax] = util_quantizer(yn,Delta,NumLevels,Type);
    v(i) = v(i) + 1;
end
