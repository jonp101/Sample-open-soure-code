//
// Menu Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//


#import "Menu.h"
#import "GameLayers.h"
#import "GameSingleton.h"




enum {
	kTagMenu = 1,
	kTagMenu0 = 0,
	kTagMenu1 = 1,
};



#pragma mark -
#pragma mark MainMenu
@implementation MainMenu
-(id) init
{
	if( (self=[super init])) {
		if (!autostart) {
			
			
			// Standard method to create a button
			CCMenuItem *starMenuItem = [CCMenuItemImage 
										itemFromNormalImage:@"play_down.png" selectedImage:@"play_up.png" 
										target:self selector:@selector(menuCallbackPlayer1:)];
			starMenuItem.position = ccp(593, 440);
			CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
			starMenu.position = CGPointZero;
			starMenu.opacity = 170;
			[self addChild:starMenu z:1];
			
			// Standard method to create a button
			CCMenuItem *opMenuItem = [CCMenuItemImage 
									  itemFromNormalImage:@"options_down.png" selectedImage:@"options_up.png" 
									  target:self selector:@selector(menuCallbackConfig:)];
			opMenuItem.position = ccp(593, 340);
			CCMenu *opstarMenu = [CCMenu menuWithItems:opMenuItem, nil];
			opstarMenu.position = CGPointZero;
			opstarMenu.opacity = 170;
			[self addChild:opstarMenu z:1];
			
			// Standard method to create a button
			CCMenuItem *hoMenuItem = [CCMenuItemImage 
									  itemFromNormalImage:@"howto_down.png" selectedImage:@"howto_up.png" 
									  target:self selector:@selector(menuCallbackHowToPlay:)];
			hoMenuItem.position = ccp(593, 240);
			CCMenu *hostarMenu = [CCMenu menuWithItems:hoMenuItem, nil];
			hostarMenu.position = CGPointZero;
			hostarMenu.opacity = 170;
			[self addChild:hostarMenu z:1];
			
			
			// Standard method to create a button
			CCMenuItem *hiMenuItem = [CCMenuItemImage 
									  itemFromNormalImage:@"history_down.png" selectedImage:@"history_up.png" 
									  target:self selector:@selector(menuCallbackHistory:)];
			hiMenuItem.position = ccp(593, 140);
			CCMenu *histarMenu = [CCMenu menuWithItems:hiMenuItem, nil];
			histarMenu.position = CGPointZero;
			histarMenu.opacity = 170;
			[self addChild:histarMenu z:1];
			
			// Standard method to create a button
			CCMenuItem *abMenuItem = [CCMenuItemImage 
									  itemFromNormalImage:@"about_down.png" selectedImage:@"about_up.png" 
									  target:self selector:@selector(menuCallbackAbout:)];
			abMenuItem.position = ccp(593, 40);
			CCMenu *abstarMenu = [CCMenu menuWithItems:abMenuItem, nil];
			abstarMenu.position = CGPointZero;
			abstarMenu.opacity = 170;
			[self addChild:abstarMenu z:1];
		}
		
		
		if (autostart) {
			
			// Draw in Background // dependend on selected board..
			if ( board == 0 )
			{
				CCSprite *bg = [CCSprite spriteWithFile:@"board mahogany.png"];
				CGPoint point = CGPointMake(384,512);
				//bg.opacity = 100;
				[bg setPosition:point];
				[self addChild:bg z:0];
			}
			if ( board == 1 )
			{
				CCSprite *bg = [CCSprite spriteWithFile:@"board slate.png"];
				CGPoint point = CGPointMake(384,512);
				//bg.opacity = 100;
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
			
			
		}
		else{
			CCSprite *bg = [CCSprite spriteWithFile:@"menu.png"];
			//bg.opacity = 123;
			CGPoint point = CGPointMake(384,512);
			[bg setPosition:point];
			[self addChild:bg z:0];
			
		}
		[self schedule: @selector(step)];
	}
	

	return self;
}

-(void) step
{
	if (autostart) {
		autostart = false;
		gs = [CCScene node];
		[gs addChild:[Game node] z:0];
		[[CCDirector sharedDirector] replaceScene: gs ];
		
	}
}


-(void) dealloc
{
	[disabledItem release];
	[super dealloc];
}

-(void) menuCallbackPlayer1: (id) sender
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
	
	NSData *DataStream;
		
	
	DataStream = [NSData dataWithContentsOfFile:dataFile];
	
	if (DataStream) {
		// open a alert with an OK and cancel button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Resume Game?" delegate:self cancelButtonTitle:@"New Game" otherButtonTitles:@"Resume", nil];
		[alert show];
		[alert release];
	}
	else {
		gs = [CCScene node];
		[gs addChild:[Game node] z:0];
		[[CCDirector sharedDirector] replaceScene: [CCFlipXTransition transitionWithDuration:1.0f scene:gs ]];
		
	}
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		// delete datafile...
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
	
	gs = [CCScene node];
	[gs addChild:[Game node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipXTransition transitionWithDuration:1.0f scene:gs ]];
	
}



