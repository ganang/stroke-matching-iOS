#import <Foundation/Foundation.h>

@interface StrokeMatchingWrapper :  NSObject

+ (bool)passFrechetDistance:(const CGPoint[])pointsA countA:(int)countA pointsB:(const CGPoint[])pointsB countB:(int)countB;
+ (float)recursiveDFD:(int)indexA indexB:(int)indexB maxThreshold:(float)maxThreshold;

@end