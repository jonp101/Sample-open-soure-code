//
//  GameLayers.m
//  temp_test
//
//  Created by J Walker on 09/05/2010.
//  Copyright 2010 test. All rights reserved.
//

//JSE

#import "GameLayers.h"
#import "Global.h"

// This section for consts and enums...
// This is the space the game is played in..

cpSpace *space;
cpBody *staticBody;
int balls_per_round = 5;
int m_calibrate_l[9] = {284,352,420,488,556,624,693,762,830};
int m_calibrate_h[9] = {296,365,433,501,569,638,706,775,841};

int s_calibrate_l[9] = {286,354,422,490,558,628,695,763,832};
int s_calibrate_h[9] = {297,367,434,502,570,640,708,776,844};

int f_calibrate_l[9] = {286,353,421,489,559,627,695,763,832};
int f_calibrate_h[9] = {297,365,433,502,571,639,707,774,842};

bool add_pen = true;

CCLayer *gamelayer;

// state types
enum{
	coin_toflick,
	coin_inplay,
	coin_stopped,
	end_of_round,
	game_over,
	game_over_two_player
};

// ball/coin states
enum {
	Ball_moving,
	Ball_out_of_bed_stopped,
	Ball_in_bed_1_stopped,
	Ball_in_bed_2_stopped,
	Ball_in_bed_3_stopped,
	Ball_in_bed_4_stopped,
	Ball_in_bed_5_stopped,
	Ball_in_bed_6_stopped,
	Ball_in_bed_7_stopped,
	Ball_in_bed_8_stopped,
	Ball_in_bed_9_stopped,
	
};



// functions from other files brought in via magic / C
extern void drawObject(void *ptr, void *unused);


static int
BeginColl(cpArbiter *arb, cpSpace *space, void *ignore)
{
	return 1;
}

static void
Seperate(cpArbiter *arb, cpSpace *space, void *ignore)
{
	
}

static int
BeginCollc(cpArbiter *arb, cpSpace *space, void *ignore)
{
    CP_ARBITER_GET_SHAPES(arb, a, b);
    cpVect va;
    cpVect vb;
    va = a->body->v;
    vb = b->body->v;
    cpVect vNet = cpvadd(va,vb);
    cpFloat Length = cpvlength(vNet);
    // 7 = barely touching
    // 1000 = hard
    if (Length > 1 ) {
		if (sound_on) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"clink.wav" pitch:1.8 pan:1 gain:(0.001*Length)];
		}
    }	
    return 1;
}

static void
Seperatec(cpArbiter *arb, cpSpace *space, void *ignore)
{
}

static void eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	CCSprite *sprite = shape->data;
	
	// for slate and mahogony then color coin yellow in bed, no need to change sprite
	if( sprite ) {
		cpBody *body = shape->body;		
		if (board == 2) {
			for ( int i = 1 ; i <= current_ball_no; i++)
			{
				if ( body == balls[i] )
				{
					if (ball_in_bed[i]) {
						shape->data = ball_sprites2[i];
						[ball_sprites[i] setPosition:ccp(-1000*i,-10000)];
					}
					else {
						shape->data = ball_sprites[i];
						[ball_sprites2[i] setPosition:ccp(-1000*i,-10000)];
					}
				}
			}
			sprite = shape->data;
		}
		else{
			// colour the ball if it stopped in a bed for slate and mahogany coins.
			for ( int i = 1 ; i <= current_ball_no; i++)
			{		
				if ( body == balls[i] )
				{
					ccColor3B yellow = {255,255,0};
					ccColor3B white  = {255,255,255};
					if ( ball_in_bed[i] )
						[sprite setColor:yellow];
					else
						[sprite setColor:white];
				}
			}
		}
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		// chipmunk uses: cpVect, and cocos2d uses CGPoint but in reality the are the same
		// since v0.7.1 you can mix them if you want.	
		
		[sprite setPosition: body->p];
		
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

// Implementation of main game logic..

@implementation Game


-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		gamelayer =  self;
		
		if (sound_on) {
			// this will load the sound into buffer and prevent freeze on first collision
			[[SimpleAudioEngine sharedEngine] playEffect:@"clink.wav" pitch:1.8 pan:1 gain:0];
			
		}
		
		CCMenuItem *infoMenuItem = [CCMenuItemImage 
		itemFromNormalImage:@"iup.png" selectedImage:@"idown.png" 
		target:self selector:@selector(menuCallbackQuit:)];
		infoMenuItem.position = ccp(700, 980);
		CCMenu *infoMenu = [CCMenu menuWithItems:infoMenuItem, nil];
		infoMenu.position = CGPointZero;
		infoMenu.opacity = 170;
		[self addChild:infoMenu z:3];		
		self.isTouchEnabled = YES;
		
		// Set up the chipmunk space..
		cpInitChipmunk();
		staticBody = cpBodyNew(INFINITY, INFINITY);
		
		space = cpSpaceNew();
		cpSpaceResizeStaticHash(space, 400.0f, 40);
		cpSpaceResizeActiveHash(space, 100, 600);
		space->gravity = ccp(0, 0);
		space->damping = 0.29f;
		space->elasticIterations = space->iterations;
		
		
		// Draw in Background // dependend on selected board..
		if ( board == 0 )
		{
			CCSprite *bg = [CCSprite spriteWithFile:@"board mahogany.png"];
			CGPoint point = CGPointMake(384,512);
			[bg setPosition:point];
			[self addChild:bg z:0];
		}
		if ( board == 1 )
		{
			CCSprite *bg = [CCSprite spriteWithFile:@"board slate.png"];
			CGPoint point = CGPointMake(384,512);
			[bg setPosition:point];
			[self addChild:bg z:0];
		}
		if ( board == 2 )
		{
			CCSprite *bg = [CCSprite spriteWithFile:@"board funky.png"];
			CGPoint point = CGPointMake(384,512);
			//bg.opacity = 100;
			[bg setPosition:point];
			[self addChild:bg z:0];
		}
		
		
		// Reset class instance variable to start of game.. and also global vars
		current_ball_no = 1;
		current_score = 0;    
		total_pen = 0;
	        new_coin = true;
		current_ball_no = 1;
		//Initial gamestate is flick coin.
		gamestate = coin_toflick;
		menu_shown = false;
		score_changed = false;
		for (int i=0; i < 9; i++) {
			player1_scores[i] = 0;
			player2_scores[i] = 0;
			player1_scores_temp[i] = 0;
			player2_scores_temp[i] = 0;
			player_1_scores_lbl[i] = nil;
			player_2_scores_lbl[i] = nil;
		}
		current_player = 1;
		game_over_balls_set = false;
		for (int i=0; i < 6; i++) {
			ball_in_bed[i] = false;
			ball_stopped[i] = 0;
		}
		ypos = nil;
		ypos2 = nil;
		thefont = nil;
		menu = nil;
		wall_collide = false;
		for (int i=0; i<9; i++) {
			for (int j=0; j<5; j++) {
				player1_round_scores[i][j] = 0;
			}
		}
		
		
		CGSize wins = [[CCDirector sharedDirector] winSize];
		
		if ( board == 0 )
		{
			// add the coin sprites...
			for ( int i = 1; i < 6 ; i++)
			{
				balls[i] = [self addSpriteNamed:@"coin.png" x:wins.width/2-i*1000 y:-7000.0f type: 0 coin_no : i]; 		
			}
		}
		else if ( board == 1 )
		{
			// add the coin sprites...
			for ( int i = 1; i < 6 ; i++)
			{
				balls[i] = [self addSpriteNamed:@"slatecoin.png" x:wins.width/2-i*1000 y:-7000.0f type: 0 coin_no : i]; 		
			}
			
		}
		else {
			// add the coin sprites...
			for ( int i = 1; i < 6 ; i++)
			{
				balls[i] = [self addSpriteNamed:@"funkycoin.png" x:wins.width/2-i*1000 y:-7000.0f type: 0 coin_no : i]; 		
			}
		}
			
		//Initialize boundaries
		[self createBoundingBox];
		
		// Set up collision handler for coin - wall.
		cpSpaceAddCollisionHandler(space, 0, 1, BeginColl, NULL, NULL, Seperate, NULL);
		// Set up collision handle for coin on coin 
		cpSpaceAddCollisionHandler(space, 0, 0, BeginCollc, NULL, NULL, Seperatec, NULL);
				
		// Display player Names
		NSString *Player_label;
		Player_label = Player1;
		
		if (two_player ) {
			player_label = [CCLabel labelWithString:Player_label dimensions:CGSizeMake(720,50) alignment:UITextAlignmentLeft fontName:@"Chalkboard"	fontSize:42];
			if ( board == 0 || board == 2 )
				player_label.color = ccc3(0,0,0);			
			//player_label = [CCLabel labelWithString:Player_label fontName:@"Marker Felt" fontSize:20]; 
			[player_label setPosition:ccp(384,37)];
			[self addChild:player_label z:3];
		}
		
		game_in_progress = TRUE;
		//[self addCheatButtons];
		
		// feature to retrieve the state of the game..
		[self Load_Game_State];
		[self display_scores];
				
		if ( !two_player)
		{
			NSString* displaystr = [NSString stringWithFormat:@"Practice Score %d", total_pen];
			
			if ( ypos)
			{
				[self removeChild:ypos cleanup:YES];
			}
						
			ypos = [CCLabel labelWithString:displaystr fontName:@"Chalkboard" fontSize:28];
					
			if ( board != 1 )
				ypos.color = ccc3(0,0,0);
			
			[self addChild: ypos];
			[ypos setPosition: ccp(384, 1024-140)];
		}
		
			
		// Set up timing loop...
		[self schedule: @selector(step:)];
				
	}
	return self;
	
}



