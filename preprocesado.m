function [Iout,Iimg,Ipar] = preprocesado(Iin)
load('RANmodelo.mat', 'modelo4', 'varNames', 'mu', 'sigma', 'X_train');
I = Iin;

if size(I, 3) == 3
    Igray = rgb2gray(I);
else
    Igray = I;
end

gamma = 0.8; 
I_norm = im2double(Igray);
Iluminaciongamma = I_norm .^ gamma;
img_filtrada = imgaussfilt(Iluminaciongamma);

img_vector = img_filtrada(:);
K=3;
[grupos, centros] = kmeans(img_vector, K, 'Replicates', 3);
segmented = reshape(grupos, size(img_filtrada));

BW = imbinarize(Iluminaciongamma);
BW = ~BW;
negativo = imcomplement(Iluminaciongamma);
IMAGEN = negativo - BW;

img_filtrada = medfilt2(IMAGEN, [3 3]);
img_filtrada = imgaussfilt(img_filtrada, 1.5);

[centers, radii] = imfindcircles(img_filtrada, [2 5], 'ObjectPolarity', 'bright', 'Sensitivity', 0.92, 'EdgeThreshold', 0.1);

% Filtrar por radio
min_radius = 2;
max_radius = 5;
valid_idx = find(radii >= min_radius & radii <= max_radius);
centers = centers(valid_idx, :);
radii = radii(valid_idx);
%%
if isempty(centers)
    resultadoFinal = "No se detectaron parásitos";
    detalles = struct();
else
    numCandidatos = length(radii);

    % Nombres de características esperadas
    predictorNames = {'Intensidad', 'Circularidad', ...
                      'Area', 'Excentricidad', 'R_Mean', 'G_Mean', 'B_Mean', ...
                      'R_Var', 'G_Var', 'B_Var', 'Num_Puntos', 'Densidad_Puntos'};

    caracteristicas = zeros(numCandidatos, numel(predictorNames));

    I_double = im2double(Igray);
    is_rgb = size(I, 3) == 3;

    for j = 1:numCandidatos
        cx = centers(j,1);
        cy = centers(j,2);
        radio = radii(j);

        [x, y] = meshgrid(1:size(Igray, 2), 1:size(Igray, 1));
        mascara = sqrt((x - cx).^2 + (y - cy).^2) <= radio;

        % Intensidad
        radio_muestra = 3;
        mascara_intensidad = sqrt((x - cx).^2 + (y - cy).^2) <= radio_muestra;
        intensidad = mean(I_double(mascara_intensidad), 'omitnan');

        % Forma
        props = regionprops(mascara, 'Circularity', 'Area', 'Eccentricity');
        if isempty(props)
            circularidad = NaN;
            area = NaN;
            excentricidad = NaN;
        else
            circularidad = props.Circularity;
            area = props.Area;
            excentricidad = props.Eccentricity;
        end
        
        % Color
        if is_rgb
            region_r = I(:,:,1).*uint8(mascara);
            region_g = I(:,:,2).*uint8(mascara);
            region_b = I(:,:,3).*uint8(mascara);

            r_vals = double(region_r(mascara));
            g_vals = double(region_g(mascara));
            b_vals = double(region_b(mascara));

            r_mean = mean(r_vals, 'omitnan');
            g_mean = mean(g_vals, 'omitnan');
            b_mean = mean(b_vals, 'omitnan');

            r_var = var(r_vals, 'omitnan');
            g_var = var(g_vals, 'omitnan');
            b_var = var(b_vals, 'omitnan');
        else
            r_mean = NaN; g_mean = NaN; b_mean = NaN;
            r_var = NaN; g_var = NaN; b_var = NaN;
        end

        % Puntos internos
        region = im2double(Igray).*mascara;
        umbral_puntos = graythresh(region(mascara));
        puntos = region > umbral_puntos & mascara;
        num_puntos = sum(puntos(:));
        densidad_puntos = num_puntos / props.Area;

        % Guardar
        caracteristicas(j,:) = [intensidad, ...
                                props.Circularity, props.Area, props.Eccentricity, ...
                                r_mean, g_mean, b_mean, ...
                                r_var, g_var, b_var, ...
                                num_puntos, densidad_puntos];
    end

    % Convertir a tabla y asegurar orden
    tablaCaracteristicas = array2table(caracteristicas, 'VariableNames', predictorNames);
    tablaCaracteristicas = tablaCaracteristicas(:, varNames); % usar orden del modelo

    % Sustituir NaN por media de entrenamiento (mu)
    X_nueva = tablaCaracteristicas{:, varNames};

    % Normalización
    X_nueva_normalized = (X_nueva - mu) ./ sigma;

    clasesPredichas = predict (modelo4, X_nueva_normalized);
    clasesPredichas=categorical(clasesPredichas,{'Falciparum','Vivax'});

    conteos = countcats(clasesPredichas);
    cantidadFalciparum = conteos(1);
    cantidadVivax = conteos(2);

    if cantidadFalciparum > cantidadVivax
        resultadoFinal = sprintf ("Falciparum");
    else 
        resultadoFinal = sprintf ("Vivax");
    end 
    imshow (I)
    hold on
    if ~isempty(centers)
    
        for j = 1:length(clasesPredichas)
            viscircles(centers(j,:), radii(j), 'Color', 'r', 'LineWidth', 1.5);
        end
    end
    hold off;
    
    frame = getframe(gca);      
    I_parasitos = frame.cdata;
end
fprintf('%d',cantidadVivax)
    fprintf('%d',cantidadFalciparum)
if resultadoFinal=="Falciparum"
    Ipar=cantidadFalciparum;
else
    Ipar=cantidadVivax;
end
Iout = resultadoFinal; 
Iimg= I_parasitos;

