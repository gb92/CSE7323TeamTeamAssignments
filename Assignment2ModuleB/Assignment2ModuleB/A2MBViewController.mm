//
//  A2MBViewController.mm
//  Assignment2ModuleB
//
//  Created by Gavin Benedict on 2/19/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "A2MBViewController.h"


#import "Novocaine.h"
#import "AudioFileReader.h"
#import "RingBuffer.h"
#import "SMUGraphHelper.h"
#import "SMUFFTHelper.h"

#include <vector>

#define kBufferLength 8192

@interface A2MBViewController ()

@property (weak, nonatomic) IBOutlet UILabel *movementLabel;

@property (weak, nonatomic) IBOutlet UISlider *toneFrequencySlider;

@property (nonatomic) bool isPlayingTone;

@end

@implementation A2MBViewController

Novocaine *audioManager;
RingBuffer *ringBuffer;
GraphHelper *graphHelper;
float *audioData;
float *fftMagnitudeBuffer;
float *fftPhaseBuffer;
SMUFFTHelper *fftHelper;
std::vector<int> previousStates;

struct IndexMagnitudePair
{
    int index;
    float magnitude;
} ;




//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    graphHelper->draw(); // draw the graph
}


//  override the GLKViewController update function, from OpenGLES
- (void)update{
    
    // plot
    ringBuffer->FetchFreshData2(audioData, kBufferLength, 0, 1);
    fftHelper->forward(0,audioData, fftMagnitudeBuffer, fftPhaseBuffer);
    float *freqMaximaArray = maximaDetection(fftMagnitudeBuffer,kBufferLength/2,5);
    
    std::vector<IndexMagnitudePair> sortedMaximaFrequencies = sortMaximaFrequencies(freqMaximaArray,kBufferLength/2);
    checkForMovement(sortedMaximaFrequencies, (A2MBViewController *) self);
    
    //graphHelper->setGraphData(0,audioData,kBufferLength); // set graph channel
    
    float maxVal = 0;
    vDSP_maxv(fftMagnitudeBuffer, 1, &maxVal, kBufferLength);
    vDSP_vdbcon(fftMagnitudeBuffer, 1, &maxVal , fftMagnitudeBuffer, 1, kBufferLength, 1);
    
    graphHelper->setGraphData(0,fftMagnitudeBuffer,kBufferLength/2,sqrt(kBufferLength/2));
    //graphHelper->setGraphData(2,freqMaximaArray,kBufferLength/2,sqrt(kBufferLength/2));
    graphHelper->update(); // update the graph
    delete [] freqMaximaArray;
}

-(void) viewDidDisappear:(BOOL)animated{
    // stop opengl from running
    graphHelper->tearDownGL();
}



-(void)dealloc{
    graphHelper->tearDownGL();
    free(fftMagnitudeBuffer);
    free(fftPhaseBuffer);
    delete fftHelper;
    free(audioData);
    
    // ARC handles everything else, just clean up what we used c++ for (calloc, malloc, new)
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    audioManager = [Novocaine audioManager];
    ringBuffer = new RingBuffer(kBufferLength,2);
    
    audioData = (float*)calloc(kBufferLength,sizeof(float));
    fftHelper = new SMUFFTHelper(kBufferLength,kBufferLength,WindowTypeRect);
    fftMagnitudeBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
    fftPhaseBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
    
    // start animating the graph
    int framesPerSecond = 15;
    int numDataArraysToGraph = 1;
    graphHelper = new GraphHelper(self,
                                  framesPerSecond,
                                  numDataArraysToGraph,
                                  PlotStyleSeparated);//drawing starts immediately after call
    
    graphHelper->SetBounds(-0.6,1,-0.9,0.9); // bottom, top, left, right, full screen==(-1,1,-1,1)
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         ringBuffer->AddNewInterleavedFloatData(data, numFrames, numChannels);
     }];
    
}


//Moving window of local maxima amplitudes
float* maximaDetection(float* freqSeries, int size, int wsize){
    float *maxima = new float[size];
    float max = 0;
    
    for (int i=0; i<size; i++) {
        max = 0;
        if(i<((wsize+1)/2)){
            for(int j=0; j<i+1; j++) {
                if(max < freqSeries[j])
                    max = freqSeries[j];
            }
            maxima[i] = max;
        }
        else if(i>size-1-((wsize-1)/2)){
            for(int j=i-((wsize-1)/2); j<size; j++) {
                if(max < freqSeries[j])
                    max = freqSeries[j];
            }
            maxima[i] = max;
        }else{
            for(int j=i-((wsize-1)/2); j<i+((wsize-1)/2)+1; j++) {
                if(max < freqSeries[j])
                    max = freqSeries[j];
            }
            maxima[i] = max;
        }
    }
    
    return maxima;
}

