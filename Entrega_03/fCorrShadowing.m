%%file fCorrShadowing.m
function mtShadowingCorr = fCorrShadowing(mtPoints,dShad,dAlphaCorr,dSigmaShad,dDimXOri,dDimYOri)
% INPUTS:
%   mtPoints: Matriz de números complexos com os pontos de medição
%   dShad: Distância de descorrelação do shadowing
%   dSigmaShad: Desvio padrão do shadowing Lognormal
%   dAlphaCorr: Coeficiente de correlação do sombreamento entre ERBs
%   dDimXOri: Dimensão X do grid em metros
%   dDimYOri: Dimensão Y do grid em metros
%
% Matriz de pontos equidistantes de dShad em dShad
dDimYS = ceil(dDimYOri+mod(dDimYOri,dShad));                      % Ajuste de dimensão para medir toda a dimensão do grid
dDimXS = ceil(dDimXOri+mod(dDimXOri,dShad));
[mtPosxShad,mtPosyShad] = meshgrid(0:dShad:dDimXS, 0:dShad:dDimYS);
mtPosShad = mtPosxShad+j*mtPosyShad;
%
% Amostras de sombremento para os pontos de grade
% Matrizes com amostras de shadowing independentes
% 7 matrizes, uma cada cada ERB
% 1 matriz para o ambiente
for iMap = 1:8
    mtShadowingSamples(:,:,iMap) = dSigmaShad*randn(size(mtPosyShad));
end

[dSizel, dSizec] = size(mtPoints);
for il = 1: dSizel
    for ic = 1: dSizec
        %
        % Ponto de medição alvo (vamos localiza-lo no novo grid e plotar os quatro pontos que o circundam) - escolhido ao acaso
        dshadPoint = mtPoints(il,ic);
        %
        % Achar a posição do ponto de medição na matriz de shadowing correlacionado
        dXIndexP1 = real(dshadPoint)/dShad;
        dYIndexP1 = imag(dshadPoint)/dShad;
        %
        % Cálculo dos demais pontos depende de:
        %   (i) se o ponto de medição é um ponto de shadowing descorrelacionado
        %   (i) se o ponto está na borda lateral direita do grid e no canto superior do grid;
        %   (ii) se o ponto está na borda lateral direita do grid;
        %   (iii) se o ponto está na borda superior do grid;
        %   (iv)  se o ponto está no meio do grid.
        if (mod(dXIndexP1,1) == 0 && mod(dYIndexP1,1) == 0)
            % O ponto de medição é um ponto de grade
            dXIndexP1 = floor(dXIndexP1)+1;
            dYIndexP1 = floor(dYIndexP1)+1;
            % Amostra de sombreamento do ambiente
            dShadowingC = mtShadowingSamples(dYIndexP1,dXIndexP1,8);
            % Amostra do sombreamento de cada ERB
            for iMap = 1:7
                dShadowingERB = mtShadowingSamples(dYIndexP1,dXIndexP1,iMap);
                mtShadowingCorr(il,ic,iMap) = sqrt(dAlphaCorr)*dShadowingC + sqrt(1-dAlphaCorr)*dShadowingERB;
            end
        else
            % Índice na matriz do primeiro ponto próximo
            dXIndexP1 = floor(dXIndexP1)+1;
            dYIndexP1 = floor(dYIndexP1)+1;
            if (dXIndexP1 == size(mtPosyShad,2)  && dYIndexP1 == size(mtPosyShad,1) )
                % Ponto de medição está na borda da lateral direta do grid
                % e no canto superior
                % P2 - P1
                % |    |
                % P4 - P3
                %
                dXIndexP2 = dXIndexP1-1;
                dYIndexP2 = dYIndexP1;
                dXIndexP4 = dXIndexP1-1;
                dYIndexP4 = dYIndexP1-1;
                dXIndexP3 = dXIndexP1;
                dYIndexP3 = dYIndexP1-1;
                %
            elseif (dXIndexP1 == size(mtPosyShad,2))
                % Ponto de medição está na borda da lateral direta do grid
                % P4 - P3
                % |    |
                % P2 - P1
                %
                dXIndexP2 = dXIndexP1-1;
                dYIndexP2 = dYIndexP1;
                dXIndexP4 = dXIndexP1-1;
                dYIndexP4 = dYIndexP1+1;
                dXIndexP3 = dXIndexP1;
                dYIndexP3 = dYIndexP1+1;
            elseif (dYIndexP1 == size(mtPosyShad,1))
                % Ponto de medição está na borda superior do grid
                % P1 - P2
                % |    |
                % P3 - P4
                %
                dXIndexP2 = dXIndexP1+1;
                dYIndexP2 = dYIndexP1;
                %
                dXIndexP4 = dXIndexP1+1;
                dYIndexP4 = dYIndexP1-1;
                %
                dXIndexP3 = dXIndexP1;
                dYIndexP3 = dYIndexP1-1;
                %
            else
                % P4 - P3
                % |    |
                % P1 - P2
                %
                %
                dXIndexP2 = dXIndexP1+1;
                dYIndexP2 = dYIndexP1;
                %
                dXIndexP4 = dXIndexP1+1;
                dYIndexP4 = dYIndexP1+1;
                %
                dXIndexP3 = dXIndexP1;
                dYIndexP3 = dYIndexP1+1;
            end
            %
            % Distâncias para regressão linear
            dDistX = (mod(real(dshadPoint),dShad))/dShad;
            dDistY = (mod(imag(dshadPoint),dShad))/dShad;
            % Ajuste do desvio padrão devido a regressão linear
            dStdNormFactor = sqrt( (1 - 2 * dDistY + 2 * (dDistY^2) )*(1 - 2 * dDistX + 2 * (dDistX^2) ) );
            %
            % Amostra do sombreamento do mapa comum
            dSample1 = mtShadowingSamples(dYIndexP1,dXIndexP1,8);
            dSample2 = mtShadowingSamples(dYIndexP2,dXIndexP2,8);
            dSample3 = mtShadowingSamples(dYIndexP3,dXIndexP3,8);
            dSample4 = mtShadowingSamples(dYIndexP4,dXIndexP4,8);
            dShadowingC = ( (1-dDistY)*[dSample1*(1-dDistX) + dSample2*(dDistX)] +...
                (dDistY)*[dSample3*(1-dDistX) + dSample4*(dDistX)])/dStdNormFactor;
            % Amostra do sombreamento de cada ERB
            for iMap = 1:7
                dSample1 = mtShadowingSamples(dYIndexP1,dXIndexP1,iMap);
                dSample2 = mtShadowingSamples(dYIndexP2,dXIndexP2,iMap);
                dSample3 = mtShadowingSamples(dYIndexP3,dXIndexP3,iMap);
                dSample4 = mtShadowingSamples(dYIndexP4,dXIndexP4,iMap);
                dShadowingERB = ( (1-dDistY)*[dSample1*(1-dDistX) + dSample2*(dDistX)] +...
                    (dDistY)*[dSample3*(1-dDistX) + dSample4*(dDistX)])/dStdNormFactor;
                mtShadowingCorr(il,ic,iMap) = sqrt(dAlphaCorr)*dShadowingC + sqrt(1-dAlphaCorr)*dShadowingERB;
            end
        end
    end
end
end