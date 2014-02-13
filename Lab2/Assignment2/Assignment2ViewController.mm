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


#define kBufferLength 4096

@interface Assignment2ViewController ()

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

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    graphHelper->draw(); // draw the graph
}


//  override the GLKViewController update function, from OpenGLES
- (void)update{
    
    // plot
    ringBuffer->FetchFreshData2(audioData, kBufferLength, 0, 1);
    fftHelper->forward(0,audioData, fftMagnitudeBuffer, fftPhaseBuffer);
    graphHelper->setGraphData(0,audioData,kBufferLength); // set graph channel
    graphHelper->setGraphData(1,fftMagnitudeBuffer,kBufferLength/2,sqrt(kBufferLength/2));
    graphHelper->setGraphData(2,maximaDetection(fftMagnitudeBuffer,kBufferLength/2,100),kBufferLength/2,sqrt(kBufferLength/2));
    graphHelper->update(); // update the graph
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
    
    NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"satisfaction" withExtension:@"mp3"];
    
    fileReader = [[AudioFileReader alloc]
                  initWithAudioFileURL:inputFileURL
                  samplingRate:audioManager.samplingRate
                  numChannels:audioManager.numOutputChannels];
    
    [fileReader play];
    fileReader.currentTime = 0.0;
    
    [audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         ringBuffer->AddNewInterleavedFloatData(data, numFrames, numChannels);
     }];
    
}

float* maximaDetection(float* freqSeries, int size, int wsize){
    float maxima[size];
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

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
