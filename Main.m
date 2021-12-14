% Load KMC parameters
load('KMC.mat');
% Load AT parameters
load('AT.mat');
% Load ACRG parameters
load('ACRG.mat');
% Get image file names
D = dir('*.jpg'); 

for i=1:numel(D)
    % Read original image
    I = imread(D(i).name);
    % Convert to grayscale
    G = im2gray(I);
    % Position image
    subplot(5,4,4*i-3); imshow(G);
    % Remove noise by AWF
    W = wiener2(G);
    % Enhance contrast by CLAHE
    C = adapthisteq(W,'ClipLimit',KMC.l(i));
    % Segment image by KMC
    L = imsegkmeans(C,KMC.k(i),'Threshold',KMC.t(i));
    B = (L == KMC.L(i));
    % Remove irrelevant objects
    SE = strel('disk',KMC.r(i));
    S = imopen(B,SE);
    % Remove incomplete nanotubes
    S = imclearborder(S);
    % Position image
    subplot(5,4,4*i-2); imshow(S); 
    % Enhance contrast by CLAHE
    C = adapthisteq(W,'ClipLimit',AT.l(i));
    % Segment image by AT
    T = adaptthresh(C,AT.s(i));
    B = not(imbinarize(C,T));
    % Remove irrelevant objects
    SE = strel('disk',AT.r(i));
    S = imopen(B,SE);
    % Remove incomplete nanotubes
    S = imclearborder(S);
    % Position image
    subplot(5,4,4*i-1); imshow(S); 
    % Enhance contrast by CLAHE
    C = adapthisteq(W,'ClipLimit',ACRG.l(i));
    % Segment image by ACRG
    mask = zeros(size(C));
    mask(ACRG.N(i):end-ACRG.N(i),ACRG.N(i):end-ACRG.N(i)) = 1;
    B = activecontour(C,mask,ACRG.n(i),'Chan-Vese','ContractionBias',ACRG.b(i));
    % Remove irrelevant objects
    SE = strel('disk',ACRG.r(i));
    if(i~=5)
    S = imopen(B,SE);
    else
    S = not(imopen(B,SE));
    end
    % Remove incomplete nanotubes
    S = imclearborder(S);
    % Position image
    subplot(5,4,4*i); imshow(S); 
end
subplot(5,4,1);
title('Image')
subplot(5,4,2);
title('KMC')
subplot(5,4,3);
title('AT')
subplot(5,4,4);
title('ACRG')