# CAM-UNet-SVM
In this paper, we added a channel attention mechanism based on U-Net, used the model trained by the CAM-UNet network to extract three different levels of features,
put them into SVM classification, and then analyzed the voting results after the majority voting game to obtain the final results and evaluate classification accuracy.
![fig2](https://user-images.githubusercontent.com/91734518/154678979-080111d0-719c-480b-b8ef-68f12cfd6173.jpg)

data, code and models are publicly available at https://pan.baidu.com/s/1AaAvIB67zUSgGZGrJ4gIeQ?pwd=8888  
Extraction Code： 8888
The code of the experiment is performed using Matlab 2021b, and the experimental environment consists of Intel(R) Core(TM) i5-8500 CPU with an NVIDIA GeForce RTX 2060 GPU.
It is recommended to run the program line by line. Double-click on the .mat file in the file to manually load the data into the workspace
The whole procedure flow is as follows: read data → divide the dataset → set training parameters and train the network → segment the dataset and verify the accuracy → extract features with network layers into svm for training → classify the dataset and evaluate the accuracy. The classification results of 2010, 2015 and 2019 were obtained after repeating three times, and the three classification results of the study area were monitored for dynamic land use changes.

‘lj_net_svm.mat’ is main. ‘CAM+UNet_Lgraph.mat’  is the network structure of CAM-Net. ‘CAM_UNet_batchsize16.mat’ is the trained network. ‘classifier_layer1_16.mat’ is the model obtained by extracting features with 'Encoder-Section-1-Conv-1' layer and putting it into svm training. ‘classifier_layer2_16.mat’ is the model obtained by extracting features with the 'Final-ConvolutionLayer' layer and putting them into the svm training.‘classifier_layer3_16.mat’ is the model obtained by extracting features with the 'Softmax-Layer' layer and putting them into the svm training.

Lines 1 to 41 are read data, and the data are remote sensing images and label maps of Xingbin District, Laibin City, Guangxi Zhuang Autonomous Region for 2010, 2015 and 2019. The size of the training, validation, and testing samples were 60%, 20%, and 20% of the total sample size, respectively
![fig1](https://user-images.githubusercontent.com/91734518/154678944-cdba18aa-3de5-421e-a9aa-28fe25239646.jpg)

Line 77：imds = imageDatastore('train_data.mat','FileExtensions','.mat','ReadFcn',@matReader); matReade.mat: data = d.(f{1})(:,:, 1:11); where 11 is the number of bands in the landsat 8 image. It needs to be modified accordingly to the number of image bands
After loading 'CAM+UNet_Lgraph.mat', open the Deep Learning Designer in the matlab2021b app → after pouring in the imported network layers from the workspace you can view the entire network in its entirety and make changes. If you modify the ImageInputLayer, you need to reset the parameters of ‘Encoder-Section-1-Conv-1’, and you can modify the classification number in Final-ConvolutionLayer.