-(void) menuCallbackConfig:(id) sender
{
	cs = [CCScene node];
	[cs addChild:[ConfigLayer node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipXTransition transitionWithDuration:1.0f scene:cs ]];
}

-(void) menuCallbackHistory:(id) sender
{
	hs = [CCScene node];
	[hs addChild:[HistoryLayer node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipYTransition transitionWithDuration:1.0f scene:hs ]];
}

-(void) menuCallbackAbout:(id) sender
{
	as = [CCScene node];
	[as addChild:[AboutLayer node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipYTransition transitionWithDuration:1.0f scene:as ]];
}

-(void) menuCallbackHowToPlay:(id) sender
{
	hp = [CCScene node];
	[hp addChild:[HowToPlayLayer node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipYTransition transitionWithDuration:1.0f scene:hp ]];
}

-(void) menuCallbackDisabled:(id) sender {
}

-(void) menuCallbackEnable:(id) sender {
	disabledItem.isEnabled = ~disabledItem.isEnabled;
}

-(void) menuCallback2: (id) sender
{
	[(CCMultiplexLayer*)parent_ switchTo:1];
}

-(void) onQuit: (id) sender
{
	[[CCDirector sharedDirector] end];
}

@end


@implementation ConfigLayer


-(void) addMenu{
	// Player 1
	[CCMenuItemFont setFontName: @"Chalkboard"];
	[CCMenuItemFont setFontSize:38];
	CCMenuItemFont *title_pl1 = [CCMenuItemFont itemFromString: @"Player 1"];
    [title_pl1 setIsEnabled:NO];
	
	
	
	//CCLabelAtlas *labelAtlas = [CCLabelAtlas labelAtlasWithString:@"Jonner" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
    CCLabel *labelAtlas= [CCLabel labelWithString:Player1 fontName:@"Chalkboard" fontSize:42];
	CCMenuItemLabel *player_1 = [CCMenuItemLabel itemWithLabel:labelAtlas target:self selector:@selector(menuCallbackPL1:)];
	
	
	// Player 2
	[CCMenuItemFont setFontName: @"Chalkboard"];
	[CCMenuItemFont setFontSize:38];
	CCMenuItemFont *title_pl2 = [CCMenuItemFont itemFromString: @"Player 2"];
    [title_pl2 setIsEnabled:NO];
	
	
	
	//CCLabelAtlas *labelAtlas_2 = [CCLabelAtlas labelAtlasWithString:@"Mark" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
	CCLabel *labelAtlas_2 = [CCLabel labelWithString:Player2 fontName:@"Chalkboard" fontSize:42];	
	
	CCMenuItemLabel *player_2 = [CCMenuItemLabel itemWithLabel:labelAtlas_2 target:self selector:@selector(menuCallbackPL2:)];
	
	
	
	[CCMenuItemFont setFontName: @"Chalkboard"];
	[CCMenuItemFont setFontSize:38];
	CCMenuItemFont *title_md = [CCMenuItemFont itemFromString: @"Game Mode"];
    [title_md setIsEnabled:NO];
	[CCMenuItemFont setFontName: @"Chalkboard"];
	[CCMenuItemFont setFontSize:42];
    CCMenuItemToggle *item_md = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallbackMD:) items:
								 [CCMenuItemFont itemFromString: @"Practice"],
								 [CCMenuItemFont itemFromString: @"2 Player"],
								 nil];
    
	if ( two_player )
	{
		item_md.selectedIndex = 1;
	}
	else
	{
		item_md.selectedIndex = 0;
	}
	
	
	[CCMenuItemFont setFontName: @"Chalkboard"];
	[CCMenuItemFont setFontSize:38];
	CCMenuItemFont *title1 = [CCMenuItemFont itemFromString: @"Sound"];
    [title1 setIsEnabled:NO];
	[CCMenuItemFont setFontName: @"Chalkboard"];
	[CCMenuItemFont setFontSize:42];
    CCMenuItemToggle *item1 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallbackSD:) items:
							   [CCMenuItemFont itemFromString: @"On"],
							   [CCMenuItemFont itemFromString: @"Off"],
							   nil];
    
	if (sound_on) {
		item1.selectedIndex = 0;
	}
	else {
		item1.selectedIndex = 1;
	}

	
    
	
	[CCMenuItemFont setFontName: @"Chalkboard"];
	[CCMenuItemFont setFontSize:38];
	CCMenuItemFont *title4 = [CCMenuItemFont itemFromString: @"Choose Board"];
    [title4 setIsEnabled:NO];
	
	[CCMenuItemFont setFontName: @"Chalkboard"];
	[CCMenuItemFont setFontSize:42];
    CCMenuItemToggle *item4 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
							   [CCMenuItemFont itemFromString: @"Mahogany"],
							   [CCMenuItemFont itemFromString: @"Slate"],
							   [CCMenuItemFont itemFromString: @"Funky"],
							   
							   nil];
	
	
	
    // you can change the one of the items by doing this
    item4.selectedIndex = board;
    
	
	menu = [CCMenu menuWithItems:
					title_pl1,player_1,
					title_pl2,player_2,
					title_md,item_md,
					title1, item1,
					title4, item4, nil]; // 9 items.
    [menu  alignItemsVertically];
    
	
	
	[self addChild: menu z:1];
	
	
}

