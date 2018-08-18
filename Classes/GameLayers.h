//
//  GameLayers.h
//  temp_test
//
//  Created by J Walker on 09/05/2010.
//  Copyright 2010 test. All rights reserved.
//

//#import "cocos2d.h"

#include "GameSingleton.h"




@interface Game : CCLayer {
   	cpMouse* mouse;
	CCLabel* HighFiveLabel;
	CCLabel* HighFiveLabel2;

}

-(cpBody *) addSpriteNamed: (NSString *)name x: (float)x y:(float)y type:(unsigned int)type coin_no: (unsigned int)coin_no;
- (void)createBoundingBox;
-(int) Coin_StoppedCheck: (bool)score_it :(int) ball: (int)ball_no;
-(void) step: (ccTime) delta;
-(bool) GameOver: (int)ball_no;
-(bool) GameOver_two_player: (int)ball_no;
-(void) Load_Game_State;
-(void) Save_Game_State;
-(void) Delete_Game_State;
-(void) display_scores;
-(void) addCheatButtons;



@end



