clear all;clc;close all;                                   % Limpa variáveis, limpa tela e fecha todas as figuras

% Entrada de parâmetros
dR = 5e3; % Raio do Hexágono
% Cálculos de outras variáveis que dependem dos parâmetros de entrada
dPasso = ceil(dR/10);                                      % Resolução do grid: distância entre pontos de medição
dIntersiteDistance = 2*sqrt(3/4)*dR;                       % Distância entre ERBs (somente para informação)
dDimX = 5*dR;                                              % Dimensão X do grid
dDimY = 6*sqrt(3/4)*dR;                                    % Dimensão Y do grid
% Vetor com posições das BSs (grid Hexagonal com 7 células, uma célula central e uma camada de células ao redor)
vtBs = [ 0 ];
dOffset = pi/6;
for iBs = 2 : 7
    vtBs = [ vtBs dR*sqrt(3)*exp( j * ( (iBs-2)*pi/3 + dOffset ) ) ];
end
vtBs = vtBs + (dDimX/2 + j*dDimY/2);                        % Ajuste de posição das bases (posição relativa ao canto inferior esquerdo)
%
% Matriz de referência com posição de cada ponto do grid (posição relativa ao canto inferior esquerdo)
dDimY = dDimY+mod(dDimY,dPasso);                           % Ajuste de dimensão para medir toda a dimensão do grid
dDimX = dDimX+mod(dDimX,dPasso);                           % Ajuste de dimensão para medir toda a dimensão do grid
[mtPosx,mtPosy] = meshgrid(0:dPasso:dDimX, 0:dPasso:dDimY);
%
% Calcular os pontos de medição relativos de cada ERB
for iBsD = 1 : length(vtBs)                                 % Loop nas 7 ERBs
    % Matriz 3D com os pontos de medição de cada ERB. Os pontos são
    % modelados como números complexos X +jY, sendo X a posição na abcissa e Y, a posição no eixo das ordenadas
    mtPosEachBS(:,:,iBsD)=(mtPosx + j*mtPosy)-(vtBs(iBsD));
    % Plot da posição relativa dos pontos de medição de cada ERB individualmente
    figure;
    plot(mtPosEachBS(:,:,iBsD),'bo');
    hold on;
    fDrawDeploy(dR,vtBs-vtBs(iBsD))
    axis equal;
    title(['ERB ' num2str(iBsD)]);
end