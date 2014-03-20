//
//  TMHeartBeatCounter.m
//  TeamFit
//
//  Created by ch484-mac5 on 3/19/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMHeartBeatCounter.h"

static const int kFramesPerSec = 24;
static const int kSampleSecond = 5;


@interface TMHeartBeatCounter()


@end

@implementation TMHeartBeatCounter
std::vector<float> meanOfRedValues;
static const int MEAN_OF_RED_VALUES_ARRAY_SIZE = kSampleSecond * kFramesPerSec;

std::vector<float>maximumValueList;


-(id)init
{
    meanOfRedValues.reserve( MEAN_OF_RED_VALUES_ARRAY_SIZE );
    
    return self;
}


-(void)setMeanOfRedValue:(float)redValue green:(float)greenValue blue:(float)blueValue
{
    if( meanOfRedValues.size() < MEAN_OF_RED_VALUES_ARRAY_SIZE )
    {
        // Make sure that the color is red.
        // and push data to the buffer.
        //
        
        
        if ((blueValue < 50 && greenValue< 50 && redValue > 200 && redValue < 253) ||
            (blueValue < 10 && greenValue < 10 && redValue > 45 && redValue < 113)) // Changed: Consider dark red as a sample
        {
            meanOfRedValues.push_back( redValue );
        }

    }
    else
    {
        normalizeData( meanOfRedValues, 6 );
        
        NSLog(@"Hear Rate : %f\n", self.heartRate);
        
        float newHeartRate = countLocalMaximaFromArray(meanOfRedValues);
        self.heartRate = ( newHeartRate + self.heartRate ) / 2.0;
        
        NSLog(@"Hear Rate new : %f\n", newHeartRate);
        
        
        meanOfRedValues.clear();
    }

    }


int countLocalMaximaFromArray(const std::vector<float> array)
{
    int result = 0;
    
    static const double ErrorRate = 0.000001;
    static const int windowSize = 11;
    std::vector<float> window;
    window.resize( windowSize );
    
    //Debug
    maximumValueList.clear();
    maximumValueList.resize( array.size() );
    
    std::vector<float>::iterator maxValueListIterator = maximumValueList.begin();
    
    //End Debug
    
	float previousMaxValue = 0.0f;
    float currentMaxValue = 0.0f;
    
    std::vector<float>::const_iterator pBeginOfBuffer = array.begin();
    std::vector<float>::const_iterator pEndOfBuffer = array.end();
    std::vector<float>::const_iterator pCurrentPointer = pBeginOfBuffer;
    
    
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

-(std::vector<float>) getMaximumValueList
{
    return maximumValueList;
}

-(std::vector<float>) getMeanOfRedValue
{
    return meanOfRedValues;
}



float maxValueOfArray( std::vector<float>::const_iterator beginOfWindow, std::vector<float>::const_iterator endOfWindow )
{
	
    float max = -MAXFLOAT;
    
    std::vector<float>::const_iterator currentPoint = beginOfWindow;
    
    while( currentPoint < endOfWindow )
    {
        max = std::max( *currentPoint, max );
        currentPoint++;
    }
    
    return max;
}

float minValueOfArray( std::vector<float>::const_iterator beginOfWindow, std::vector<float>::const_iterator endOfWindow )
{
	
    float min = MAXFLOAT;
    
    std::vector<float>::const_iterator currentPoint = beginOfWindow;
    
    while( currentPoint < endOfWindow )
    {
        min = std::min( *currentPoint, min );
        currentPoint++;
    }
    
    return min;
}





void normalizeData( std::vector<float>& array, float scaleFactor )
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







@end
