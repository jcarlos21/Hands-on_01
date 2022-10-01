% Entrada de parâmetros
dR = 200;                                                  % Raio do Hexágono
dFc = 800;                                                 % Frequência da portadora
dShad = 50;                                                % Distância de descorrelação do shadowing
dSigmaShad = 8;                                            % Desvio padrão do sombreamento lognormal
dAlphaCorr = 0.5;                                          % Coeficiente de correlação do sombreamento entre ERBs (sombreamento correlacionado)
% Cálculos de outras variáveis que dependem dos parâmetros de entrada
%dPasso = ceil(dR/10);                                     % Resolução do grid: distância entre pontos de medição
dPasso = 10;
dRMin = dPasso;                                            % Raio de segurança
dIntersiteDistance = 2*sqrt(3/4)*dR;                       % Distância entre ERBs (somente para informação)
%
% Cálculos de outras variáveis que dependem dos parâmetros de entrada
dDimXOri = 5*dR;                                           % Dimensão X do grid
dDimYOri = 6*sqrt(3/4)*dR;                                 % Dimensão Y do grid
dPtdBm = 57;                                               % EIRP (incluindo ganho e perdas) (https://pt.slideshare.net/naveenjakhar12/gsm-link-budget)
dPtLinear = 10^(dPtdBm/10)*1e-3;                           % EIRP em escala linear
dHMob = 5;                                                 % Altura do receptor
dHBs = 30;                                                 % Altura do transmissor
dAhm = 3.2*(log10(11.75*dHMob)).^2 - 4.97;                 % Modelo Okumura-Hata: Cidade grande e fc  >= 400MHz
% Vetor com posições das BSs (grid Hexagonal com 7 células, uma célula central e uma camada de células ao redor)
vtBs = [ 0 ];
dOffset = pi/6;
for iBs = 2 : 7
    vtBs = [ vtBs dR*sqrt(3)*exp( j * ( (iBs-2)*pi/3 + dOffset ) ) ];
end
vtBs = vtBs + (dDimXOri/2 + j*dDimYOri/2);                        % Ajuste de posição das bases (posição relativa ao canto inferior esquerdo)
%
% Matriz de referência com posição de cada ponto do grid (posição relativa ao canto inferior esquerdo)
dDimY = ceil(dDimYOri+mod(dDimYOri,dPasso));                      % Ajuste de dimensão para medir toda a dimensão do grid
dDimX = ceil(dDimXOri+mod(dDimXOri,dPasso));                      % Ajuste de dimensão para medir toda a dimensão do grid
[mtPosx,mtPosy] = meshgrid(0:dPasso:dDimX, 0:dPasso:dDimY);
mtPontosMedicao = mtPosx + j*mtPosy;
% Iniciação da Matriz de com a pontência de recebida máxima em cada ponto
% medido. Essa potência é a maior entre as 7 ERBs.
mtPowerFinaldBm = -inf*ones(size(mtPosy));
mtPowerFinalShaddBm = -inf*ones(size(mtPosy));
mtPowerFinalShadCorrdBm = -inf*ones(size(mtPosy));
%
% Calcula o sombreamento correlacionado
mtShadowingCorr = fCorrShadowing(mtPontosMedicao,dShad,dAlphaCorr,dSigmaShad,dDimXOri,dDimYOri);
%
% Calcular O REM de cada ERB e aculumar a maior potência em cada ponto de medição
for iBsD = 1 : length(vtBs)                                 % Loop nas 7 ERBs
    % Matriz 3D com os pontos de medição de cada ERB. Os pontos são
    % modelados como números complexos X +jY, sendo X a posição na abcissa e Y, a posição no eixo das ordenadas
    mtPosEachBS = mtPontosMedicao-(vtBs(iBsD));
    mtDistEachBs = abs(mtPosEachBS);              % Distância entre cada ponto de medição e a sua ERB
    mtDistEachBs(mtDistEachBs < dRMin) = dRMin;             % Implementação do raio de segurança
    % Okumura-Hata (cidade urbana) - dB
    mtPldB = 69.55 + 26.16*log10(dFc) + (44.9 - 6.55*log10(dHBs))*log10(mtDistEachBs/1e3) - 13.82*log10(dHBs) - dAhm;
    % Shadowing independente em cada ponto
    mtShadowing = dSigmaShad*randn(size(mtPosy));
    % Potências recebidas em cada ponto de medição sem shadowing
    mtPowerEachBSdBm = dPtdBm - mtPldB;
    % Potências recebidas em cada ponto de medição com shadowing
    mtPowerEachBSShaddBm = dPtdBm - mtPldB + mtShadowing;
    % Potências recebidas em cada ponto de medição com shadowing
    % correlacionado
    mtPowerEachBSShadCorrdBm = dPtdBm - mtPldB + mtShadowingCorr(:,:,iBsD);
    % Cálulo da maior potência em cada ponto de medição sem shadowing
    mtPowerFinaldBm = max(mtPowerFinaldBm,mtPowerEachBSdBm);
    % Cálulo da maior potência em cada ponto de medição com shadowing
    mtPowerFinalShaddBm = max(mtPowerFinalShaddBm,mtPowerEachBSShaddBm);
    % Cálulo da maior potência em cada ponto de medição com shadowing
    mtPowerFinalShadCorrdBm = max(mtPowerFinalShadCorrdBm,mtPowerEachBSShadCorrdBm);
end
% Plot da REM de todo o grid (composição das 7 ERBs) sem shadowing
figure;
pcolor(mtPosx,mtPosy,mtPowerFinaldBm);
colormap(hsv);
colorbar;
fDrawDeploy(dR,vtBs);
axis equal;
title(['Todas as 7 ERB sem shadowing']);
%
% Plot da REM de todo o grid (composição das 7 ERBs) sem shadowing
figure;
pcolor(mtPosx,mtPosy,mtPowerFinalShaddBm);
colormap(hsv);
colorbar;
fDrawDeploy(dR,vtBs);
axis equal;
title(['Todas as 7 ERB com shadowing']);
%
% Plot da REM de todo o grid (composição das 7 ERBs) com shadowing
% correlacionado
figure;
pcolor(mtPosx,mtPosy,mtPowerFinalShadCorrdBm);
colormap(hsv);
colorbar;
fDrawDeploy(dR,vtBs);
axis equal;
title(['Todas as 7 ERB com shadowing correlacionado']);

disp(['Desvio padrão: ' num2str(std(mtShadowingCorr(:)))])