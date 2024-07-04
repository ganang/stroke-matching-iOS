#import "StrokeMatching-Bridging-Header.h" 
#include "StrokeMatching.hpp"
#include "vector"

using namespace std;
using namespace strokeMatching;

@implementation StrokeMatchingWrapper

+ (bool)passFrechetDistance:(const CGPoint[])pointsA countA:(int)countA pointsB:(const CGPoint[])pointsB countB:(int)countB {
    
    auto strokeMatching = make_unique<StrokeMatching>();

    vector<Point2f> currentPointsA;
    vector<Point2f> currentPointsB;
    
    float xA, yA;
    float xB, yB;

    currentPointsA.reserve(countA);
    currentPointsB.reserve(countB);
    
    for (int i = 0; i < countA; ++i) {
        CGFloat x = pointsA[i].x;
        CGFloat y = pointsA[i].y;

        xA = (float)x;
        yA = (float)y;

        currentPointsA.emplace_back(xA, yA);
    }

    for (int i = 0; i < countB; ++i) {
        CGFloat x = pointsB[i].x;
        CGFloat y = pointsB[i].y;

        xB = (float)x;
        yB = (float)y;

        currentPointsB.emplace_back(xB, yB);
    }

    return strokeMatching->passFrechetDistance(currentPointsA, currentPointsB);
}

+ (float)recursiveDFD:(int)indexA indexB:(int)indexB maxThreshold:(float)maxThreshold {
    return 1.0;
}

@end