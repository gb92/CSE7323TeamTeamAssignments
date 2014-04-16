//
//  GestureTrainner.cpp
//  Assignment6
//
//  Created by Mark Wang on 4/15/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#include "GestureTrainner.h"
#include <stdio.h>

#define FETURES_SIZE 2

using namespace cv;

GestureTrainner::GestureTrainner()
{
    
}

GestureTrainner::~GestureTrainner()
{
    
}

void GestureTrainner::testTrain()
{

    // Set up training data
    float labels[4] = {1.0, -1.0, -1.0, -1.0};
    Mat labelsMat(4, 1, CV_32FC1, labels);
    
    float trainingData[4][2] = { {501, 10}, {255, 10}, {501, 255}, {10, 501} };
    Mat trainingDataMat(4, 2, CV_32FC1, trainingData);
    
    // Set up SVM's parameters
    CvSVMParams params;
    params.svm_type    = CvSVM::C_SVC;
    params.kernel_type = CvSVM::LINEAR;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
    
    // Train the SVM
    
    SVM.train(trainingDataMat, labelsMat, Mat(), Mat(), params);
    

    for (int i = 0; i < 10; ++i)
    {
        Mat sampleMat = (Mat_<float>(1,2) << 501,10);
        float response = SVM.predict( sampleMat );
        
        if (response == 1)
            std::cout << "1";
        else if (response == -1)
            std::cout << "-1";
    }
    

    // Show support vectors
//    int c     = SVM.get_support_vector_count();
//    const float* v = SVM.get_support_vector(0);

}

void GestureTrainner::addTrainningVector( float *trainningVector, int label )
{
    std::vector<float>vTrainningVector;
    vTrainningVector.resize( FETURES_SIZE );
    
    vTrainningVector.assign(trainningVector, trainningVector+FETURES_SIZE );
    
    trainningSet.push_back( vTrainningVector );
    labels.push_back(label);
}

void GestureTrainner::fit()
{
    
    float *labelsRawData = new float[ labels.size() ];

    for( int i=0; i<labels.size(); i++ )
    {
        labelsRawData[i] = labels[i];
        printf(":%f\n", labelsRawData[i] );
        
    }
    Mat labelsMat( (int)labels.size(), 1, CV_32FC1, labelsRawData );
    
    float *trainingRawData = new float[ trainningSet.size() * FETURES_SIZE ];
    
    for( int i=0; i<trainningSet.size(); i++ )
    {
        memcpy( &trainingRawData[i * FETURES_SIZE], trainningSet[i].data(), FETURES_SIZE * sizeof(float) );
        
        for( int j=0; j<FETURES_SIZE; j++ )
        {
            printf(":%f", trainingRawData[i*FETURES_SIZE + j ] );
        }
        printf("\n");
    }
    
    Mat trainingDataMat( (int)trainningSet.size(), FETURES_SIZE, CV_32FC1, trainingRawData );
    
    
    // Set up SVM's parameters
    CvSVMParams params;
    params.svm_type    = CvSVM::C_SVC;
    params.kernel_type = CvSVM::LINEAR;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
    
    // Train the SVM
    SVM.train(trainingDataMat, labelsMat, Mat(), Mat(), params);
    
    delete trainingRawData;
    delete labelsRawData;
}

int GestureTrainner::predict( float* testVector )
{
    Mat sampleMat( FETURES_SIZE, 1, CV_32FC1, testVector );
    float response = SVM.predict( sampleMat );
    
    return response;
}











