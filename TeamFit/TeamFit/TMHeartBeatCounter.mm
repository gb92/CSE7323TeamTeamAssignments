//
//  TMHeartBeatCounter.m
//  TeamFit
//
//  Created by ch484-mac5 on 3/19/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMHeartBeatCounter.h"

namespace TeamTeam
{
    
    static const int kFramesPerSec = 24;
    static const int kSampleSecond = 10;
    static const int HEART_RATE_BUFFER_SIZE = kSampleSecond * kFramesPerSec;


    //-------------------------------------------
    /* Convinion Functions */
    //-------------------------------------------

    float maxValueOfArray( std::deque<float>::const_iterator beginOfWindow, std::deque<float>::const_iterator endOfWindow )
    {
        
        float max = -MAXFLOAT;
        
        std::deque<float>::const_iterator currentPoint = beginOfWindow;
        
        while( currentPoint < endOfWindow )
        {
            max = std::max( *currentPoint, max );
            currentPoint++;
        }
        
        return max;
    }

    float minValueOfArray( std::deque<float>::const_iterator beginOfWindow, std::deque<float>::const_iterator endOfWindow )
    {
        
        float min = MAXFLOAT;
        
        std::deque<float>::const_iterator currentPoint = beginOfWindow;
        
        while( currentPoint < endOfWindow )
        {
            min = std::min( *currentPoint, min );
            currentPoint++;
        }
        
        return min;
    }


    void normalizeData( std::deque<float>& array, float scaleFactor )
    {
        
        int minOfThisList = (int)minValueOfArray( array.begin(), array.end());
        int maxOfThisList = (int)maxValueOfArray( array.begin(), array.end())+1;
        const float range = (float)(maxOfThisList-minOfThisList);
        const float rangeInverse = 1.0/range;
        
        for( int i=0; i<array.size(); i++ )
        {
            float substractedValue = (array[i] - minOfThisList);
            array[i] = substractedValue * rangeInverse;
            array[i] *= scaleFactor;
        }
        
    }

    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------


    TMHeartRateCounter::TMHeartRateCounter()
    {
        
    }

    TMHeartRateCounter::~TMHeartRateCounter()
    {
        
    }

    void TMHeartRateCounter::setMeanOfPixelValue( float redValue, float greenValue, float blueValue )
    {
        if ((blueValue < 50 && greenValue< 50 && redValue > 200 && redValue < 253) ||
            (blueValue < 10 && greenValue < 10 && redValue > 45 && redValue < 113)) // Changed: Consider dark red as a sample
        {
            if( meanOfRedValues.size() >= HEART_RATE_BUFFER_SIZE )
            {
                meanOfRedValues.pop_back();
            }
            
            meanOfRedValues.push_front(redValue);

            //NSLog(@"%f\n", meanOfRedValues[0]);

        }
    }

    void TMHeartRateCounter::calculateHeartRate()
    {
        //normalizeData( meanOfRedValues, 6 );
        heartRate = countLocalMaximaFromArray(meanOfRedValues);

    }

    int TMHeartRateCounter::countLocalMaximaFromArray(const std::deque<float> array)
    {
        int result = 0;
        
        static const double ErrorRate = 0.000001;
        static const int windowSize = 11;

        //Debug
        maximumValueList.clear();
        maximumValueList.resize( array.size() );
        
        std::deque<float>::iterator maxValueListIterator = maximumValueList.begin();
        
        //End Debug
        
        float previousMaxValue = 0.0f;
        float currentMaxValue = 0.0f;
        
        std::deque<float>::const_iterator pBeginOfBuffer = array.begin();
        std::deque<float>::const_iterator pEndOfBuffer = array.end();
        std::deque<float>::const_iterator pCurrentPointer = pBeginOfBuffer;
        
        
        while( pCurrentPointer < pEndOfBuffer)
        {
            currentMaxValue = maxValueOfArray( pCurrentPointer, pCurrentPointer + windowSize );
            
            double thisError = (previousMaxValue - currentMaxValue); // Changed:
            
            if( thisError < 0 ) thisError *= -1.0;
            
            if ( thisError < ErrorRate ) // Found local maximar
            {
                
                //! Debug mask
                //
                {
                    *maxValueListIterator = currentMaxValue;
                    maxValueListIterator = maxValueListIterator + windowSize;
                }
                //
                // End debug mask
                
                
                result++;
                
                // Hack lol
                pCurrentPointer = pCurrentPointer + windowSize;
                previousMaxValue = 0;
                
                
            }
            else // Not Found local maximra
            {
                
                // move window
                pCurrentPointer = pCurrentPointer + 5;
                
                // Debug mask---
                //*maxValueListIterator = currentMaxValue;
                maxValueListIterator = maxValueListIterator + 5;
                
                // end Debug mask---
                
                previousMaxValue = currentMaxValue;
                
                
            }
            
        }
        
        return result;
    }

    std::vector<float> TMHeartRateCounter::getMaximumValueList()
    {
        return std::vector<float>( maximumValueList.begin(), maximumValueList.end() );
    }

    std::vector<float> TMHeartRateCounter::getMeanOfRedValue()
    {
        return std::vector<float>( meanOfRedValues.begin(), meanOfRedValues.end() );;
    }
    
    float TMHeartRateCounter::getHeartRate()
    {
        return (float)heartRate * 6 * ( (float)HEART_RATE_BUFFER_SIZE / (float)meanOfRedValues.size() );
    }

}

