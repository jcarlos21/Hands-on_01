clear; clc; close all;                                         % Limpa variáveis, limpa tela e fecha todas as figuras

vtFc = [800 900 1800 1900 2100];
dR = [12e3 12e3 12e3 12e3 12e3];                               % Raio máximo da celula
dOutRate = [12 12 12 12 12];                                   % Condição para entrar no laço While


for iFc = 1:length(vtFc)
    dFc = vtFc(iFc);

    while (dOutRate(iFc)>10)

        % Entrada de parâmetros
        % Cálculos de outras variáveis que dependem dos parâmetros de entrada
        dPasso = ceil(dR(iFc)/50);                                 % Resolução do grid: distância entre pontos de medição
        dRMin = dPasso;                                            % Raio de segurança
        dIntersiteDistance = 2*sqrt(3/4)*dR(iFc);                  % Distância entre ERBs (somente para informação)
        dDimX = 5*dR(iFc);                                         % Dimensão X do grid
        dDimY = 6*sqrt(3/4)*dR(iFc);                               % Dimensão Y do grid
        dPtdBm = 57;                                               % EIRP (incluindo ganho e perdas) (https://pt.slideshare.net/naveenjakhar12/gsm-link-budget)
        dPtLinear = 10^(dPtdBm/10)*1e-3;                           % EIRP em escala linear
        dSensitivity = -104;                                       % Sensibilidade do receptor (http://www.comlab.hut.fi/opetus/260/1v153.pdf)
        dHMob = 5;                                                 % Altura do receptor
        dHBs = 30;                                                 % Altura do transmissor
        dAhm = 3.2*(log10(11.75*dHMob)).^2 - 4.97;                 % Modelo Okumura-Hata: Cidade grande e fc  >= 400MHz
        %
        % Vetor com posições das BSs (grid Hexagonal com 7 células, uma célula central e uma camada de células ao redor)
        vtBs = [ 0 ];
        dOffset = pi/6;
        for iBs = 2 : 7
            vtBs = [ vtBs dR(iFc)*sqrt(3)*exp( j * ( (iBs-2)*pi/3 + dOffset ) ) ];
        end
        vtBs = vtBs + (dDimX/2 + j*dDimY/2);                       % Ajuste de posição das bases (posição relativa ao canto inferior esquerdo)
        %
        % Matriz de referência com posição de cada ponto do grid (posição relativa ao canto inferior esquerdo)
        dDimY = ceil(dDimY+mod(dDimY,dPasso));                     % Ajuste de dimensão para medir toda a dimensão do grid
        dDimX = ceil(dDimX+mod(dDimX,dPasso));                     % Ajuste de dimensão para medir toda a dimensão do grid
        [mtPosx,mtPosy] = meshgrid(0:dPasso:dDimX, 0:dPasso:dDimY);
        %
        % Iniciação da Matriz de com a pontência de recebida máxima em cada ponto
        % medido. Essa potência é a maior entre as 7 ERBs.
        mtPowerFinaldBm = -inf*ones(size(mtPosy));
        % Calcular O REM de cada ERB e aculumar a maior potência em cada ponto de medição
        for iBsD = 1 : length(vtBs)                                % Loop nas 7 ERBs
            % Matriz 3D com os pontos de medição de cada ERB. Os pontos são
            % modelados como números complexos X +jY, sendo X a posição na abcissa e Y, a posição no eixo das ordenadas
            mtPosEachBS =(mtPosx + j*mtPosy)-(vtBs(iBsD));
            mtDistEachBs = abs(mtPosEachBS);                       % Distância entre cada ponto de medição e a sua ERB
            mtDistEachBs(mtDistEachBs < dRMin) = dRMin;            % Implementação do raio de segurança
            % Okumura-Hata (cidade urbana) - dB
            mtPldB = 69.55 + 26.16*log10(dFc) + (44.9 - 6.55*log10(dHBs))*log10(mtDistEachBs/1e3) - 13.82*log10(dHBs) - dAhm;
            mtPowerEachBSdBm = dPtdBm - mtPldB;                     % Potências recebidas em cada ponto de medição
            % Cálulo da maior potência em cada ponto de medição
            mtPowerFinaldBm = max(mtPowerFinaldBm,mtPowerEachBSdBm);
        end
        %
        % Outage (limite 10%)
        dOutRate(iFc) = 100*length(find(mtPowerFinaldBm < dSensitivity))/numel(mtPowerFinaldBm);

        if (dOutRate(iFc) > 10)
            dR(iFc) = dR(iFc)-10;
        end
    end

    disp(['Frequência da portadora = ' num2str(dFc)]);
    disp(['Taxa de outage = ' num2str(dOutRate(iFc)) ' %']);
    disp(['Raio celular aproximado = ' num2str(dR(iFc))])
    disp(['-------------------------------'])
end