-(void) game_logic
{
	switch (gamestate) {
		case coin_toflick:                         
		{
			if ( new_coin )
			{
				// Reset the coin position.
				balls[current_ball_no]->p.x = 384;
				balls[current_ball_no]->p.y = 100;
				new_coin = false;
			}
			break;
		}
		case coin_inplay:                           
		{
			// Re-mark all on-board coins as moving at this point
			for(int i = 1; i <= current_ball_no; i++ )
			{
				ball_stopped[i] = 0;
			}
			// check if all coins up to current ball have stopped..
			for (int  i = 1; i <= current_ball_no; i++ )
			{
				int CoinResult;
				//current_ball = balls[i];
				if ( current_ball_no < balls_per_round )
					CoinResult = [self Coin_StoppedCheck: true : 0: i];
				else
					CoinResult = [self Coin_StoppedCheck: true : 0: i];				
				
				if (CoinResult != Ball_moving)
				{
					ball_stopped[i] = 1; // mark this ball as stopped..
					// coin has stopped so highlight if in bed
					if (CoinResult > Ball_out_of_bed_stopped)
					{
						// coin in bed so highlight yellow
						ball_in_bed[i] = true;
					}
					else{
						ball_in_bed[i] = false;
					}
					if (ball_in_bed[i] == false && balls[i]->p.y <= 115*2.13 )
					{
						ball_stopped[i] = 0; // this effectivly stops it from being considered a stopped ball...
						gamestate = coin_toflick;
					}
				}
				else
				{
					//ball_stopped[i] = 0; // ball is still moving
				}
				
			}
			// if all balls have stopped then move to the coin stopped state..
			bool allstopped = true;
			for ( int i = 1; i <= current_ball_no; i++ )
			{
				if ( ball_stopped[i] == 0 )
					allstopped = false;
			}
			if ( allstopped )
			{
				for ( int i=1; i<= current_ball_no; i++ )
				{
					ball_stopped[i] = 0;
				}
				current_ball_no++;
				gamestate = coin_stopped;
				menu_shown = false;
			}
			break;
			
		}
		case coin_stopped :
		{
			if (!menu_shown) {
				score_added = false;	
				
				// Check here to see if game is complete 
				if ( two_player )
				{
					if ([self GameOver_two_player: current_ball_no-1]) {
						gamestate = game_over_two_player;
						break;
					}
				}
				else
				{
					if ([self GameOver: current_ball_no-1]) {
						gamestate = game_over;
						break;
					}
				}
				// Coin has stopped. if its less than number of coins then just go to next coin
				if ( current_ball_no <= balls_per_round )
				{
					if (menu)
					{
						[self removeChild:menu cleanup:YES];
						menu = nil;
					}	
					gamestate = coin_toflick;
					new_coin = true;
				}
				else
				{
					// Display the scores and calculate the round score..
					int before = 0;
					int after  = 0;
					for (int i=0; i<9; i++) {
						if (current_player == 1) {
							before += player1_scores[i];
							after  += player1_scores_temp[i];
						}
						else {
							before += player2_scores[i];
							after  += player2_scores_temp[i];
						}
						player1_scores[i] = player1_scores_temp[i];
						player2_scores[i] = player2_scores_temp[i];
					}
					score_this_round = after - before;
					[self display_scores];					
					
					if ( score_this_round > 1)
					{
						if ( wellDone )
							[self removeChild:wellDone cleanup:TRUE];
						
						switch(score_this_round) {
							case 2:
							{
								wellDone = [CCLabel labelWithString:@"Not Bad" fontName:@"Chalkboard" fontSize:120];
								break;
							}
							case 3:
							{
								wellDone = [CCLabel labelWithString:@"Way To Go" fontName:@"Chalkboard" fontSize:120];
								break;
							}
							case 4:
							{
								wellDone = [CCLabel labelWithString:@"Look At You" fontName:@"Chalkboard" fontSize:120];
								break;
							}
							case 5:
							{
								wellDone = [CCLabel labelWithString:@"High Five" fontName:@"Chalkboard" fontSize:120];								break;
							}
							default:
								break;
						}
						
						if ( score_this_round == 5 )
							[[SimpleAudioEngine sharedEngine] playEffect:@"highfive.wav" ];
						
						
						//id color_action = [CCTintBy actionWithDuration:0.5f red:0 green:-255 blue:-255];
						//id color_back = [color_action reverse];
						//id seq = [CCSequence actions:color_action, color_back, nil];
						
						// We want to run several actions at once
						//id action = [CCSpawn actions:
						//			 [CCScaleTo actionWithDuration:2.3f scale:0],
						//			 seq,
						//			 nil];
						
						
						
						
						[wellDone setPosition:ccp(384,512)];
					        wellDone.scale = 0.8f;
						
						 //wellDone.color = ccc3(255,0,0);
						if (board == 0) 
						{
							wellDone.color = ccc3(147,53,0);
						}
						else if ( board == 1 )
						{
							wellDone.color = ccc3(255,255,255);
						}
						else 
						{
							wellDone.color = ccc3(215,82,215);
						}

						id fadeout = [CCFadeOut actionWithDuration:2.0f];
						id action = [CCSequence actions:fadeout,nil];
						
						[wellDone runAction:action];
						
						[self addChild: wellDone z:3];						
					}
					
					
					
					// now scores are displayed... move on to next round..
					
					if ( !two_player )
					{
						if (add_pen) {
							total_pen += (5-score_this_round)*10;
							score_added = true;
							
						}
						else {
							add_pen = TRUE;
						}
						
						
						// temp display score this round.
						// DEBUG
						NSString* displaystr = [NSString stringWithFormat:@"Practice Score %d", total_pen];
						
						if ( ypos)
						{
							[self removeChild:ypos cleanup:YES];
						}
						
						
						ypos = [CCLabel labelWithString:displaystr fontName:@"Chalkboard" fontSize:28 ];
						
						
						
						if ( board != 1 )
							ypos.color = ccc3(0,0,0);
						
						[self addChild: ypos];
						[ypos setPosition: ccp(384, 1024-140)];
					}
					
					// Display touch screen.
					if (menu)
					{
						[self removeChild:menu cleanup:YES];
						menu = nil;
					}	
					[CCMenuItemFont setFontSize:42];
					[CCMenuItemFont setFontName: @"Chalkboard"];
					
					if (two_player) {
						thefont =  [CCMenuItemFont itemFromString: @"Next Player" target:self selector:@selector(menuCallbackTap:)];
					}
					else
					{
						thefont =  [CCMenuItemFont itemFromString: @"Next Round" target:self selector:@selector(menuCallbackTap:)];
					}
   				   
					
					// Set the color of next player or next round....
					if ( board == 0 )
						thefont.color = ccc3(255,255,255);
					else if ( board == 1 )
						thefont.color = ccc3(255,255,255);
					else {
						thefont.color = ccc3(255,255,255);
					}

						
					
					
					menu = [CCMenu menuWithItems: thefont, nil];
					menu.opacity = 200;
					
					
					if (score_this_round > 1) {
						thefont.scale = 2;
						thefont.opacity = 0;
						[menu setPosition:ccp(384,110)];
						id actionTo = [CCMoveTo actionWithDuration: 2.8f position:ccp(384,110)];
						id actionCent = [CCFadeIn actionWithDuration:0.4f ];
 					    [menu runAction:[CCSequence actions:actionTo,actionCent,nil]]; 
						
					}
					else
					{
						thefont.scale = 2;
						thefont.opacity = 0;
						[menu setPosition:ccp(384,110)];
						id actionCent = [CCFadeIn actionWithDuration:0.4f ];
 					    [menu runAction:[CCSequence actions:actionCent,nil]]; 
					}
					
					[self addChild: menu];
							
				}
				menu_shown = true;
			}
			break;
		}
		case game_over:
		{
			if (!game_over_balls_set)
			{
				// remove the game_state file here
				[self Delete_Game_State];
				
				
				
				// Add the new game and menu button 
				// back to menu
				[CCMenuItemFont setFontSize:50];
				[CCMenuItemFont setFontName: @"Chalkboard"];
				//CCMenuItem *item4 = [CCMenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallbackEnable:)];
				CCMenuItemFont *item1 = [CCMenuItemFont itemFromString: @"Menu" target: self selector:@selector(menuCallbackQuit:)];
				backtomenu = [CCMenu menuWithItems: item1, nil];
				//[menu alignItemsVertically];
				[backtomenu setPosition:ccp(768-120,50)];
				[self addChild: backtomenu z:3];
				
				// back to menu
				[CCMenuItemFont setFontSize:50];
				[CCMenuItemFont setFontName: @"Chalkboard"];
				//CCMenuItem *item4 = [CCMenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallbackEnable:)];
				newGameFont = [CCMenuItemFont itemFromString: @"New Game" target: self selector:@selector(menuCallbackNew:)];
				newGame = [CCMenu menuWithItems: newGameFont, nil];
				//[menu alignItemsVertically];
				[newGame setPosition:ccp(150,50)];
				[self addChild: newGame z:3];						
								
				
				
				
				// ok here we setup the high score table..
				struct penalty_score_entry structArray[10];				
				NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];	
				int ii = -1;
				// get the current high score values from disk into the array.
				for (int i = 0; i < 10; i++) {
					if ([userPreferences stringForKey:[NSString stringWithFormat:@"highScoreDateEntry%d", i]] != nil && [userPreferences stringForKey:[NSString stringWithFormat:@"highScoreEntry%d", i]] != nil) {
						structArray[i].the_date = [userPreferences stringForKey:[NSString stringWithFormat:@"highScoreDateEntry%d", i]];
						structArray[i].PenaltyScore = [userPreferences integerForKey:[NSString stringWithFormat:@"highScoreEntry%d", i]];
						ii = i;
					}
				}
				// get the current date as a string
				NSDate* date = [NSDate date];
				//Create the dateformatter object
				NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
				//Set the required date format
				[formatter setDateFormat:@"dd-MM-yyyy"];
				//Get the string date
				
				NSString* str = [formatter stringFromDate:date];
				
				// ok we have the score in total_pen and the date, so bubble sort it in the array list.... remembereing to have the lowest score first..
				for (int i = ii; i >= 0; i--) {
					if (total_pen < structArray[i].PenaltyScore) {
						if (i < 9)
							structArray[i + 1] = structArray[i];
						structArray[i].the_date = str;
						structArray[i].PenaltyScore = total_pen;
						if (i == ii && ii < 9)
							ii =  i + 1;
					}
					else if (i == ii && i < 9) {
						structArray[i + 1].the_date = str;
						structArray[i + 1].PenaltyScore = total_pen;
						ii = i + 1;
					}
				}
				// if there were no entries then ii will be -1 so put it in here..
				if (ii == -1 ) {
					structArray[0].the_date = str;
					structArray[0].PenaltyScore = total_pen;
					ii = 0;
				}	
				
				
				// save high score to list..
				for (int i = 0; i <= ii; i++) {
					[userPreferences setObject:structArray[i].the_date forKey:[NSString stringWithFormat:@"highScoreDateEntry%d", i]];
					[userPreferences setInteger:structArray[i].PenaltyScore forKey:[NSString stringWithFormat:@"highScoreEntry%d", i]];
				}
				
				
				if (sound_on) {
					[[SimpleAudioEngine sharedEngine] playEffect:@"cheers.wav"];
				}
				
				for (int i=0; i < 6; i++) {
					ball_in_bed[i] = false;
					ball_stopped[i] = 0;
				}
				
				if ( ypos)
				{
					[self removeChild:ypos cleanup:YES];
				}
				
				
				ypos = [CCLabel labelWithString:@"Game Over" fontName:@"Chalkboard" fontSize:88 ];
				
				
				
				if ( board != 1 )
					ypos.color = ccc3(0,0,0);
				
				
				// animate Game over....
				//id color_action = [CCFadeOut actionWithDuration:0.5f ];
				//id color_back = [color_action reverse];
				//id seq = [CCSequence actions:color_action, color_back, nil];
				
				
				
				//[ypos runAction:[CCRepeatForever actionWithAction:seq]];
				[self addChild: ypos z:3];
				[ypos setPosition: ccp(384, 512)];
				
				
				
				if ( ypos2)
				{
					[self removeChild:ypos2 cleanup:YES];
				}
			 	
				NSString* displaystr = [NSString stringWithFormat:@"Score %d", total_pen];
				
				ypos2 = [CCLabel labelWithString:displaystr fontName:@"Chalkboard" fontSize:88 ];
				
				
				
				
				if ( board != 1 )
					ypos2.color = ccc3(0,0,0);
				
				
				[self addChild: ypos2 z:3];
				[ypos2 setPosition: ccp(384, 412)];
				
				
				// set the balls off 
				
				space->damping = 1;
				
				balls[1] -> p.x = 0+60*2.13;
				balls[1] -> p.y = 100*2.13;
				balls[1] -> v.y = 200*2.13;
				balls[1] -> v.x = 50*2.13;
				balls_shapes[1]->e = 1.0f;
				
				
				balls[2] -> p.x = (50+60)*2.13;
				balls[2] -> p.y = 400*2.13;
				balls[2] -> v.y = -200*2.13;
				balls[2] -> v.x = -50*2.13;
				balls_shapes[2]->e = 1.0f;
				
				
				
				balls[3] -> p.x = (100+60)*2.13;
				balls[3] -> p.y = 100*2.13;
				balls[3] -> v.y = 200*2.13;
				balls[3] -> v.x = -50*2.13;
				balls_shapes[3]->e = 1.0f;
				
				
				balls[4] -> p.x = (150+60)*2.13;
				balls[4] -> p.y = 400*2.13;
				balls[4] -> v.y = -200*2.13;
				balls[4] -> v.x = 50*2.13;
				balls_shapes[4]->e = 1.0f;
				
				
				balls[5] -> p.x = (200+60)*2.13;
				balls[5] -> p.y = 100*2.13;
				balls[5] -> v.y = 200*2.13;
				balls[5] -> v.x = -50*2.13;
				balls_shapes[5]->e = 1.0f;
				
				current_ball_no=5;
				
				game_over_balls_set = true;
				
			}
			break;
		}
		case game_over_two_player:
		{
			if (!game_over_balls_set)
			{
				// remove the game_state file here
				[self Delete_Game_State];
				
				if (player_label) {
					[self removeChild:player_label cleanup:YES];
				}	
				
				
				// Add the new game and menu button 
				// back to menu
				[CCMenuItemFont setFontSize:50];
				[CCMenuItemFont setFontName: @"Chalkboard"];
				//CCMenuItem *item4 = [CCMenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallbackEnable:)];
				CCMenuItemFont *item1 = [CCMenuItemFont itemFromString: @"Menu" target: self selector:@selector(menuCallbackQuit:)];
				backtomenu = [CCMenu menuWithItems: item1, nil];
				//[menu alignItemsVertically];
				[backtomenu setPosition:ccp(768-120,50)];
				[self addChild: backtomenu z:3];
				
				// back to menu
				[CCMenuItemFont setFontSize:50];
				[CCMenuItemFont setFontName: @"Chalkboard"];
				//CCMenuItem *item4 = [CCMenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallbackEnable:)];
				newGameFont = [CCMenuItemFont itemFromString: @"New Game" target: self selector:@selector(menuCallbackNew:)];
				newGame = [CCMenu menuWithItems: newGameFont, nil];
				//[menu alignItemsVertically];
				[newGame setPosition:ccp(120,50)];
				[self addChild: newGame z:3];		
				
				
				if (sound_on) {
					[[SimpleAudioEngine sharedEngine] playEffect:@"cheers.wav"];
				}
				
				for (int i=0; i < 6; i++) {
					ball_in_bed[i] = false;
					ball_stopped[i] = 0;
				}
				
				if ( ypos)
				{
					[self removeChild:ypos cleanup:YES];
				}
				
				
				ypos = [CCLabel labelWithString:@"Game Over" fontName:@"Chalkboard" fontSize:44 ];

				if ( board != 1 )
					ypos.color = ccc3(0,0,0);
				
				
				//[self addChild: ypos z:3];
				//[ypos setPosition: ccp(160, 240)];
				
				
				
				if ( ypos2)
				{
					[self removeChild:ypos2 cleanup:YES];
				}
			 	
				NSString* displaystr; // = [NSString stringWithFormat:@"Score %d", total_pen];
				if (current_player == 1) {
					displaystr = Player1; 
					displaystr = [displaystr stringByAppendingFormat:@" Wins"];
				}
				else {
					displaystr = Player2;
					displaystr = [displaystr stringByAppendingFormat:@" Wins"];
				}
				
				
				
				ypos2 = [CCLabel labelWithString:displaystr fontName:@"Chalkboard" fontSize:88 ];
				
				
				
				
				if ( board != 1 )
					ypos2.color = ccc3(0,0,0);
				
				
				[self addChild: ypos2 z:3];
				[ypos2 setPosition: ccp(384, 512)];
				
				
				// set the balls off 
				
				space->damping = 1;
				
				balls[1] -> p.x = 0+60*2.13;
				balls[1] -> p.y = 100*2.13;
				balls[1] -> v.y = 200*2.13;
				balls[1] -> v.x = 50*2.13;
				balls_shapes[1]->e = 1.0f;
				
				
				balls[2] -> p.x = (50+60)*2.13;
				balls[2] -> p.y = 400*2.13;
				balls[2] -> v.y = -200*2.13;
				balls[2] -> v.x = -50*2.13;
				balls_shapes[2]->e = 1.0f;
				
				
				
				balls[3] -> p.x = (100+60)*2.13;
				balls[3] -> p.y = 100*2.13;
				balls[3] -> v.y = 200*2.13;
				balls[3] -> v.x = -50*2.13;
				balls_shapes[3]->e = 1.0f;
				
				
				balls[4] -> p.x = (150+60)*2.13;
				balls[4] -> p.y = 400*2.13;
				balls[4] -> v.y = -200*2.13;
				balls[4] -> v.x = 50*2.13;
				balls_shapes[4]->e = 1.0f;
				
				
				balls[5] -> p.x = (200+60)*2.13;
				balls[5] -> p.y = 100*2.13;
				balls[5] -> v.y = 200*2.13;
				balls[5] -> v.x = -50*2.13;
				balls_shapes[5]->e = 1.0f;
				
				current_ball_no=5;
								
				game_over_balls_set = true;
				
			}
			break;
		}
		default:
			break;
	}
}

