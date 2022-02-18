[x,r] =  geotiffread('xingbinqu_im.tif'); %%%%%%%%%2019
filename_hdr='xingbinqu_svmclass2.hdr';
filename='xingbinqu_svmclass2.img'; 
[data,row,col,n]= getENVI(filename_hdr,filename);% [row,col,channel]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%2010 label need masks%%%%%%%%%%%%%%%%%%%%%%%
[x,r] =  geotiffread('out_xingbinqu_20101102tif.tif'); %%%%2010 
filename_hdr='out_xingbinqu_20101102_class.hdr';
filename='out_xingbinqu_20101102_class.img'; 
[data,row,col,n]= getENVI(filename_hdr,filename);%[row,col,channel]

[m1,n1,l1] = size(x);
band= zeros(m1,n1);
for i = 1:m1
    for j = 1:n1
        if x(i,j,1) > 0
           band(i,j) = 1;
        else 
           band(i,j) = 0;
        end
    end
end
data = data.*uint8(band); %%%mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%2015 label need masks%%%%%
[x,r] =  geotiffread('out_2015.tif'); %%%2015
filename_hdr='2015_maxlike_1.hdr'; 
filename ='2015_maxlike_1.img'; 
[data,row,col,n]= getENVI(filename_hdr,filename);% [row,col,n]

[m1,n1,l1] = size(x);
band= zeros(m1,n1);
for i = 1:m1
    for j = 1:n1
        if x(i,j,1) > 0
           band(i,j) = 1;
        else 
           band(i,j) = 0;
        end
    end
end
data = data.*uint8(band);  %%  mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% show label %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classNames = ["Nodata","suguar","rice","water","constructionland","forest","bareland","other_cultivated_land"]; %%    
figure
cmap = [1 1 1;0 1 0;0.67843 1 0.18431; 0 0 1; 1 0 0;0.13333 0.5451 0.13333;0.72157 0.52549 0.04314;0.93333 0.86667 0.5098];
colormap(cmap);
imshow(data,colormap);
N = numel(classNames);
ticks = 1:1:8;% 1/(N*2):1/N:1;
colorbar('TickLabels',cellstr(classNames),'Ticks',ticks,'TickLength',0,'TickLabelInterpreter','none');

% for i = 1:m1
%     for j = 1:n1
%         data(i,j) = data(i,j)-1;
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Delineate the data set %%%
Train_x = x(1:1775,:,:);
Test_x = x(1776:2958,1:1465,:);
Vail_x = x(1776:2958,1466:2931,:);

Train_label = data(1:1775,:);
Test_label = data(1776:2958,1:1465);
Vail_label = data(1776:2958,1466:2931);

figure
montage(...
    {histeq(Train_x(:,:,[6 5 4])), ...
    histeq(Vail_x(:,:,[6 5 4])), ...
    histeq(Test_x(:,:,[6 5 4]))}, ...
    'BorderSize',10,'BackgroundColor','white')
title('RGB Component of Training Image (Left), Validation Image (Center), and Test Image (Right)')
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create a random patch extraction data store for training
imwrite(Train_label,'train_labels.png');
imds = imageDatastore('train_data.mat','FileExtensions','.mat','ReadFcn',@matReader); % @matReader：Change according to the band of the image
 pixelLabelIds = 0:7;   
pxds = pixelLabelDatastore('train_labels.png',classNames,pixelLabelIds);
dsTrain = randomPatchExtractionDatastore(imds,pxds,[256,256],'PatchesPerImage',16000);%
inputBatch = preview(dsTrain);
disp(inputBatch)
load('CAM+UNet_Lgraph.mat'); %%load CAM-UNet_Lgraph

