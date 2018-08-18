//
//  GameSingleton.h
//  Klink
//  Created by My Mac on 20/06/2010.
//


#include "chipmunk.h"
#include "cocos2d.h"
#include "cpMouse.h"
#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"


@interface GameSingleton : NSObject {

}


// Game variables here...
int gamestate; 
int ball_stopped[6];
bool ball_in_bed[6];
cpBody * balls[6];
cpShape* balls_shapes[6];
CCSprite* ball_sprites[6];
CCSprite* ball_sprites2[6];

int current_ball_no;

CCMenu *menu;
CCMenuItemFont *thefont;
CCLabel *ypos;
CCLabel *ypos2;
CCLabel *player_label;
CCLabel *wellDone;

CCMenu *newGame;
CCMenu *backtomenu;
CCMenuItemFont *newGameFont;

// state bool switches
bool new_coin;
bool menu_shown ;
bool game_over_balls_set;
bool score_changed;
bool score_added;
bool wall_collide;


// score variables.
int current_score;
int score_this_round;
int total_pen;
int player1_round_scores[9][5];
int player1_scores[10]; 
int player2_scores[10]; 
int player1_scores_temp[10];
int player2_scores_temp[10];
CCLabel *player_1_scores_lbl[10]; 
CCLabel *player_2_scores_lbl[10]; 

int current_player;
bool game_in_progress;
bool autostart;

@end