// Main Game loop..
-(void) step: (ccTime) delta {
	
	[self game_logic ];
	
	int steps = 1;
	cpFloat dt = delta/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
	
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);
} 


-(bool) GameOver: (int)ball_no;
{
	// transfer player_1_scores to player1_scores_temp
	for ( int i=0; i < 9; i++ )
	{
		player1_scores_temp[i] = player1_scores[i];
		player2_scores_temp[i] = player2_scores[i];
	}
	
	// Get the score at this point and put it in player1_scores_temp
	score_changed = true;
	for ( int i=0; i < 9; i++ ){
		int bed_score = 0;			
		for ( int j=0; j < 5; j++ ){
			if ( player1_round_scores[i][j] == 1 )
			{
				bed_score++;
			}
		}
		
		player1_scores_temp[i] += bed_score;
		
		
		// if scores over 3 then player 2 gets points
		if ( player1_scores_temp[i] > 3 )
		{
			player2_scores_temp[i] += ( player1_scores_temp[i] - 3 );
		}
		if ( player2_scores_temp[i] > 3 )
		{
			player2_scores_temp[i] = 3;
		}
		
		if ( player1_scores_temp[i] > 3 )
		{
			player1_scores_temp[i] = 3;
		}
	}
	
	// ok we now have the current score in player 1 temp lets see if the game is over...
	bool ret_value = YES;
	for ( int i=0; i < 9; i++ )
	{
		if ( player1_scores_temp[i] != 3 )
			ret_value = NO;
	}
	
	// TODO if the game is finished then update the score board..
	
	
	// if game over then update the score board..
	if (ret_value)
	{
		if ( score_changed )
		{	
			score_changed = false;
			// update temp files
			int before = 0;
			int after  = 0;
			for (int i=0; i<9; i++) {
				if (current_player == 1) {
					before += player1_scores[i];
					after  += player1_scores_temp[i];
				}
				else {
					before += player2_scores[i];
					after  += player2_scores_temp[i];
				}
				player1_scores[i] = player1_scores_temp[i];
				player2_scores[i] = player2_scores_temp[i];
			}
			score_this_round = after - before;
			[ self display_scores ];
		    // if ret value also display game over and total penalty points...
		    total_pen += (ball_no-score_this_round) * 10;
			
		}
	}

	return ret_value;
}

