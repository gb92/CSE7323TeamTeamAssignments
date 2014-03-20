//
//  TMHeartBeatCounter.h
//  TeamFit
//
//  Created by ch484-mac5 on 3/19/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <vector>

namespace TeamTeam
{

    class TMHeartRateCounter
    {
    private:
        std::vector<float> meanOfRedValues;
        std::vector<float>maximumValueList;
        float heartRate;
        
        
        int countLocalMaximaFromArray(const std::vector<float> array);
        
    public:
        TMHeartRateCounter();
        ~TMHeartRateCounter();
        
        void setMeanOfPixelValue( float redValue, float greenValue, float blueValue );
        std::vector<float> getMaximumValueList();
        std::vector<float> getMeanOfRedValue();
        float getHeartRate();
    };

}

