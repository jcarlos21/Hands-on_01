close all;clear all;clc;
% Entrada de parâmetros
dR = 200;                                                  % Raio do Hexágono
dShad = 50;                                                % Distância de descorrelação do shadowing
dPasso = 7;                                                % Distância entre pontos de medição
dSigmaShad = 8;                                            % Desvio padrão do sombreamento lognormal
% Cálculos de outras variáveis que dependem dos parâmetros de entrada
dDimXOri = 5*dR;                                              % Dimensão X do grid
dDimYOri = 6*sqrt(3/4)*dR;                                    % Dimensão Y do grid
%
% Matriz de referência com posição de cada ponto do grid (posição relativa ao canto inferior esquerdo)
dDimY = ceil(dDimYOri+mod(dDimYOri,dPasso));                      % Ajuste de dimensão para medir toda a dimensão do grid
dDimX = ceil(dDimXOri+mod(dDimXOri,dPasso));                      % Ajuste de dimensão para medir toda a dimensão do grid
[mtPosx,mtPosy] = meshgrid(0:dPasso:dDimX, 0:dPasso:dDimY);
mtPontosMedicao = mtPosx + j*mtPosy;
%
% Ponto de medição alvo (vamos localiza-lo no novo grid e plotar os quatro pontos que o circundam) - escolhido ao acaso
dshadPoint = mtPontosMedicao(12,12);
%
% Matriz de pontos equidistantes de dShad em dShad
dDimYS = ceil(dDimYOri+mod(dDimYOri,dShad));                      % Ajuste de dimensão para medir toda a dimensão do grid
dDimXS = ceil(dDimXOri+mod(dDimXOri,dShad)); 
[mtPosxShad,mtPosyShad] = meshgrid(0:dShad:dDimXS, 0:dShad:dDimYS);
mtPosShad = mtPosxShad+j*mtPosyShad;
% Amostras de sombremento para os pontos de grade
mtShadowingSamples = dSigmaShad*randn(size(mtPosyShad));
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
    plot(complex(mtPosShad(dYIndexP1,dXIndexP1)),'g*');
    disp('O ponto de medição é um ponto de grade');
    % Amostra de sombreamento
    dShadowingC = mtShadowingSamples(dYIndexP1,dXIndexP1);
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
    % Plot dos pontos de grade
    plot(complex(mtPosShad),'ko')
    hold on;
    %
    % Plot do ponto de medição (quadrado vermelho)
    plot(complex(dshadPoint),'sr')
    %
    % Plot dos quadtro pontos de grade que circundam o ponto de medição
    mt4Poitns = complex([mtPosShad(dYIndexP1,dXIndexP1)...
        mtPosShad(dYIndexP2,dXIndexP2)...
        mtPosShad(dYIndexP3,dXIndexP3) ...
        mtPosShad(dYIndexP4,dXIndexP4)]);
    plot(mt4Poitns,'b*');
    axis equal;
    %
    % Zoom nos pontos próximos ao ponto investigado
    axis([-2*dShad+real(mtPosShad(dYIndexP3,dXIndexP3))...
        2*dShad+real(mtPosShad(dYIndexP4,dXIndexP4))...
        -2*dShad+imag(mtPosShad(dYIndexP3,dXIndexP3))...
        2*dShad+imag(mtPosShad(dYIndexP1,dXIndexP1))]);
    %
    % Distâncias para regressão linear
    dDistX = (mod(real(dshadPoint),dShad))/dShad;
    dDistY = (mod(imag(dshadPoint),dShad))/dShad;
    disp(['X = ' num2str(dDistX) ' e Y = ' num2str(dDistY)])
    % Ajuste do desvio padrão devido a regressão linear
    dStdNormFactor = sqrt( (1 - 2 * dDistY + 2 * (dDistY^2) )*(1 - 2 * dDistX + 2 * (dDistX^2) ) );
    %
    % Amostras do sombreamento para os quatro pontos de grade
    dSample1 = mtShadowingSamples(dYIndexP1,dXIndexP1);
    dSample2 = mtShadowingSamples(dYIndexP2,dXIndexP2);
    dSample3 = mtShadowingSamples(dYIndexP3,dXIndexP3);
    dSample4 = mtShadowingSamples(dYIndexP4,dXIndexP4);
    dShadowingC = ( (1-dDistY)*[dSample1*(1-dDistX) + dSample2*(dDistX)] +...
        (dDistY)*[dSample3*(1-dDistX) + dSample4*(dDistX)])/dStdNormFactor;
end
disp(['O Sombreamento é ' num2str(dShadowingC) ' dB'])