Title = 'Inner diameter measurement of aligned TiO2 nanotubes by computational image analysis';
figure('NumberTitle', 'off', 'Name', Title);
% Method parameters
load('KMC.mat');
load('AT.mat');
load('ACRG.mat');
% Conversion factors
F = [6.25,7.02,4,3.16,3.16];
D = dir('*.jpg');
for i=1:numel(D)
    %% Image acquisition
    I = imread(D(i).name);
    % Preprocessing
    G = im2gray(I);
    %% Image enhancement
    % Noise removal
    W = wiener2(G); j=1;
    for m = ["KMC","AT","ACRG"]
        % Contrast enhancement
        C = adapthisteq(W,'ClipLimit',eval(m+".l(i)"));
        % Show enhanced image
        subplot(5,4,4*i-3); 
        imshow(C); xlabel("("+D(i).name(1)+")");
        %% Segmentation
        if strcmp(m,"KMC")
            % K-means++ clustering
            L = imsegkmeans(C,KMC.k(i),'Threshold',KMC.t(i));
            B = (L == KMC.L(i));
        elseif strcmp(m,"AT")
            % Adaptive thresholding
            T = adaptthresh(C,AT.s(i));
            B = not(imbinarize(C,T));
        else
            % Active contours region growing
            mask = zeros(size(C));
            mask(ACRG.N(i):end-ACRG.N(i),ACRG.N(i):end-ACRG.N(i)) = 1;
            B = activecontour(C,mask,ACRG.n(i),'Chan-Vese','ContractionBias',ACRG.b(i));
        end
        % Postprocessing operations
        % Remove irrelevant objects
        SE = strel('disk',eval(m+".r(i)"));
        S = imopen(B,SE);
        if(i==5 && strcmp(m,"ACRG"))
            S = not(S);
        end        
        % Remove incomplete nanotubes
        S = imclearborder(S);
        % Show segmented image
        subplot(5,4,4*i-3+j); 
        imshow(S); j=j+1;
        %% Feature extraction
        CC = bwconncomp(S);
        % Inner area
        A = bwarea(S)/CC.NumObjects;
        % Inner diameter
        Di = sqrt(((A*F(i))*4)/pi);
        Di = fix(Di*100)/100;
        xlabel(sprintf('Di = %.2f nm',Di));
    end
end
% Add titles to plots
subplot(5,4,1); title('Enhanced image');
subplot(5,4,2); title('KMC');
subplot(5,4,3); title('AT');
subplot(5,4,4); title('ACRG');