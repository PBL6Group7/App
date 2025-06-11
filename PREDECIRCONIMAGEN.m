function Mout=PREDECIR(Min)
% 1. Cargar modelo
load('modelo_malaria_SVM1.mat');  % Contiene mdl_svm
    % Leer y procesar imagen
    Vivax = imread(Min);
    Vivax_doble = im2double(Vivax);
    BW = imbinarize(Vivax_doble);
    BW = im2double(BW);

    % === segmentCellsStainBased ===
    I = BW;
    if size(I, 3) == 3
        I = rgb2gray(I);
    end
    level = graythresh(I);
    bw = imbinarize(I, level);
    if mean(I(bw)) < mean(I(~bw))
        bw = ~bw;
    end
    bw_clean = imopen(bw, strel('disk', 5));
    bw_clean = imclose(bw_clean, strel('disk', 5));
    bw_clean = imfill(bw_clean, 'holes');

    stats = regionprops(bw_clean, 'Area', 'Centroid', 'EquivDiameter');
    [~, idx] = max([stats.Area]);
    circle_centroid = stats(idx).Centroid;
    circle_radius = stats(idx).EquivDiameter / 2;
    adjusted_radius = max(circle_radius - 15, 0);
    [rows, cols] = size(bw_clean);
    [X, Y] = meshgrid(1:cols, 1:rows);
    fov_mask = (X - circle_centroid(1)).^2 + (Y - circle_centroid(2)).^2 <= adjusted_radius^2;

    BW = BW .* fov_mask;

    % === Extracción de características ===
    hsv_img = rgb2hsv(BW);
    H = hsv_img(:,:,1); S = hsv_img(:,:,2); V = hsv_img(:,:,3);
    mascara_general = (((H >= 0.9) | (H <= 0.1)) & (S > 0.2) & (V > 0.5)) | ...
                      ((H > 0.55) & (H < 0.75) & (S > 0.4));
    mascara_general = bwareaopen(mascara_general, 50);

    cc = bwconncomp(mascara_general);
    stats = regionprops(cc, 'Area', 'Centroid');

    umbral_area_wbc = 1500;
    mascara_wbc = false(size(mascara_general));
    centros_detectados = [];
    indices_wbc = [];

    for j = 1:length(stats)
        if stats(j).Area > umbral_area_wbc
            mascara_wbc(cc.PixelIdxList{j}) = true;
            centros_detectados(end+1, :) = stats(j).Centroid;
            indices_wbc(end+1) = j;
        end
    end

    nombresVariables = {'Paciente', 'Imagen', 'Area', 'Perimetro', 'Excentricidad', ...
        'Extension', 'Eje_Mayor', 'Eje_Menor', 'H_Media'};
    caracteristicas_wbc = cell2table(cell(0, length(nombresVariables)), 'VariableNames', nombresVariables);

    for j = 1:length(indices_wbc)
        idx_cc = indices_wbc(j);
        if idx_cc > numel(cc.PixelIdxList)
            continue;
        end

        pixelList = cc.PixelIdxList{idx_cc};
        mask_single = false(size(mascara_wbc));
        mask_single(pixelList) = true;

        props = regionprops(mask_single, 'Area', 'Perimeter', 'Eccentricity', ...
            'Extent', 'MajorAxisLength', 'MinorAxisLength');

        H_vals = H(mask_single); S_vals = S(mask_single); V_vals = V(mask_single);
        H_media = mean(H_vals);

        new_row = {nombrePaciente, nombreImagen, ...
                   props.Area, props.Perimeter, props.Eccentricity, ...
                   props.Extent, props.MajorAxisLength, ...
                   props.MinorAxisLength, H_media};
        caracteristicas_wbc = [caracteristicas_wbc; new_row];
    end

    diagnostico = 'Sano';  % Default
    if ~isempty(caracteristicas_wbc)
        caracteristicas_wbc.Eje_Ratio    = caracteristicas_wbc.Eje_Mayor ./ (caracteristicas_wbc.Eje_Menor + eps);
        caracteristicas_wbc.Compactitud  = (caracteristicas_wbc.Perimetro.^2) ./ (4 * pi * caracteristicas_wbc.Area + eps);
        caracteristicas_wbc.Circularidad = (4 * pi * caracteristicas_wbc.Area) ./ (caracteristicas_wbc.Perimetro.^2 + eps);

        X_all = caracteristicas_wbc{:, 3:end};
        X_norm = (X_all - mean(X_all)) ./ std(X_all);
        [~, score_pred] = predict(mdl_svm, X_norm);
        prob_pos = score_pred(:, 2);

        umbral = 0.57;
        if mean(prob_pos) > umbral
            diagnostico = 'Malaria';
        end
    end

    % Cambio de paciente
    if ~strcmp(nombrePaciente, pacienteAnterior) && i > 1
        fprintf('→ Paciente: %s - Sano: %d | Malaria: %d\n', pacienteAnterior, sanoPaciente, malariaPaciente);
        sanoPaciente = 0; malariaPaciente = 0;
    end

    fprintf('Paciente: %s | Diagnóstico: %s\n', nombrePaciente, diagnostico);

    if strcmp(diagnostico, 'Sano')
        Sano = Sano + 1;
        sanoPaciente = sanoPaciente + 1;
    elseif strcmp(diagnostico, 'Malaria')
        Malaria = Malaria + 1;
        malariaPaciente = malariaPaciente + 1;
    end

    pacienteAnterior = nombrePaciente;
end

% Resultados finales
fprintf('→ Paciente: %s - Sano: %d | Malaria: %d\n', pacienteAnterior, sanoPaciente, malariaPaciente);
fprintf('\nDetectados %d sanos de %d y %d de malaria de %d\n', Sano, length(archivos_imagen), Malaria, length(archivos_imagen));

Mout=diagnostico;