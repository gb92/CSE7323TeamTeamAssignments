//
//  Assignment2ViewController.m
//  Assignment2
//
//  Created by ch484-mac7 on 2/12/14.
//  Copyright (c) 2014 ch484-mac7. All rights reserved.
//

#import "Assignment2ViewController.h"
#import "Novocaine.h"
#import "AudioFileReader.h"
#import "RingBuffer.h"
#import "SMUGraphHelper.h"
#import "SMUFFTHelper.h"

#include <vector>

#define kBufferLength 8192 //4096

@interface Assignment2ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *topFrequencyLabel1;

@property (weak, nonatomic) IBOutlet UILabel *topFrequencyLabel2;

@end

@implementation Assignment2ViewController

Novocaine *audioManager;
AudioFileReader *fileReader;
RingBuffer *ringBuffer;
GraphHelper *graphHelper;
float *audioData;
float *fftMagnitudeBuffer;
float *fftPhaseBuffer;
SMUFFTHelper *fftHelper;

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
    
    
    if(sortedMaximaFrequencies.size() > 0)
    {
        self.topFrequencyLabel1.text = [NSString stringWithFormat:@"Freq 1: %f", sortedMaximaFrequencies[0].index*(44100.0f/(kBufferLength))];
    }
    if(sortedMaximaFrequencies.size() > 1)
    {
        self.topFrequencyLabel2.text = [NSString stringWithFormat:@"Freq 2: %f", sortedMaximaFrequencies[1].index*(44100.0f/(kBufferLength))];
    }
    graphHelper->setGraphData(0,audioData,kBufferLength); // set graph channel
    graphHelper->setGraphData(1,fftMagnitudeBuffer,kBufferLength/2,sqrt(kBufferLength/2));
    graphHelper->setGraphData(2,freqMaximaArray,kBufferLength/2,sqrt(kBufferLength/2));
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
    int numDataArraysToGraph = 3;
    graphHelper = new GraphHelper(self,
                                  framesPerSecond,
                                  numDataArraysToGraph,
                                  PlotStyleSeparated);//drawing starts immediately after call
    
    graphHelper->SetBounds(-0.9,0.9,-0.9,0.9); // bottom, top, left, right, full screen==(-1,1,-1,1)
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"satisfaction" withExtension:@"mp3"];
//    
//    fileReader = [[AudioFileReader alloc]
//                  initWithAudioFileURL:inputFileURL
//                  samplingRate:audioManager.samplingRate
//                  numChannels:audioManager.numOutputChannels];
//    
//    [fileReader play];
//    fileReader.currentTime = 0.0;
    
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
    
    int freqThreshold = 500;
    int freqThresholdindex = 100;//(int) ciel(500.0f/(44100.0f/(kBufferLength))); //ignore everything under 500 Hz
    printf("Threshold Index: %f\n", freqThresholdindex);
    
    for (int i=freqThresholdindex; i<(size-1); i++) {
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
                        printf("Index added: %d\n", temp.index);
                        break;
                }
            }
        }
    }
    
    for(int i=0; i< indexMags.size(); i++)
    {
        float freq=indexMags[i].index*(44100.0f/(kBufferLength))];
        
        if(freq<500)
        {
            indexMags.removeAt(i);
            i--;
        }
    }
    
    std::sort(indexMags.begin(), indexMags.end(), compareIndexMagnitudePairs);
    
    return indexMags;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