-(id) init
{
	[super init];
	
	[self addMenu ];
		
	// back to menu
	
	[CCMenuItemFont setFontSize:50];
	[CCMenuItemFont setFontName: @"Chalkboard"];
	 CCMenuItem *item1 = [CCMenuItemFont itemFromString: @"Play" target: self selector:@selector(backCallback:)];
	
	
	CCMenu *menu1 = [CCMenu menuWithItems: item1, nil];
	//[menu alignItemsVertically];
	[menu1 setPosition:ccp(384,55)];
	
	[self addChild: menu1 z:1];	
	
	
	
	// add a background
	
	//
	bg = [CCSprite spriteWithFile:@"options_screen.png"];
	CGPoint point = CGPointMake(384,512);
	[bg setPosition:point];
	[self addChild:bg z:0];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) menuPlay: (id) sender
{
	gs = [CCScene node];
	[gs addChild:[Game node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipXTransition transitionWithDuration:1.0f scene:gs ]];
}

-(void) menuCallbackPL1: (id) sender
{
	
	UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"Enter Player 1 Name"
													 message:@"Enter name for Player 1"
													delegate:self cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK", nil];
	myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
	myTextField.keyboardType = UIKeyboardTypeASCIICapable;
	myTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
	
	
	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 130);
	[alert setTransform:myTransform];
	[myTextField setBackgroundColor:[UIColor whiteColor]];
	[myTextField setDelegate:self];
	[alert addSubview:myTextField];
	
	//myTextField.max = 3;
	
	alert.tag = 1;
	[alert show];
	[alert release];
	[myTextField release];
	
}

// delegate to handle textfield entry
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 10 && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {return YES;}
}



// delegate to handle button press.....
	
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
		NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
		
		if (buttonIndex == 0 && alert.tag == 1) {
			// cancel do nothing...
		}
		else if(buttonIndex == 0 && alert.tag == 2) {
		  //cancel do nothing
		}
		
		else if(buttonIndex==1 && alert.tag == 1) {
			// Ok button was pressed so replace Player 1 Name then reload menu..
			//Player1 = @"test";
			if(myTextField.text != nil && myTextField.text != @"")
			{
				Player1 = [myTextField.text copy];
				[userPreferences setObject:Player1 forKey:@"Player1"];
				
			}
			
			if ( menu )
			{
				[self removeChild:menu cleanup:YES];
				[self addMenu ];
			}
			
		}
		else if(buttonIndex==1 && alert.tag == 2) {
			// Ok button was pressed so replace Player 2 Name
			if(myTextField.text != nil && myTextField.text != @"")
			{
				Player2 = [myTextField.text copy];
				[userPreferences setObject:Player2 forKey:@"Player2"];
				
			}
			
			if ( menu )
			{
				[self removeChild:menu cleanup:YES];
				[self addMenu ];
			}
			
		}
		else {
			// the user clicked one of the OK/Cancel buttons
			if (buttonIndex == 0)
			{
				// delete datafile...
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
			
			gs = [CCScene node];
			[gs addChild:[Game node] z:0];
			[[CCDirector sharedDirector] replaceScene: [CCFlipXTransition transitionWithDuration:1.0f scene:gs ]];
			
		}
		
	}