-(bool) GameOver_two_player: (int)ball_no;
{
	// transfer scores_temp
	for ( int i=0; i < 9; i++ )
	{
		player1_scores_temp[i] = player1_scores[i];
		player2_scores_temp[i] = player2_scores[i];
	}
	
	// Get the score at this point and put it in player1_scores_temp
	score_changed = true;
	for ( int i=0; i < 9; i++ ){
		int bed_score = 0;			
		for ( int j=0; j < 5; j++ ){
			if ( player1_round_scores[i][j] == 1 )
			{
				bed_score++;
			}
		}
		
		if ( current_player == 1 )
		{
			player1_scores_temp[i] += bed_score;
			if ( player1_scores_temp[i] > 3 )
			{
				player2_scores_temp[i] += ( player1_scores_temp[i] - 3 );
				// if this causes player 2 to win then reduce this to 2 and get rid of one of the scoreing coins..
				int player_2_win = 0;
				for (int j = 0; j < 9; j++) {
					if ( player2_scores_temp[j] < 3 )
						player_2_win = 1;
				}
				
				if (player_2_win == 0) {
					// this would cause it to win so remove it...
					player2_scores_temp[i] = 2;
					for (int j=0; j < 5; j++) {
						if ( player1_round_scores[i][j] == 1 )
						{
							player1_round_scores[i][j] = 0;
							break;
						}
						
					}
				}
			}
		}
		else
		{
			player2_scores_temp[i] += bed_score;
			if ( player2_scores_temp[i] > 3 )
			{
				player1_scores_temp[i] += ( player2_scores_temp[i] - 3 );
				
				// if this causes player 1 to win then reduce this to 2 and get rid of one of the scoreing coins..
				int player_1_win = 0;
				for (int j = 0; j < 9; j++) {
					if ( player1_scores_temp[j] < 3 )
						player_1_win = 1;
				}
				
				if (player_1_win == 0) {
					// this would cause it to win so remove it...
					player1_scores_temp[i] = 2;
					for (int j=0; j < 5; j++) {
						if ( player1_round_scores[i][j] == 1 )
						{
							player1_round_scores[i][j] = 0;
							break;
						}
						
					}
				}
			}
			
		}
		
		
		if ( player2_scores_temp[i] > 3 )
		{
			player2_scores_temp[i] = 3;
		}
		
		if ( player1_scores_temp[i] > 3 )
		{
			player1_scores_temp[i] = 3;
		}
	}
	
	// ok we now have the current score in player 1 temp lets see if the game is over...
	bool ret_value = YES;
	
	if (current_player == 1 )
	{
		for ( int i=0; i < 9; i++ )
		{
			if ( player1_scores_temp[i] != 3 )
				ret_value = NO;
		}
	}
	else
	{
		for ( int i=0; i < 9; i++ )
		{
			if ( player2_scores_temp[i] != 3 )
				ret_value = NO;
		}
	}
	
	// if game over then update the score board..
	if (ret_value)
	{
		if ( score_changed ){	
			score_changed = false;
			for (int i=0; i<9; i++) {
				player1_scores[i] = player1_scores_temp[i];
				player2_scores[i] = player2_scores_temp[i];
			}
			[ self display_scores];
			
			
		}
	}
	return ret_value;
}


-(int) Coin_StoppedCheck: (bool)score_it :(int) ball: (int)ball_no
{
	int the_result = Ball_moving;
	if( abs(balls[ball_no] -> v.x) <= 0.001 && abs(balls[ball_no] -> v.y) <= 0.001 && wall_collide == false) 
	{
		// stop the coin 
		balls[ball_no] -> v.y = 0.0;
		balls[ball_no] -> v.x = 0.0;		
		
		ball = ball_no-1;
		the_result = Ball_out_of_bed_stopped;
		// ball has stopped, so notify
		int myInt = balls[ball_no] -> p.y + 0.5;
				
		
		int high[9] = {0,0,0,0,0,0,0,0,0};
		int low[9]  = {0,0,0,0,0,0,0,0,0};
		
		// reset the player1_round scores so its re-scored correctly
		// and copy the calibration fig..
		for (int i=0; i < 9 ;i++) {
			player1_round_scores[i][ball] = 0;
			if (board == 0) {
				high[i] = m_calibrate_h[i];
				low[i]  = m_calibrate_l[i];
			}
			else if ( board ==1 )
			{
				high[i] = m_calibrate_h[i];
				low[i]  = m_calibrate_l[i];
			}
			else
			{
				high[i] = m_calibrate_h[i];
				low[i]  = m_calibrate_l[i];
			}			
		}
		
		
		// Now Determine if the coin landed in a bed
		if (myInt >= low[0] && myInt <= high[0] )
		{
			the_result = Ball_in_bed_1_stopped;
			if (score_it)
				player1_round_scores[0][ball] = 1;
		}
		if (myInt >= low[1] && myInt <= high[1] )
		{
			the_result = Ball_in_bed_2_stopped;
			if (score_it)
				player1_round_scores[1][ball] =1;
		}
		if (myInt >= low[2] && myInt <= high[2] )
		{
			the_result = Ball_in_bed_3_stopped;
			if (score_it)
				player1_round_scores[2][ball] = 1;
		}
		if (myInt >= low[3] && myInt <= high[3] )
		{
			the_result = Ball_in_bed_4_stopped;
			if (score_it)
				player1_round_scores[3][ball] = 1;
		}
		if (myInt >= low[4] && myInt <= high[4] )
		{
			the_result = Ball_in_bed_5_stopped;
			if (score_it)
				player1_round_scores[4][ball] = 1;
		}
		if (myInt >= low[5] && myInt <= high[5] )
		{
			the_result = Ball_in_bed_6_stopped;
			if (score_it)
				player1_round_scores[5][ball] = 1;
		}
		if (myInt >= low[6] && myInt <= high[6] )
		{
			the_result = Ball_in_bed_7_stopped;
			if (score_it)
				player1_round_scores[6][ball]=1;
		}
		if (myInt >= low[7] && myInt <= high[7] )
		{
			the_result = Ball_in_bed_8_stopped;
			if (score_it)
				player1_round_scores[7][ball]=1;
		}
		if (myInt >= low[8] && myInt <= high[8] )
		{
			the_result = Ball_in_bed_9_stopped;
			if (score_it)
				player1_round_scores[8][ball]=1;
		}
		
	}
	
    return the_result;
}


// Go to Main Menu
-(void) menuCallbackQuit:(id) sender
{
	theScene = [CCScene node];
	[theScene addChild:[MainMenu node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipXTransition transitionWithDuration:1.0f scene:theScene ]];
	
	/*autostart = true;
	theScene = [CCScene node];
	[theScene addChild:[MainMenu node] z:0];
	[[CCDirector sharedDirector] replaceScene : theScene ];*/

}


// New Game go to splash screen.
-(void) menuCallbackNew:(id) sender
{
	autostart = true;
	theScene = [CCScene node];
	[theScene addChild:[MainMenu node] z:0];
	[[CCDirector sharedDirector] replaceScene : theScene ];
	
}