%inputTileSize = [256,256,11];
%lgraph = createUnet(inputTileSize);  %%creat U-Net
% disp(lgraph.Layers)
analyzeNetwork(lgraph_3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%选Optional training options
initialLearningRate = 0.01;
maxEpochs = 30;
minibatchSize = 16;
l2reg = 0.0001;
options = trainingOptions('sgdm',...
    'InitialLearnRate',initialLearningRate, ...
    'Momentum',0.9,...
    'L2Regularization',l2reg,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',minibatchSize,...
    'LearnRateSchedule','piecewise',...    
    'Shuffle','every-epoch',...
    'GradientThresholdMethod','l2norm',...
    'GradientThreshold',0.05, ...
    'Plots','training-progress', ...
    'VerboseFrequency',20);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%训练网络

doTraining = true; % false
if doTraining
    modelDateTime = datestr(now,'dd-mmm-yyyy-HH-MM-SS');
    [net,info] = trainNetwork(dsTrain,lgraph_3,options); %%%
    save(['multispectralUnet-' modelDateTime '-Epoch-' num2str(maxEpochs) '.mat'],'net','options');
else 
    load('multispectralUnet.mat');
end

%%%%%%%%%%%%%%%%%%% mask   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
band_x= mask(data);
band_train= mask(Train_label);
band_test = mask(Test_label);
band_vail = mask(Vail_label);

%%%%%%%%%%%%%%%%%%  segment Image  %%%%%%%%%%%%%%%%%%%%%%%%%%
load('CAM_UNet_batchsize16.mat');
%%%%%%%%%%%%% segment the whole Image %%%%%%%%%%
predictPatchSize = [256 256];
segmented_x = nozeroSubtract1((uint8(band_x).*segmentImage(x,net,predictPatchSize)));
classNames = ["Nodata","suguar","rice","water","constructionland","forest","bareland","other_cultivated_land"]; %%    
figure
cmap = [1 1 1;0 1 0;0.67843 1 0.18431; 0 0 1; 1 0 0;0.13333 0.5451 0.13333;0.72157 0.52549 0.04314;0.93333 0.86667 0.5098];
colormap(cmap);
imshow(nozeroPlus1(segmented_test),colormap);
N = numel(classNames);
ticks = 1:1:8;% 1/(N*2):1/N:1;
colorbar('TickLabels',cellstr(classNames),'Ticks',ticks,'TickLength',0,'TickLabelInterpreter','none');
%%%%%%%%%%%%%%%% segment test set and validation set%%%

segmented_test = nozeroSubtract1(uint8(band_test).*segmentImage(Test_x,net,predictPatchSize));
segmented_vail = nozeroSubtract1(uint8(band_vail).*segmentImage(Vail_x,net,predictPatchSize));

classNames = ["Nodata","suguar","rice","water","constructionland","forest","bareland","other_cultivated_land"]; %%    
figure
cmap = [1 1 1;0 1 0;0.67843 1 0.18431; 0 0 1; 1 0 0;0.13333 0.5451 0.13333;0.72157 0.52549 0.04314;0.93333 0.86667 0.5098];
colormap(cmap);
imshow(nozeroPlus1(segmented_test),colormap);
N = numel(classNames);
ticks = 1:1:8;% 1/(N*2):1/N:1;
colorbar('TickLabels',cellstr(classNames),'Ticks',ticks,'TickLength',0,'TickLabelInterpreter','none');

figure
cmap = [1 1 1;0 1 0;0.67843 1 0.18431; 0 0 1; 1 0 0;0.13333 0.5451 0.13333;0.72157 0.52549 0.04314;0.93333 0.86667 0.5098];
colormap(cmap);
imshow(nozeroPlus1(segmented_vail),colormap);
N = numel(classNames);
ticks = 1:1:8;% 1/(N*2):1/N:1;
colorbar('TickLabels',cellstr(classNames),'Ticks',ticks,'TickLength',0,'TickLabelInterpreter','none');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  accuary    

segimg = DimensionReduction2D(segmented_x);
segimg1 = DimensionReduction2D(segmented_test);
segimg2 = DimensionReduction2D(segmented_vail);

data_se = DimensionReduction2D(data);
Test_label_se = DimensionReduction2D(Test_label);
Vail_label_se = DimensionReduction2D(Vail_label);

[data_se_1,segimg_1,] = nozero(data_se,segimg);
accuary =  mean(data_se_1 == segimg_1); 

[m2,n2] = size(Test_label);
t = 0;
for i = 1:m2*n2
    if Test_label_se(i,1) ~=0
        t = t+1;
        segimg1_1(t,1)  =  segimg1(i,1);
        Test_label_se_1(t,1) = Test_label_se(i,1);
    end
end
accuary1 = mean(Test_label_se_1 == segimg1_1); 
cm_unet_test  = confusionmat(segimg1_1,Test_label_se_1); 

[m3,n3] = size(Vail_label);
t = 0;
for i = 1:m3*n3
    if Vail_label_se(i,1) ~=0
        t = t+1;
        segimg2_1(t,1)  =  segimg2(i,1);
        Vail_label_se_1(t,1) = Vail_label_se(i,1);
    end
end
accuary2 = mean(Vail_label_se_1 == segimg2_1);  
cm_unet_vail  = confusionmat(segimg2_1,Vail_label_se_1); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Extraction features  %%%%%%%%%%%%%%%
layer1 = 'Encoder-Section-1-Conv-1'; 
layer2 = 'Final-ConvolutionLayer';
layer3 = 'Softmax-Layer'; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%  Extraction features %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
train_features_layer1 = mapminmax(actions_DevideImgae(net,Train_x,layer1));
train_features_layer2 = mapminmax(actions_DevideImgae(net,Train_x,layer2));
train_features_layer3 = actions_DevideImgae(net,Train_x,layer3);

test_features_layer1 =  mapminmax(actions_DevideImgae(net,Test_x,layer1));
test_features_layer2 =  mapminmax(actions_DevideImgae(net,Test_x,layer2));
test_features_layer3 =  actions_DevideImgae(net,Test_x,layer3);

vail_features_layer1 = mapminmax(actions_DevideImgae(net,Vail_x,layer1));
vail_features_layer2 = mapminmax(actions_DevideImgae(net,Vail_x,layer2));
vail_features_layer3 = actions_DevideImgae(net,Vail_x,layer3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Trainlabels = DimensionReduction2D(Devide_label(Train_label,train_features_layer1));
Testlabels = DimensionReduction2D(Devide_label(Test_label,test_features_layer1));
Vaillabels = DimensionReduction2D(Devide_label(Vail_label,vail_features_layer1));
%%%%%%%%%制作掩膜
train_features_layer1 = mask(Trainlabels).*train_features_layer1;
train_features_layer2 = mask(Trainlabels).*train_features_layer2;
train_features_layer3 = mask(Trainlabels).*train_features_layer3;

test_features_layer1 = mask(Testlabels).*test_features_layer1;
test_features_layer2 =  mask(Testlabels).*test_features_layer2;
test_features_layer3 =  mask(Testlabels).*test_features_layer3;

vail_features_layer1 = mask(Vaillabels).*vail_features_layer1;
vail_features_layer2 =  mask(Vaillabels).*vail_features_layer2;
vail_features_layer3 =  mask(Vaillabels).*vail_features_layer3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classifier_layer1 = fitcecoc(train_features_layer1,Trainlabels);
classifier_layer2 = fitcecoc(train_features_layer2,Trainlabels);
classifier_layer3 = fitcecoc(train_features_layer3,Trainlabels);
save('classifier_layer1.mat');
save('classifier_layer2.mat');
save('classifier_layer3.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%% predict  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Pred_test_layer1 = predict(classifier_layer1,test_features_layer1);
Pred_test_layer2 = predict(classifier_layer2,test_features_layer2);
Pred_test_layer3 = predict(classifier_layer3,test_features_layer3);

Pred_vail_layer1 = predict(classifier_layer1,vail_features_layer1);
Pred_vail_layer2 = predict(classifier_layer2,vail_features_layer2);
Pred_vail_layer3 = predict(classifier_layer3,vail_features_layer3);

vote_test1 = vote_3d(Pred_test_layer1,Pred_test_layer2,Pred_test_layer3);
vote_vail1 = vote_3d(Pred_vail_layer1,Pred_vail_layer2,Pred_vail_layer3);

m4 = ceil(m2/256)*256;
n4 = ceil(n2/256)*256;

m5 = ceil(m3/256)*256;
n5 = ceil(n3/256)*256;

test = nozeroPlus1(DimensionImprove(vote_test1,zeros(m4,n4,1))); 
test = test(1:m2,1:n2);

vail = nozeroPlus1(DimensionImprove(vote_vail1,zeros(m5,n5,1)));
vail = vail(1:m3,1:n3);

classNames = ["Nodata","suguar","rice","water","constructionland","forest","bareland","other_cultivated_land"]; %%    
figure
cmap = [1 1 1;0 1 0;0.67843 1 0.18431; 0 0 1; 1 0 0;0.13333 0.5451 0.13333;0.72157 0.52549 0.04314;0.93333 0.86667 0.5098];
colormap(cmap);
imshow(test,colormap);
N = numel(classNames);
ticks = 1:1:8;% 1/(N*2):1/N:1;
colorbar('TickLabels',cellstr(classNames),'Ticks',ticks,'TickLength',0,'TickLabelInterpreter','none');

%%%%%%%%%%%%%% Remove background
[Testlabels_nozero,Pred_test_layer1_nozero] = nozero(Testlabels,Pred_test_layer1);
[Testlabels_nozero,Pred_test_layer2_nozero] = nozero(Testlabels,Pred_test_layer2);
[Testlabels_nozero,Pred_test_layer3_nozero] = nozero(Testlabels,Pred_test_layer3);

[Vaillabels_nozero,Pred_vail_layer1_nozero] = nozero(Vaillabels,Pred_vail_layer1);
[Vaillabels_nozero,Pred_vail_layer2_nozero] = nozero(Vaillabels,Pred_vail_layer2);
[Vaillabels_nozero,Pred_vail_layer3_nozero] = nozero(Vaillabels,Pred_vail_layer3);

%%%
% accuracy_test_layer1 = mean(Pred_test_layer1_nozero == Testlabels_nozero);
% accuracy_test_layer2 = mean(Pred_test_layer2_nozero == Testlabels_nozero);
% accuracy_test_layer3 = mean(Pred_test_layer3_nozero == Testlabels_nozero);
% 
% accuracy_vail_layer1 = mean(Pred_vail_layer1_nozero == Vaillabels_nozero);
% accuracy_vail_layer2 = mean(Pred_vail_layer2_nozero == Vaillabels_nozero);
% accuracy_vail_layer3 = mean(Pred_vail_layer3_nozero == Vaillabels_nozero);

vote_test = vote_3d(Pred_test_layer1_nozero,Pred_test_layer2_nozero,Pred_test_layer3_nozero);
vote_vail = vote_3d(Pred_vail_layer1_nozero,Pred_vail_layer2_nozero,Pred_vail_layer3_nozero);

accuracy_vote_test = mean(vote_test == Testlabels_nozero);
accuracy_vote_vail = mean(vote_vail == Vaillabels_nozero);
%%%%%%%%% confusionmat
%[m,order] = confusionmat(trueLabels,predictedLabels); 
confusionma_test = confusionmat(vote_test,Testlabels_nozero);
confusionma_vail = confusionmat(vote_vail,Vaillabels_nozero);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Classify the original image using the trained svm  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_features_layer1 =  mapminmax(actions_DevideImgae(net,x,layer1));
x_features_layer2 =  mapminmax(actions_DevideImgae(net,x,layer2));
x_features_layer3 =  actions_DevideImgae(net,x,layer3);

se_data = Devide_label(data,x_features_layer1);
x_labels = DimensionReduction2D(Devide_label(data,x_features_layer1));

x_features_layer1 = mask(x_labels).*x_features_layer1;
x_features_layer2 = mask(x_labels).*x_features_layer2;
x_features_layer3 = mask(x_labels).*x_features_layer3;

Pred_x_layer1 = predict(classifier_layer1,x_features_layer1);
Pred_x_layer2 = predict(classifier_layer2,x_features_layer2);
Pred_x_layer3 = predict(classifier_layer3,x_features_layer3);
%%%%%%%%%%%%
vote_x1 = vote_3d(Pred_x_layer1,Pred_x_layer2,Pred_x_layer3);
confusionma_x = confusionmat(vote_x1,x_labels);
vote_class_x = DimensionImprove(vote_x1,se_data);
vote_class_x = nozeroPlus1(vote_class_x);

figure
cmap = [1 1 1;0 1 0;0.67843 1 0.18431; 0 0 1; 1 0 0;0.13333 0.5451 0.13333;0.72157 0.52549 0.04314;0.93333 0.86667 0.5098];
colormap(cmap);
imshow(vote_class_x,colormap);
N = numel(classNames);
ticks = 1:1:8;% 1/(N*2):1/N:1;
colorbar('TickLabels',cellstr(classNames),'Ticks',ticks,'TickLength',0,'TickLabelInterpreter','none');

%%%Remove background
[xlabels_nozero,Pred_x_layer1_nozero] = nozero(x_labels,Pred_x_layer1);
[xlabels_nozero,Pred_x_layer2_nozero] = nozero(x_labels,Pred_x_layer2);
[xlabels_nozero,Pred_x_layer3_nozero] = nozero(x_labels,Pred_x_layer3);

vote_x = vote_3d(Pred_x_layer1_nozero,Pred_x_layer2_nozero,Pred_x_layer3_nozero);
accuracy_vote_x = mean(vote_x == xlabels_nozero);
confusionma_x = confusionmat(vote_x,xlabels_nozero);
%%%%%%%%%%%%%%%     LUCC          %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%The algorithm of this paper is used to find the classification results of 2010, 2015,
Y_2010 = vote_class_x; %%2010
Y_2015 = vote_class_x;  %%2015
Y_2019 = vote_class_x;  %%2019
Y_2010_1 = Y_2010(1:m1,1:n1);
Y_2015_1 = Y_2015(1:m1,1:n1);
Y_2019_1 = Y_2019(1:m1,1:n1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = 0;
for i = 1:m1
    for j = 1:n1
         if data3(i,j) == 2
            t = t+1;
        end
    end
end

data1=  Y_2010_1;
data2 = Y_2015_1;
data3 = Y_2019_1;

figure
cmap = [1 1 1;1 1 1;1 1 1; 1 1 1; 1 1 1;0.13333 0.5451 0.13333;1 1 1;1 1 1];
colormap(cmap);
imshow(data3,colormap);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Each category varies from each other, and there are 7 categories in total：2、3、4、5、6、7、8
data_var_2010_2015 = LUCC7(data1,data2);
data_var_2015_2019 = LUCC7(data2,data3);
data_var_2010_2019 = LUCC7(data1,data3);
figure
cmap = [1 1 1;1 1 1;1 1 1;1 1 1;1 1 1;1 1 1;1 1 1;1 1 1;
        0.59608 0.98431 0.9609;0 1 0.49804;0.48627 0.98824 0;0 1 0;0.19608 0.80392 0.19608;0.60392 0.80392 0.19608;
        0.93333 0.9098 0.66667;1 1 0;1 0.84314 0;0.93333 0.86667 0.5098;0.8549 0.64703 0.12549;0.72157 0.52549 0.04314;
        0 0 1;0.11765 0.56471 1;0 0.74902 1;0.52641 0.80784 0.92157;0.25098 0.87843 0.81569;0 1 1;
        1 0 0;1 0.41176 0.70588;1 0.07843 0.57647;1 0.75294 0.79608;0.85882 0.43922 0.57647;0.6902 0.18824 0.37647;
        0.91373 0.58824 0.47843;0.98039 0.50196 0.44706;1 0.62745 0.47843;1 0.64706 0;1 0.64706 0;1 0.54902 0;0.94118 0.50196 0.50196;
        1 0 1;0.93333 0.5098 0.93333;0.86667 0.62745 0.86667;0.8549 0.43922 0.83922;0.72941 0.33333 0.82745;0.6 0.19608 0.8;
        0.98039 0.94118 0.90196; 1 0.93725 0.83529;1 0.89412 0.76863;1 0.97255 0.86275;0.94118 1 1;0.90196 0.90196 0.98039;
        1 1 1];
colormap(cmap);
imshow(data_var_2010_2019,colormap);
