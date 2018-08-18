//
//  Global.h
//  flickit
//
//  Created by J Walker on 14/05/2010.
//  Copyright 2010 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"
#import "cocos2d.h"
#import "chipmunk.h"
#import "cpMouse.h"




@interface Global : NSObject {

}

@end

@interface MainMenu : CCLayer < UITextFieldDelegate >
{
	CCMenuItem	*disabledItem;
	NSTimer *menuTimer;
}

-(void) menuCallbackPlayer1:(id) sender;
-(void) menuCallback2:(id) sender;
-(void) onQuit:(id) sender;
@end


@interface SplashLayer : CCLayer
{
	NSTimer *splashTimer;
}
-(void) splashTimerCallback;
@end

// really should have a singleton here for global state variables.

int board;
NSString *Player1;
NSString *Player2;
bool two_player;
bool sound_on;


CCScene *theScene;  //menu Scene..
CCScene *gs;        //game Scene..
CCScene *cs;        //config Scene..
CCScene *hs;        //history scene..
CCScene *as;		 //about scene..
CCScene *hp;        //how to play scene..
CCScene *sl;        //splash layer..


// for high score entries....
struct penalty_score_entry {
	NSString *the_date;
	int PenaltyScore;
};