// new ball
-(void) menuCallbackTap:(id) sender
{
	score_this_round = 0;
	
	if ( HighFiveLabel )
	{
		[self removeChild:HighFiveLabel cleanup:YES];
		HighFiveLabel = nil;
	}
	if ( HighFiveLabel2)
	{
		[self removeChild:HighFiveLabel2 cleanup:YES];
		HighFiveLabel2 = nil;
	}
	
	if ( two_player )
	{
		//swap players
		
		if ( current_player == 1 )
			current_player = 2;
		else
			current_player = 1;
		
		[self removeChild:player_label cleanup:YES];
		
		if ( current_player == 1 )
		{
			player_label = [CCLabel labelWithString:Player1 dimensions:CGSizeMake(720,50) alignment:UITextAlignmentLeft fontName:@"Chalkboard"	fontSize:42];
			if ( board == 0 || board == 2 )
				player_label.color = ccc3(0,0,0);
			
			[player_label setPosition:ccp(384,37)];
			[self addChild:player_label z:3];
		}
		else 
		{
			player_label = [CCLabel labelWithString:Player2 dimensions:CGSizeMake(720,50) alignment:UITextAlignmentRight fontName:@"Chalkboard"	fontSize:42];
			if ( board == 0 || board == 2 )
				player_label.color = ccc3(0,0,0);
			
			[player_label setPosition:ccp(384,37)];
			[self addChild:player_label z:3];
			
		}
		
		
		
	}
	
	
	current_ball_no = 1;
	if (menu)
	{
		[self removeChild:menu cleanup:NO];
		menu = nil;
	}	
	gamestate = coin_toflick;
	new_coin = true;
	menu_shown = false;
	for ( int i = 1; i <= balls_per_round ; i++ )
	{
		// reset scores..
		for (int j=0; j<9; j++) {
			player1_round_scores[j][i-1]=0;
		}
		ball_in_bed[i] = false;
		ball_stopped[i] = 0;
		balls[i] -> p.y = -7000-i*1000;
	}
}


// add sprite routine and put item into the chipmunk space..
-(cpBody *) addSpriteNamed: (NSString *)name x: (float)x y:(float)y type:(unsigned int) type coin_no: (unsigned int) coin_no
{
	// Add the thing as a sprite
	UIImage *image = [UIImage imageNamed:name]; 
	//CCSprite *sprite = [CCSprite spriteWithFile:name];
	ball_sprites[coin_no] = [CCSprite spriteWithFile:name];
	ball_sprites2[coin_no] = [CCSprite spriteWithFile:@"funk3.png"];
	[self addChild: ball_sprites[coin_no] z:2];
	[self addChild: ball_sprites2[coin_no] z:2];
	ball_sprites2[coin_no].position = ccp (-1000*coin_no, -10000);
	ball_sprites[coin_no].position = ccp( x, y);
	
	int num_vertices = 4;
	cpVect verts[] = {
		cpv([image size].width/2 * -1, [image size].height/2 * -1),
		cpv([image size].width/2 * -1, [image size].height/2),
		cpv([image size].width/2, [image size].height/2),
		cpv([image size].width/2, [image size].height/2 * -1)
	};
	
	cpBody *body;
	
	body = cpBodyNew(1.0, cpMomentForPoly(1.0, num_vertices, verts, cpvzero));
	
	body->p = cpv(x, y);
	
	cpSpaceAddBody(space, body);
	
	balls_shapes[coin_no] = cpCircleShapeNew(body, [image size].width / 2, cpvzero);
	
	balls_shapes[coin_no]->data = ball_sprites[coin_no];
	
	balls_shapes[coin_no]->e = 0.5f; // elasticity
	balls_shapes[coin_no]->u = 1.0f; // friction
	
	
    cpSpaceAddShape(space, balls_shapes[coin_no]);	
	return body;
}

// This routine set the bounding collision walls of the chipmunk space..
- (void)createBoundingBox
{
	
	cpShape *squareShape;	
	cpVect squared[100];
	
	
	CGSize wins = [[CCDirector sharedDirector] winSize];
	
	switch (board) {
		case 0:
		{
			// top is split into 8 segments 
			
			// segment 1
			squared[0] = ccp (-2000,wins.height+2000);
			squared[1] = ccp (98,wins.height+2000);
			squared[2] = ccp (98,wins.height-153);
			squared[3] = ccp (-2000,wins.height-153);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			// segment 2
			squared[0] = ccp (98,wins.height+2000);
			squared[1] = ccp (223,wins.height+2000);
			squared[2] = ccp (223,wins.height-106);
			squared[3] = ccp (98,wins.height-153);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 3
			squared[0] = ccp (223,wins.height+2000);
			squared[1] = ccp (259,wins.height+2000);
			squared[2] = ccp (259,wins.height-97);
			squared[3] = ccp (223,wins.height-106);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 4
			squared[0] = ccp (259,wins.height+2000);
			squared[1] = ccp (384,wins.height+2000);
			squared[2] = ccp (384,wins.height-88);
			squared[3] = ccp (259,wins.height-97);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
						
			// segment 5
			squared[0] = ccp (384,wins.height+2000);
			squared[1] = ccp (768-259,wins.height+2000);
			squared[2] = ccp (768-259,wins.height-97);
			squared[3] = ccp (384,wins.height-88);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
						
			// segment 6
			squared[0] = ccp (768-259,wins.height+2000);
			squared[1] = ccp (768-223,wins.height+2000);
			squared[2] = ccp (768-223,wins.height-106);
			squared[3] = ccp (768-259,wins.height-97);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 7
			squared[0] = ccp (768-223,wins.height+2000);
			squared[1] = ccp (768-98,wins.height+2000);
			squared[2] = ccp (768-98,wins.height-153);
			squared[3] = ccp (768-223,wins.height-106);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 8
			squared[0] = ccp (768-98,wins.height+2000);
			squared[1] = ccp (wins.width+2000,wins.height+2000);
			squared[2] = ccp (wins.width+2000,wins.height-153);
			squared[3] = ccp (768-98,wins.height-153);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// Bottom section is in 4 segments
			
			// Bottom Left top 
			
			squared[0] = ccp ( -2000,wins.height-153);
			squared[1] = ccp (58,wins.height-153);
			squared[2] = ccp (58,wins.height-767);
			squared[3] = ccp (-2000,wins.height-767);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
						
			// bottom left bottom
						
			squared[0] = ccp (-4000,wins.height);
			squared[1] = ccp (0,wins.height);
			squared[2] = ccp (0,-4000);
			squared[3] = ccp (-4000,-4000);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);			
			
			// Bottom Right top 
			
			squared[0] = ccp ( wins.width-58,wins.height-153);
			squared[1] = ccp (wins.width+2000,wins.height-153);
			squared[2] = ccp (wins.width+2000,wins.height-767);
			squared[3] = ccp (wins.width-58,wins.height-767);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			// bottom Right bottom
			
			squared[0] = ccp (wins.width,wins.height);
			squared[1] = ccp (wins.width+4000,wins.height);
			squared[2] = ccp (wins.width+4000,-4000);
			squared[3] = ccp (wins.width,-4000);
			
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
				
			// finally the bottom boundary
			squared[0] = ccp (-2000,0);
			squared[1] = ccp (wins.width+2000,0);
			squared[2] = ccp (wins.width+2000,-2000);
			squared[3] = ccp (-2000,-2000);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
			
		}
			
		break;
		case 1:
		{
			// top is split into 8 segments 
			
			// segment 1
			squared[0] = ccp (-2000,wins.height+2000);
			squared[1] = ccp (98,wins.height+2000);
			squared[2] = ccp (98,wins.height-153);
			squared[3] = ccp (-2000,wins.height-153);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			// segment 2
			squared[0] = ccp (98,wins.height+2000);
			squared[1] = ccp (223,wins.height+2000);
			squared[2] = ccp (223,wins.height-106);
			squared[3] = ccp (98,wins.height-153);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 3
			squared[0] = ccp (223,wins.height+2000);
			squared[1] = ccp (259,wins.height+2000);
			squared[2] = ccp (259,wins.height-97);
			squared[3] = ccp (223,wins.height-106);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 4
			squared[0] = ccp (259,wins.height+2000);
			squared[1] = ccp (384,wins.height+2000);
			squared[2] = ccp (384,wins.height-88);
			squared[3] = ccp (259,wins.height-97);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			
			// segment 5
			squared[0] = ccp (384,wins.height+2000);
			squared[1] = ccp (768-259,wins.height+2000);
			squared[2] = ccp (768-259,wins.height-97);
			squared[3] = ccp (384,wins.height-88);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			// segment 6
			squared[0] = ccp (768-259,wins.height+2000);
			squared[1] = ccp (768-223,wins.height+2000);
			squared[2] = ccp (768-223,wins.height-106);
			squared[3] = ccp (768-259,wins.height-97);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 7
			squared[0] = ccp (768-223,wins.height+2000);
			squared[1] = ccp (768-98,wins.height+2000);
			squared[2] = ccp (768-98,wins.height-153);
			squared[3] = ccp (768-223,wins.height-106);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 8
			squared[0] = ccp (768-98,wins.height+2000);
			squared[1] = ccp (wins.width+2000,wins.height+2000);
			squared[2] = ccp (wins.width+2000,wins.height-153);
			squared[3] = ccp (768-98,wins.height-153);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// Bottom section is in 4 segments
			
			// Bottom Left top 
			
			squared[0] = ccp ( -2000,wins.height-153);
			squared[1] = ccp (58,wins.height-153);
			squared[2] = ccp (58,wins.height-767);
			squared[3] = ccp (-2000,wins.height-767);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
			
			
			// bottom left bottom
			
			
			squared[0] = ccp (-4000,wins.height);
			squared[1] = ccp (0,wins.height);
			squared[2] = ccp (0,-4000);
			squared[3] = ccp (-4000,-4000);
			
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);
			
			
			
			// Bottom Right top 
			
			squared[0] = ccp ( wins.width-58,wins.height-153);
			squared[1] = ccp (wins.width+2000,wins.height-153);
			squared[2] = ccp (wins.width+2000,wins.height-767);
			squared[3] = ccp (wins.width-58,wins.height-767);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			// bottom Right bottom
			
			squared[0] = ccp (wins.width,wins.height);
			squared[1] = ccp (wins.width+4000,wins.height);
			squared[2] = ccp (wins.width+4000,-4000);
			squared[3] = ccp (wins.width,-4000);
			
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
			
					
			// finally the bottom boundary
			squared[0] = ccp (-2000,0);
			squared[1] = ccp (wins.width+2000,0);
			squared[2] = ccp (wins.width+2000,-2000);
			squared[3] = ccp (-2000,-2000);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);				
		}
		break;
		case 2:
		{
			// top is split into 8 segments 
			
			// segment 1
			squared[0] = ccp (-2000,wins.height+2000);
			squared[1] = ccp (98,wins.height+2000);
			squared[2] = ccp (98,wins.height-147);
			squared[3] = ccp (-2000,wins.height-147);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			// segment 2
			squared[0] = ccp (98,wins.height+2000);
			squared[1] = ccp (223,wins.height+2000);
			squared[2] = ccp (223,wins.height-111);
			squared[3] = ccp (98,wins.height-147);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 3
			squared[0] = ccp (223,wins.height+2000);
			squared[1] = ccp (259,wins.height+2000);
			squared[2] = ccp (259,wins.height-105);
			squared[3] = ccp (223,wins.height-111);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 4
			squared[0] = ccp (259,wins.height+2000);
			squared[1] = ccp (384,wins.height+2000);
			squared[2] = ccp (384,wins.height-97);
			squared[3] = ccp (259,wins.height-105);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			
			// segment 5
			squared[0] = ccp (384,wins.height+2000);
			squared[1] = ccp (768-259,wins.height+2000);
			squared[2] = ccp (768-259,wins.height-105);
			squared[3] = ccp (384,wins.height-97);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			// segment 6
			squared[0] = ccp (768-259,wins.height+2000);
			squared[1] = ccp (768-223,wins.height+2000);
			squared[2] = ccp (768-223,wins.height-111);
			squared[3] = ccp (768-259,wins.height-105);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 7
			squared[0] = ccp (768-223,wins.height+2000);
			squared[1] = ccp (768-98,wins.height+2000);
			squared[2] = ccp (768-98,wins.height-147);
			squared[3] = ccp (768-223,wins.height-111);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// segment 8
			squared[0] = ccp (768-98,wins.height+2000);
			squared[1] = ccp (wins.width+2000,wins.height+2000);
			squared[2] = ccp (wins.width+2000,wins.height-147);
			squared[3] = ccp (768-98,wins.height-147);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			// Bottom section is in 4 segments
			
			// Bottom Left top 
			
			squared[0] = ccp ( -2000,wins.height-147);
			squared[1] = ccp (67,wins.height-153);
			squared[2] = ccp (67,wins.height-767);
			squared[3] = ccp (-2000,wins.height-767);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
			
			
			squared[0] = ccp (67,wins.height-767);
			squared[1] = ccp (34,wins.height-780);
			squared[2] = ccp (0,wins.height-767);
			
			squareShape = cpPolyShapeNew(staticBody, 3, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
			
			squared[2] = ccp (wins.width-67,wins.height-767);
			squared[1] = ccp (wins.width-34,wins.height-780);
			squared[0] = ccp (wins.width,wins.height-767);
			
			squareShape = cpPolyShapeNew(staticBody, 3, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
			
			
			
			// bottom left bottom
			
			
			squared[0] = ccp (-4000,wins.height);
			squared[1] = ccp (0,wins.height);
			squared[2] = ccp (0,-4000);
			squared[3] = ccp (-4000,-4000);
			
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);
			
			
			
			// Bottom Right top 
			
			squared[0] = ccp ( wins.width-67,wins.height-147);
			squared[1] = ccp (wins.width+2000,wins.height-147);
			squared[2] = ccp (wins.width+2000,wins.height-767);
			squared[3] = ccp (wins.width-67,wins.height-767);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);		
			
			
			// bottom Right bottom
			
			squared[0] = ccp (wins.width,wins.height);
			squared[1] = ccp (wins.width+4000,wins.height);
			squared[2] = ccp (wins.width+4000,-4000);
			squared[3] = ccp (wins.width,-4000);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
			
			
			
			// finally the bottom boundary
			squared[0] = ccp (-2000,0);
			squared[1] = ccp (wins.width+2000,0);
			squared[2] = ccp (wins.width+2000,-2000);
			squared[3] = ccp (-2000,-2000);
			
			squareShape = cpPolyShapeNew(staticBody, 4, squared, cpv(0,0));
			squareShape->e = 1.0f; squareShape->u = 1.0f;
			squareShape->collision_type = 1;
			cpSpaceAddStaticShape(space, squareShape);	
			
		}
			break;
		default:
			break;
	}
	
	
}



