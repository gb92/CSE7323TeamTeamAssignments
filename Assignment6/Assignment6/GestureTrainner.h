//
//  GestureTrainner.h
//  Assignment6
//
//  Created by Mark Wang on 4/15/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#ifndef __Assignment6__GestureTrainner__
#define __Assignment6__GestureTrainner__

#include <iostream>
#include <opencv2/ml/ml.hpp>

class GestureTrainner
{
public:
    GestureTrainner();
    ~GestureTrainner();

    void testTrain();
    
    void addTrainningVector( float* trainningVector, int label );
    
    void fit();
    
    int predict( float* testVector );
    
private:
    
    std::vector< std::vector<float> >trainningSet;
    std::vector< int > labels;
    
    CvSVM SVM;
};

#endif /* defined(__Assignment6__GestureTrainner__) */