-(void) menuCallbackPL2: (id) sender
{
	
	UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"Enter Player 2 Name"
													 message:@"Enter name for Player 2"
													delegate:self cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK", nil];
	myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
	myTextField.keyboardType = UIKeyboardTypeASCIICapable;
	myTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
	
	
	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 130);
	[alert setTransform:myTransform];
	[myTextField setBackgroundColor:[UIColor whiteColor]];
	[myTextField setDelegate:self];
	[alert addSubview:myTextField];
	
	//myTextField.max = 3;
	
	alert.tag = 2;
	[alert show];
	[alert release];
	[myTextField release];
}

-(void) menuCallbackMD: (id) sender
{  
	NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];	
		
	if ([sender selectedIndex] == 1) {
		two_player = true;
		[userPreferences setObject:@"Y" forKey:@"TwoPlayer"];
	}
	else {
		two_player = FALSE;
		[userPreferences setObject:@"N" forKey:@"TwoPlayer"];
	}

}

-(void) menuCallbackSD: (id) sender
{  
	NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];	
	
	if ([sender selectedIndex] == 0) {
		sound_on = true;
		[userPreferences setObject:@"Y" forKey:@"SoundOnOff"];
	}
	else {
		sound_on = FALSE;
		[userPreferences setObject:@"N" forKey:@"SoundOnOff"];
	}
}


-(void) menuCallback: (id) sender
{
	NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];	
	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
	board = [sender selectedIndex];
	
	if (board == 0){
		[userPreferences setObject:@"M" forKey:@"Board"];
	}
	else if (board == 1 )
	{
		[userPreferences setObject:@"S" forKey:@"Board"];
	}
	else {
		[userPreferences setObject:@"F" forKey:@"Board"];
	}

	
}


-(void) backCallback: (id) sender
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
	
	NSData *DataStream;
	
	
	DataStream = [NSData dataWithContentsOfFile:dataFile];
	
	if (DataStream) {
		// open a alert with an OK and cancel button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Resume Game?" delegate:self cancelButtonTitle:@"New Game" otherButtonTitles:@"Resume", nil];
		[alert show];
		[alert release];
	}
	else {
		gs = [CCScene node];
		[gs addChild:[Game node] z:0];
		[[CCDirector sharedDirector] replaceScene: [CCFlipXTransition transitionWithDuration:1.0f scene:gs ]];
		
	}
}

@end

@implementation SplashLayer

-(id) init
{
	self = [super init];
	
	if( self != nil)
	{
		CCSprite *titlesprite = [CCSprite spriteWithFile:@"Options.png"];
		[self addChild:titlesprite z:0];
		[titlesprite setPosition:CGPointMake(384,512)];
		splashTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(splashTimerCallback) userInfo:nil repeats:NO];

	}
	return self;
}
	
-(void) splashTimerCallback
{
	theScene = [CCScene node];
	[theScene addChild:[MainMenu node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipXTransition transitionWithDuration:1.0f scene:theScene ]];

}


@end


@implementation AboutLayer