// Touch handlers...
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if ( gamestate == coin_toflick || gamestate == coin_inplay)
	{
		//if ( !mouse) 
		mouse = cpMouseNew(space);
		
		if (current_ball_no > balls_per_round)
		{
			// not sure what to do here
		}
		else
		{
			UITouch *myTouch = [touches anyObject];
			CGPoint location = [myTouch locationInView: [myTouch view]];
			location = [[CCDirector sharedDirector] convertToGL: location];
			
			
			// only control in the firing area below 100
			if (location.y <= 115*2.13333333)
			{
				
				// ok we need to find position of the coin to flick
				float x = balls[current_ball_no] -> p.x;
				float y = balls[current_ball_no] -> p.y;
				
				if ( abs(x-location.x) < 35*2.133333 && abs(y-location.y) < 35*2.1333333 && y <= 115*2.13333333 )
				{
					cpMouseGrab(mouse, cpv(balls[current_ball_no]->p.x, balls[current_ball_no]->p.y), true);
					//move the nouse to the click
					cpMouseMove(mouse, cpv(location.x, location.y));
					if(mouse->body == nil){
						cpMouseGrab(mouse, cpv(location.x, location.y), true);
					}
				}
			}
		}
	}
	
}

- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
	if ( gamestate == coin_toflick || gamestate == coin_inplay)
	{	
		if ( mouse ){
			UITouch *myTouch = [touches anyObject];
			CGPoint location = [myTouch locationInView: [myTouch view]];
			location = [[CCDirector sharedDirector] convertToGL: location];
			if ( location.y <=115*2.13333333 )
			{
				//move the nouse to the click
				cpMouseMove(mouse, cpv(location.x, location.y));
				if(mouse->body == nil){
					cpMouseGrab(mouse, cpv(location.x, location.y), true);
				}
			}
			else
			{
				//[self ccTouchesEnded:touches withEvent:event];
			}
		}
	}
	
}	

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ( gamestate == coin_toflick || gamestate == coin_inplay)
	{	
		[self ccTouchesCancelled:touches withEvent:event];
	}
}
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if ( gamestate == coin_toflick || gamestate == coin_inplay)
	{	
		
		if (gamestate == coin_toflick)
		{
			//[[SimpleAudioEngine sharedEngine] playEffect:@"slide.wav"];
			
			gamestate = coin_inplay;
		}
		
		cpMouseFree(mouse);
	}
	else
	{
		cpMouseFree(mouse);
	}
	
}

// Save the game state...
// load up the saved game state so we can resume where we left off.