bool compareIndexMagnitudePairs(IndexMagnitudePair a, IndexMagnitudePair b)
{
    return a.magnitude>b.magnitude;
}

//This function takes a filtered (moving window maxima) fft magnitude array and returns a sorted vector of index magnitude pairs
std::vector<IndexMagnitudePair> sortMaximaFrequencies(float* filteredFreqSeries, int size){
    std::vector<IndexMagnitudePair> indexMags;
    
    int count = 0;
    
    int freqThresholdindex = (int) ceil(12000.0f/(44100.0f/(kBufferLength))); //ignore everything under 500 Hz
    //printf("Threshold Index: %d\n", freqThresholdindex);
    
    for (int i=freqThresholdindex; i<(size-1); i++){
        if(filteredFreqSeries[i] == filteredFreqSeries[i+1]){
            for (int j=i; j<size; j++) {
                if(filteredFreqSeries[i] == filteredFreqSeries[j]){
                    count++;
                }
                else{
                    IndexMagnitudePair temp;
                    temp.index = i + (j-i)/2;
                    temp.magnitude = filteredFreqSeries[i];
                    indexMags.push_back(temp);
                    i = j;
                    break;
                }
            }
        }
    }
    
    std::sort(indexMags.begin(), indexMags.end(), compareIndexMagnitudePairs);
    
    return indexMags;
}

void checkForMovement(std::vector<IndexMagnitudePair> sortedMaximaFrequencies, A2MBViewController * This)
{
    //if the tone is being played
    if(This.isPlayingTone)
    {
        //and there is actually more than 1 maxima frequencies
        if(sortedMaximaFrequencies.size() > 1)
        {
            //calculate the current playing frequency
            //(should have made this a variable, that was modified when slider updates)
            float currentPlayingFrequency=15000+(This.toneFrequencySlider.value*5000);
            
            //set the thresholds
            float lower_threshold=5;
            float higher_threshold=100;
            float amplitude_threshold=sortedMaximaFrequencies[0].magnitude*0.25;
            
            //calculate the freque
            float freq=sortedMaximaFrequencies[1].index*(audioManager.samplingRate/(kBufferLength));
            float distance = abs(freq-currentPlayingFrequency);
            
            //add the current state to the vector
            if(freq>currentPlayingFrequency && distance>=lower_threshold && distance<=higher_threshold && sortedMaximaFrequencies[1].magnitude>=amplitude_threshold)
            {
                previousStates.push_back(1);
            }
            else if(freq<currentPlayingFrequency && distance>=lower_threshold && distance<=higher_threshold && sortedMaximaFrequencies[1].magnitude>=amplitude_threshold)
            {
                previousStates.push_back(-1);

            }else{
                previousStates.push_back(0);
                
            }
            
            
        }else{
            previousStates.push_back(0);
        }

        //dequeue states from the beginning of the vector
        if(previousStates.size()>5)
        {
            //it's -6 to make sure that it's begin->begin for size=6
            previousStates.erase(previousStates.begin(), previousStates.begin()+(previousStates.size()-6));
        }

        //calculate the average of the previous states
        float avg=0.0f;
        
        for(int i=0; i<previousStates.size();i++)
        {
            avg+=previousStates.at(i);
        }
        
        avg=avg/previousStates.size();
        
        //round the average to the nearest state
        //only possible problem is that 0 has a larger range of values...
        int roundedAvg=rintf(avg);
        
        //set the label based on the
        if(roundedAvg==1)
        {
            [This.movementLabel setText:@"Moving Towards"];
        }
        else if(roundedAvg == -1)
        {
            [This.movementLabel setText:@"Moving Away"];
        }
        else
        {
            [This.movementLabel setText:@"Not Moving"];
        }
    }else{
        [This.movementLabel setText:@"Not Playing Tone"];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)ToneButtonPressed:(id)sender {
    UIButton *button=(UIButton *)sender;
    
    if(!self.isPlayingTone)
    {
        [button setTitle:@"Stop Tone" forState:UIControlStateNormal];
        
        __block float phase = 0.0;
        __block float samplingRate = audioManager.samplingRate;
        
        [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
            double frequency=15000+(self.toneFrequencySlider.value*5000);
            double phaseIncrement = 2*M_PI*frequency/samplingRate;
            double repeatMax = 2*M_PI;
            for (int i=0; i < numFrames; ++i)
            {
                for(int j=0;j<numChannels;j++){
                    data[i*numChannels+j] = sin(phase);
                    
                }
                phase += phaseIncrement;
                
                if(phase>repeatMax)
                    phase -= repeatMax;
            }

        }];
        self.isPlayingTone=YES;
    }
    else
    {
        [button setTitle:@"Play Tone" forState:UIControlStateNormal];
        
        [audioManager setOutputBlock:nil];
        
        self.isPlayingTone=NO;
    }
}


@end