-(id) init
{
	self = [super init];
	
	if( (self=[super init])) {
		CCSprite *titlesprite = [CCSprite spriteWithFile:@"credits.png"];
		[self addChild:titlesprite z:0];
		[titlesprite setPosition:CGPointMake(384,512)];
	}
	
	// back to menu
	[CCMenuItemFont setFontSize:50];
	[CCMenuItemFont setFontName: @"Chalkboard"];
	//CCMenuItem *item4 = [CCMenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallbackEnable:)];
	CCMenuItem *item1 = [CCMenuItemFont itemFromString: @"Back" target: self selector:@selector(menuCallback:)];
	
	// Playhaven
	
	CCMenuItem *item2 = [CCMenuItemImage 
								itemFromNormalImage:@"playhaven.png" selectedImage:@"playhaven.png" 
								target:self selector:@selector(menuCallbackG:)];
	item2.position = ccp(540, 240);
		
	CCMenu *menu = [CCMenu menuWithItems: item1, nil];
	//[menu alignItemsVertically];
	[menu setPosition:ccp(384,50)];
	
	CCMenu *menu2 = [CCMenu menuWithItems: item2, nil];
	//[menu alignItemsVertically];
	[menu2 setPosition:CGPointZero];
	
	
	
	
	
	[self addChild: menu];
	[self addChild: menu2];
	
	return self;


}



-(void) menuCallback: (id) sender
{
	theScene = [CCScene node];
	[theScene addChild:[MainMenu node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipYTransition transitionWithDuration:1.0f scene:theScene ]];
}

-(void) menuCallbackG: (id) sender
{
	[PlayHaven loadChartsWithDelegate:self context:nil];
	//theScene = [CCScene node];
	//[theScene addChild:[MainMenu node] z:0];
	//[[CCDirector sharedDirector] replaceScene: [CCFlipYTransition transitionWithDuration:1.0f scene:theScene ]];
}



// playhaven delegate methods

-(void)playhaven:(UIView *)view didLoadWithContext:(id)contextValue {
	[[[CCDirector sharedDirector] openGLView] addSubview:view];
}

-(void)playhaven:(UIView *)view didFailWithError:(NSString *)message context:(id)contextValue {
	//NSLog(@"playhaven didFailWithError: %@", message);
	[view removeFromSuperview];
}

-(void)playhaven:(UIView *)view wasDismissedWithContext:(id)contextValue {
	[view removeFromSuperview];
}


@end

@implementation HistoryLayer

-(id) init
{
	self = [super init];
	
	if( (self=[super init])) {
		CCSprite *titlesprite = [CCSprite spriteWithFile:@"scoreboard-1.png"];
		[self addChild:titlesprite z:0];
		[titlesprite setPosition:CGPointMake(384,512)];
	}
	
	
	CCLabel* title = [CCLabel labelWithString:[NSString stringWithFormat:@"Score history for %@", Player1] fontName:@"Chalkboard" fontSize:50];
	[title setPosition:ccp(384,970)];
	[self addChild:title];
	
	
	
	// load high score table from nsdefaults...
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
	
	
	
	int ystart = 780;
	for (int i=0; i <= ii; i++) {
		
		CCLabel *test = [CCLabel labelWithString:structArray[i].the_date fontName:@"Chalkboard" fontSize:42];
		[test setPosition:ccp(160,ystart)];
		[self addChild:test];
		CCLabel *score_lbl = [CCLabel labelWithString:[NSString stringWithFormat:@"%d",structArray[i].PenaltyScore] dimensions:CGSizeMake(300,50) alignment:UITextAlignmentRight fontName:@"Chalkboard" fontSize:42]; 
		[score_lbl setPosition:ccp(400,ystart)];
		[self addChild:score_lbl];
		
		ystart -= 66;
	}
	
	
	
	// back to menu
	[CCMenuItemFont setFontSize:50];
	[CCMenuItemFont setFontName: @"Chalkboard"];
	//CCMenuItem *item4 = [CCMenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallbackEnable:)];
	CCMenuItem *item1 = [CCMenuItemFont itemFromString: @"Back" target: self selector:@selector(menuCallback:)];
	
	
	CCMenu *menu = [CCMenu menuWithItems: item1, nil];
	//[menu alignItemsVertically];
	[menu setPosition:ccp(384,50)];
		
	[self addChild: menu];
	
	return self;
}

-(void) menuCallback: (id) sender
{
	theScene = [CCScene node];
	[theScene addChild:[MainMenu node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipYTransition transitionWithDuration:1.0f scene:theScene ]];
}


@end

@implementation HowToPlayLayer