-(void) Save_Game_State;
{
	// Code here to save the game state if game is in progress...
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dataFile = [documentsDirectory stringByAppendingPathComponent:@"gameState"];
	
	NSString *board_type;
	
	if (board == 0) {
		board_type = @"M";
	}
	else if (board == 1) {
		board_type = @"S";
	}
	else {
		board_type = @"F";
	}
	dataFile = [dataFile stringByAppendingString: board_type];
	
	
	NSString *two_player_type;
	if (two_player) {
		two_player_type = @"Y.dat";
	}
	else {
		two_player_type = @"N.dat";
	}
	
	dataFile = [dataFile stringByAppendingString: two_player_type ];
		
	NSMutableData *datastream;
	NSKeyedArchiver *encoder;
	datastream = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:datastream]; 
	
	
	// Game Variables here...
	[encoder encodeInt:gamestate forKey:@"GameState"];
	[encoder encodeInt:current_ball_no forKey:@"Current_Ball_No"];
	for (int i=0; i<6; i++) {
		[encoder encodeInt:ball_stopped[i] forKey:[NSString stringWithFormat:@"Ball_Stopperd%d",i]];
		[encoder encodeBool:ball_in_bed[i] forKey:[NSString stringWithFormat:@"Ball_In_Bed%d",i]];
		
		if ( i > 0 ) // coins are 1 - 5
		{
			// encode the positions, velocities, force and angular position and velocity of all the balls.... eek.
			// Position
			[encoder encodeFloat:balls[i]->p.x forKey:[NSString stringWithFormat:@"Ballpx%d",i]];
			[encoder encodeFloat:balls[i]->p.y forKey:[NSString stringWithFormat:@"Ballpy%d",i]];
			// Velocity
			[encoder encodeFloat:balls[i]->v.x forKey:[NSString stringWithFormat:@"Ballvx%d",i]];
			[encoder encodeFloat:balls[i]->v.y forKey:[NSString stringWithFormat:@"Ballvy%d",i]];
			//Force
			[encoder encodeFloat:balls[i]->f.x forKey:[NSString stringWithFormat:@"Ballfx%d",i]];
			[encoder encodeFloat:balls[i]->f.y forKey:[NSString stringWithFormat:@"Ballfy%d",i]];
			
			// Angular components
			[encoder encodeFloat:balls[i]->a forKey:[NSString stringWithFormat:@"Angulara%d",i]];
			[encoder encodeFloat:balls[i]->w forKey:[NSString stringWithFormat:@"Angularw%d",i]];
			[encoder encodeFloat:balls[i]->t forKey:[NSString stringWithFormat:@"Angulart%d",i]];
			[encoder encodeFloat:balls[i]->rot.x forKey:[NSString stringWithFormat:@"Angularrotx%d",i]];
			[encoder encodeFloat:balls[i]->rot.y forKey:[NSString stringWithFormat:@"Angularroty%d",i]];
			
			// save the shape props.
			[encoder encodeFloat:balls_shapes[i]->u forKey:[NSString stringWithFormat:@"friction%d",i]];
			[encoder encodeFloat:balls_shapes[i]->e forKey:[NSString stringWithFormat:@"elasticity%d",i]];
		}
	}
	
	// bool switches here
	[encoder encodeBool:new_coin forKey:@"new_coin"];
	[encoder encodeBool:menu_shown forKey:@"menu_shown"];
	[encoder encodeBool:score_added forKey:@"score_added"];
	// Menu_shown always set to false...
	// game_over_balls_set always set to false...
	// score_changed always set to false;
	
	// scoreing variables
	[encoder encodeInt:current_score forKey:@"current_score"];
	[encoder encodeInt:score_this_round forKey:@"score_this_round"];
	[encoder encodeInt:total_pen forKey: @"total_pen"];
	
	for (int i=0; i<9; i++) {
		for (int j=0; j<5; j++) {
			[encoder encodeInt:player1_round_scores[i][j] forKey:[NSString stringWithFormat:@"Player_round_scored%d%d",i,j]];
		}
		[encoder encodeInt:player1_scores[i] forKey:[NSString stringWithFormat:@"Player_1_Score%d",i]];
		[encoder encodeInt:player2_scores[i] forKey:[NSString stringWithFormat:@"Player_2_Score%d",i]];
		[encoder encodeInt:player1_scores_temp[i] forKey:[NSString stringWithFormat:@"Player_1_Score_temp%d",i]];
		[encoder encodeInt:player2_scores_temp[i] forKey:[NSString stringWithFormat:@"Player_2_Score_temp%d",i]];
		// set labels to nil...
	}
	
	[encoder encodeInt:current_player forKey: @"current_player"];	
	[encoder finishEncoding ];
	[datastream writeToFile:dataFile atomically:TRUE];	
	[encoder release];	
}

-(void) Load_Game_State
{
	// Code here to save the game state if game is in progress...
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dataFile = [documentsDirectory stringByAppendingPathComponent:@"gameState"];
	
	NSString *board_type;
	
	if (board == 0) {
		board_type = @"M";
	}
	else if (board == 1) {
		board_type = @"S";
	}
	else {
		board_type = @"F";
	} 
	dataFile = [dataFile stringByAppendingString: board_type];
	
	
	NSString *two_player_type;
	if (two_player) {
		two_player_type = @"Y.dat";
	}
	else {
		two_player_type = @"N.dat";
	}
	
	dataFile = [dataFile stringByAppendingString: two_player_type ];
	
	NSData *DataStream;
	NSKeyedUnarchiver *decoder;
	//DataStream = [NSData data];
	
	DataStream = [NSData dataWithContentsOfFile:dataFile];
	
	if (DataStream) {
		// load it in...
		decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:DataStream];
		
		
		gamestate = [decoder decodeIntForKey:@"GameState"];
		current_ball_no = [decoder decodeIntForKey:@"Current_Ball_No"];
		for (int i=0; i<6; i++) {
			ball_stopped[i] = [decoder decodeIntForKey:[NSString stringWithFormat:@"Ball_Stopperd%d",i]];
			ball_in_bed[i] = [decoder decodeBoolForKey:[NSString stringWithFormat:@"Ball_In_Bed%d",i]];
			
			if ( i > 0 ) // coins are 1 - 5
			{
				// encode the positions, velocities, force and angular position and velocity of all the balls.... eek.
				// Position
				balls[i]->p.x = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Ballpx%d",i]];
				balls[i]->p.y = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Ballpy%d",i]];
				// Velocity
				balls[i]->v.x = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Ballvx%d",i]];
				balls[i]->v.y = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Ballvy%d",i]];
				//Force
				balls[i]->f.x = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Ballfx%d",i]];
				balls[i]->f.y = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Ballfy%d",i]];
				
				// Angular components
				balls[i]->a = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Angulara%d",i]];
				balls[i]->w = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Angularw%d",i]];
				balls[i]->t = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Angulart%d",i]];
				balls[i]->rot.x = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Angularrotx%d",i]];
				balls[i]->rot.y = [decoder decodeFloatForKey:[NSString stringWithFormat:@"Angularroty%d",i]];
				
				// save the shape props.
				balls_shapes[i]->u = [decoder decodeFloatForKey:[NSString stringWithFormat:@"friction%d",i]];
				balls_shapes[i]->e = [decoder decodeFloatForKey:[NSString stringWithFormat:@"elasticity%d",i]];
			}
		}
		
		// bool switches here
		new_coin = [decoder decodeBoolForKey:@"new_coin"];
		menu_shown = [decoder decodeBoolForKey:@"menu_shown"];
		score_added= [decoder decodeBoolForKey:@"score_added"];
		
		
		// game_over_balls_set always set to false...
		game_over_balls_set = false;
		// score_changed always set to false;
		score_changed = false;
		
		// scoreing variables
		current_score = [decoder decodeIntForKey:@"current_score"];
		score_this_round = [decoder decodeIntForKey:@"score_this_round"];
		total_pen = [decoder decodeIntForKey: @"total_pen"];
		
		if ( menu_shown )
		{
			menu_shown = false;
			if (score_added) {
				add_pen = FALSE;
			}
			// the penalty score will be re-added so mark a temp var so it dont get re-added
			//add_pen = FALSE;
			//score_this_round = 0;
		}
		
		for (int i=0; i<9; i++) {
			for (int j=0; j<5; j++) {
				player1_round_scores[i][j] = [decoder decodeIntForKey:[NSString stringWithFormat:@"Player_round_scored%d%d",i,j]];
				player1_round_scores[i][j] = 0;
			}
			player1_scores[i] = [decoder decodeIntForKey:[NSString stringWithFormat:@"Player_1_Score%d",i]];
			player2_scores[i] = [decoder decodeIntForKey:[NSString stringWithFormat:@"Player_2_Score%d",i]];
			player1_scores_temp[i] = [decoder decodeIntForKey:[NSString stringWithFormat:@"Player_1_Score_temp%d",i]];
			player2_scores_temp[i] = [decoder decodeIntForKey:[NSString stringWithFormat:@"Player_2_Score_temp%d",i]];
			// set labels to nil...
		}
		
		current_player = [decoder decodeIntForKey: @"current_player"];
		
		[decoder release];
		
		if ( two_player )
		{
			if (player_label) {
				[self removeChild:player_label cleanup:YES];
			}
			if ( current_player == 1 )
			{
				player_label = [CCLabel labelWithString:Player1 dimensions:CGSizeMake(720,50) alignment:UITextAlignmentLeft fontName:@"Chalkboard"	fontSize:42];
				if ( board == 0 || board == 2 )
					player_label.color = ccc3(0,0,0);
				[player_label setPosition:ccp(384,37)];
				[self addChild:player_label z:3];
			}
			else 
			{
				player_label = [CCLabel labelWithString:Player2 dimensions:CGSizeMake(720,50) alignment:UITextAlignmentRight fontName:@"Chalkboard"	fontSize:42];
				if ( board == 0 || board == 2 )
					player_label.color = ccc3(0,0,0);
				[player_label setPosition:ccp(384,37)];
				[self addChild:player_label z:3];
				
			}	
		}
		
		
    }
}

-(void) Delete_Game_State
{
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dataFile = [documentsDirectory stringByAppendingPathComponent:@"gameState"];
	
	NSString *board_type;
	
	if (board == 0) {
		board_type = @"M";
	}
	else if (board == 1) {
		board_type = @"S";
	}
	else {
		board_type = @"F";
	}
	dataFile = [dataFile stringByAppendingString: board_type];
	
	
	NSString *two_player_type;
	if (two_player) {
		two_player_type = @"Y.dat";
	}
	else {
		two_player_type = @"N.dat";
	}
	
	dataFile = [dataFile stringByAppendingString: two_player_type ];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:dataFile error:NULL];
	
}

