//
//  TMHeartBeatCounter.h
//  TeamFit
//
//  Created by ch484-mac5 on 3/19/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vector>
#import <deque>

namespace TeamTeam
{

    class TMHeartRateCounter
    {
    private:
        std::deque<float> meanOfRedValues;
        std::deque<float> maximumValueList;
        float heartRate;
        
        
        int countLocalMaximaFromArray(const std::deque<float> array);
        
        
    public:
        TMHeartRateCounter();
        ~TMHeartRateCounter();
        
        void setMeanOfPixelValue( float redValue, float greenValue, float blueValue );
        std::vector<float> getMaximumValueList();
        std::vector<float> getMeanOfRedValue();
        void calculateHeartRate();
        float getHeartRate();
        
    };

}