-(id) init
{
	self = [super init];
	
	if( (self=[super init])) {
		CCSprite *titlesprite = [CCSprite spriteWithFile:@"how_to_play.png"];
		[self addChild:titlesprite z:0];
		[titlesprite setPosition:CGPointMake(384,512)];
	}
	
	// back to menu
	[CCMenuItemFont setFontSize:50];
	[CCMenuItemFont setFontName: @"Chalkboard"];
	//CCMenuItem *item4 = [CCMenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallbackEnable:)];
	CCMenuItem *item1 = [CCMenuItemFont itemFromString: @"Back" target: self selector:@selector(menuCallback:)];
	
	
	CCMenu *menu = [CCMenu menuWithItems: item1, nil];
	//[menu alignItemsVertically];
	[menu setPosition:ccp(384,50)];
	
	[self addChild: menu];
	
	return self;
	
}

-(void) menuCallback: (id) sender
{
	theScene = [CCScene node];
	[theScene addChild:[MainMenu node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCFlipYTransition transitionWithDuration:1.0f scene:theScene ]];
}

@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	[PlayHaven preloadWithPublisherToken:@"E1t8vC7JUoLYXr-jm2lEWQ" testing:NO];
	
	// set globals... need way to retrieve from file
	board = 0;
	Player1 = @"Player1";
	Player2 = @"Player2";
	two_player = true;
	sound_on = true;
	game_in_progress = FALSE;
	autostart = false;
	// initialize sound engine
	//[[SimpleAudioEngine sharedEngine] init ];
	
	
	
	// get user preferences.
	NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
	
    if ([userPreferences stringForKey:  @"SoundOnOff"] != nil) {
	  NSString *comp = [userPreferences stringForKey:  @"SoundOnOff"];
	  if ([comp isEqualToString:@"Y"]) {
		  sound_on = true;
	  }
	  else {
		  sound_on = false;
	  }
	}
	
	
    if ([userPreferences stringForKey:  @"TwoPlayer"] != nil) {
		NSString *comp = [userPreferences stringForKey:  @"TwoPlayer"];
		if ([comp isEqualToString:@"Y"]) {
			two_player = true;
		}
		else {
			two_player = false;
		}
	}
	
	if ([userPreferences stringForKey:  @"Board"] != nil) {
		NSString *comp = [userPreferences stringForKey:  @"Board"];
		if ([comp isEqualToString:@"M"]) {
			board = 0;
		}
		else if ([comp isEqualToString:@"S"]) {
			board = 1;
		}
		else {
			board = 2;
		}
	}
	
	if ([userPreferences stringForKey:  @"Player1"] != nil) {
		Player1 = [userPreferences stringForKey:@"Player1"];
	}
	
	if ([userPreferences stringForKey:  @"Player2"] != nil) {
		Player2 = [userPreferences stringForKey:@"Player2"];
	}

	// Tell the UIDevice to send notifications when the orientation changes
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	
	
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeMainLoop];
	
	// before creating any layer, set the landscape mode
	//[[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationPortraitUpsideDown];

	// show FPS
	[[CCDirector sharedDirector] setDisplayFPS:NO];

	// multiple touches or not ?
//	[[Director sharedDirector] setMultipleTouchEnabled:YES];
	
	// frames per second
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];	

	// attach cocos2d to a window
	[[CCDirector sharedDirector] attachInView:window];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];	

	theScene = [CCScene node];

	// Game always starts with the splash screen
	[theScene addChild:[SplashLayer node] z:0];
	
	//[theScene addChild:[MainMenu node] z:0];
	
	//CCMultiplexLayer *layer = [CCMultiplexLayer layerWithLayers: [MainMenu node], [ConfigLayer node], [Game node], nil];
	//[scene addChild: layer z:0];

	[window makeKeyAndVisible];
	[[CCDirector sharedDirector] runWithScene: theScene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) applicationWillTerminate:(UIApplication*)application
{
	// need to end sound engine else memory leak detected
	//[SimpleAudioEngine end];
	[[CCDirector sharedDirector] end ]; 					  
	
}

- (void) dealloc
{
	[window dealloc];
	[super dealloc];
}

// tell the director that the orientation has changed
-(void) orientationChanged:(NSNotification *)notification
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
	{
		[[CCDirector sharedDirector] setDeviceOrientation:(ccDeviceOrientation)orientation];
		[[UIApplication sharedApplication] setStatusBarOrientation:(ccDeviceOrientation)orientation animated: YES ];
	}
}

@end