-(void) display_scores
{
	
	CGSize wins = [[CCDirector sharedDirector] winSize];
	
	
	// Player 1 scores
	for ( int i=0; i<9; i++)
	{
		if (player_1_scores_lbl[i] )
		{
			[self removeChild:player_1_scores_lbl[i] cleanup:YES];
		}
		
		
		if( player1_scores[i] > 0 )
		{
			switch (player1_scores[i]) {
				case 1:
				{
					NSString *chalk = @"I";	
					player_1_scores_lbl[i] = [CCLabel labelWithString:chalk fontName:@"Marker Felt" fontSize:45]; 
					[self addChild:player_1_scores_lbl[i] z:3];
					[player_1_scores_lbl[i] setPosition: ccp(30, wins.height-733 + i*68)]; 
				}
					break;
				case 2:
				{
					NSString *chalk = @"II";	
					player_1_scores_lbl[i] = [CCLabel labelWithString:chalk fontName:@"Marker Felt" fontSize:45]; 
					[self addChild:player_1_scores_lbl[i] z:3];
					[player_1_scores_lbl[i] setPosition: ccp(30, wins.height-733 + i*68)]; 
					break;
				}
				case 3:
				{
					NSString *chalk = @"III";	
					player_1_scores_lbl[i] = [CCLabel labelWithString:chalk fontName:@"Marker Felt" fontSize:45]; 
					[self addChild:player_1_scores_lbl[i] z:3];
					[player_1_scores_lbl[i] setPosition: ccp(30, wins.height-733 + i*68)]; 
					break;
				}
				default:
					break;
			}
		}
		
	}
	
	// Player 2 scores
	for ( int i=0; i<9; i++)
	{
		if (player_2_scores_lbl[i] )
		{
			[self removeChild:player_2_scores_lbl[i] cleanup:YES];
		}
		
		
		if( player2_scores[i] > 0 )
		{
			switch (player2_scores[i]) {
				case 1:
				{
					NSString *chalk = @"I";	
					player_2_scores_lbl[i] = [CCLabel labelWithString:chalk fontName:@"Marker Felt" fontSize:45]; 
					[self addChild:player_2_scores_lbl[i] z:3];
					[player_2_scores_lbl[i] setPosition: ccp(wins.width-30, wins.height-733 + i*68)]; 
				}
					break;
				case 2:
				{
					NSString *chalk = @"II";	
					player_2_scores_lbl[i] = [CCLabel labelWithString:chalk fontName:@"Marker Felt" fontSize:45]; 
					[self addChild:player_2_scores_lbl[i] z:3];
					[player_2_scores_lbl[i] setPosition: ccp(wins.width-30, wins.height-733 + i*68)]; 
					break;
				}
				case 3:
				{
					NSString *chalk = @"III";	
					player_2_scores_lbl[i] = [CCLabel labelWithString:chalk fontName:@"Marker Felt" fontSize:45]; 
					[self addChild:player_2_scores_lbl[i] z:3];
					[player_2_scores_lbl[i] setPosition: ccp(wins.width-30, wins.height-733 + i*68)]; 
					break;
				}
				default:
					break;
			}
		}
		
	}
	
	
}

-(void) dealloc
{
	game_in_progress = FALSE;
	if ( gamestate != game_over && gamestate != game_over_two_player )		
		[self Save_Game_State];
	
	// dealloc chipmunk stuff
	[self unschedule: @selector(step:)]; 
	
	cpSpaceFreeChildren(space);
	cpSpaceFree(space);
	
	[super dealloc];
}

// Debug cheat buttons
-(void) addCheatButtons
{
	[CCMenuItemFont setFontSize:30];
	[CCMenuItemFont setFontName: @"Chalkboard"];
	
	CCMenuItemFont *bed1 =  [CCMenuItemFont itemFromString: @"C" target:self selector:@selector(Tap1:)];
	
	if ( board != 1 )
		bed1.color = ccc3(0,0,0);
	
	//[thefont setPosition:ccp(0,0)];
    CCMenu *menu1 = [CCMenu menuWithItems: bed1, nil];
    menu1.opacity = 200;
	[menu1 setPosition:ccp(80,290)];
	[self addChild:menu1 z:3];
	
	
	CCMenuItemFont *bed2 =  [CCMenuItemFont itemFromString: @"C" target:self selector:@selector(Tap2:)];
	
	if ( board != 1 )
		bed2.color = ccc3(0,0,0);
	
	//[thefont setPosition:ccp(0,0)];
    CCMenu *menu2 = [CCMenu menuWithItems: bed2, nil];
	menu2.opacity = 200;
	[menu2 setPosition:ccp(80,360)];
	[self addChild:menu2 z:3];
	
	
	CCMenuItemFont *bed3 =  [CCMenuItemFont itemFromString: @"C" target:self selector:@selector(Tap3:)];
	
	if ( board != 1 )
		bed3.color = ccc3(0,0,0);
	
	//[thefont setPosition:ccp(0,0)];
    CCMenu *menu3 = [CCMenu menuWithItems: bed3, nil];
    menu3.opacity = 200;
	[menu3 setPosition:ccp(80,426)];
	[self addChild:menu3 z:3];
	
	
	CCMenuItemFont *bed4=  [CCMenuItemFont itemFromString: @"C" target:self selector:@selector(Tap4:)];
	
	if ( board != 1 )
		bed4.color = ccc3(0,0,0);
	
	//[thefont setPosition:ccp(0,0)];
    CCMenu *menu4 = [CCMenu menuWithItems: bed4, nil];
    menu4.opacity = 200;
	[menu4 setPosition:ccp(80,490)];
	[self addChild:menu4 z:3];
	
	
	CCMenuItemFont *bed5 =  [CCMenuItemFont itemFromString: @"C" target:self selector:@selector(Tap5:)];
	
	if ( board != 1 )
		bed5.color = ccc3(0,0,0);
	
	//[thefont setPosition:ccp(0,0)];
    CCMenu *menu5 = [CCMenu menuWithItems: bed5, nil];
    menu5.opacity = 200;
	[menu5 setPosition:ccp(80,562)];
	[self addChild:menu5 z:3];
	
	
	CCMenuItemFont *bed6 =  [CCMenuItemFont itemFromString: @"C" target:self selector:@selector(Tap6:)];
	
	if ( board != 1 )
		bed6.color = ccc3(0,0,0);
	
	//[thefont setPosition:ccp(0,0)];
    CCMenu *menu6 = [CCMenu menuWithItems: bed6, nil];
    menu6.opacity = 200;
	[menu6 setPosition:ccp(80,630)];
	[self addChild:menu6 z:3];
	
	
	CCMenuItemFont *bed7 =  [CCMenuItemFont itemFromString: @"C" target:self selector:@selector(Tap7:)];
	
	if ( board != 1 )
		bed7.color = ccc3(0,0,0);
	
	//[thefont setPosition:ccp(0,0)];
    CCMenu *menu7 = [CCMenu menuWithItems: bed7, nil];
    menu7.opacity = 200;
	[menu7 setPosition:ccp(80,702)];
	[self addChild:menu7 z:3];
	
	
	CCMenuItemFont *bed8 =  [CCMenuItemFont itemFromString: @"C" target:self selector:@selector(Tap8:)];
	
	if ( board != 1 )
		bed8.color = ccc3(0,0,0);
	
	//[thefont setPosition:ccp(0,0)];
    CCMenu *menu8 = [CCMenu menuWithItems: bed8, nil];
    menu8.opacity = 200;
	[menu8 setPosition:ccp(80,770)];
	[self addChild:menu8 z:3];
	
	
	CCMenuItemFont *bed9 =  [CCMenuItemFont itemFromString: @"C" target:self selector:@selector(Tap9:)];
	
	if ( board != 1 )
		bed9.color = ccc3(0,0,0);
	
	//[thefont setPosition:ccp(0,0)];
    CCMenu *menu9 = [CCMenu menuWithItems: bed9, nil];
    menu9.opacity = 200;
	[menu9 setPosition:ccp(80,835)];
	[self addChild:menu9 z:3];
	
	
	
}

// new ba;;
-(void) Tap1:(id) sender
{
	if (gamestate == coin_inplay) {
		balls[current_ball_no]->v.x = 0;
		balls[current_ball_no]->v.y = 0;
        balls[current_ball_no]->p.y = 290;
		
	}
	
}

-(void) Tap2:(id) sender
{
	if (gamestate == coin_inplay) {
		balls[current_ball_no]->v.x = 0;
		balls[current_ball_no]->v.y = 0;
        balls[current_ball_no]->p.y = 360;
		
	}
	
}
-(void) Tap3:(id) sender
{
	if (gamestate == coin_inplay) {
		balls[current_ball_no]->v.x = 0;
		balls[current_ball_no]->v.y = 0;
        balls[current_ball_no]->p.y = 426;
		
	}
	
}
-(void) Tap4:(id) sender
{
	if (gamestate == coin_inplay) {
		balls[current_ball_no]->v.x = 0;
		balls[current_ball_no]->v.y = 0;
        balls[current_ball_no]->p.y = 495;
		
	}
	
}
-(void) Tap5:(id) sender
{
	if (gamestate == coin_inplay) {
		balls[current_ball_no]->v.x = 0;
		balls[current_ball_no]->v.y = 0;
        balls[current_ball_no]->p.y = 560;
		
	}
	
}

-(void) Tap6:(id) sender
{
	if (gamestate == coin_inplay) {
		balls[current_ball_no]->v.x = 0;
		balls[current_ball_no]->v.y = 0;
        balls[current_ball_no]->p.y = 630;
		
	}
	
}

-(void) Tap7:(id) sender
{
	if (gamestate == coin_inplay) {
		balls[current_ball_no]->v.x = 0;
		balls[current_ball_no]->v.y = 0;
        balls[current_ball_no]->p.y = 700;
		
	}
	
}

-(void) Tap8:(id) sender
{
	if (gamestate == coin_inplay) {
		balls[current_ball_no]->v.x = 0;
		balls[current_ball_no]->v.y = 0;
        balls[current_ball_no]->p.y = 770;
		
	}
	
}

-(void) Tap9:(id) sender
{
	if (gamestate == coin_inplay) {
		balls[current_ball_no]->v.x = 0;
		balls[current_ball_no]->v.y = 0;
        balls[current_ball_no]->p.y = 836;
		
	}
	
}


@end
