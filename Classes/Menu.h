#import "cocos2d.h"
#import "chipmunk.h"
#import "Global.h"
#import "PlayHaven.h"



@class CCMenu;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow *window;
}
@end





@interface ConfigLayer : CCLayer  < UITextFieldDelegate >
{
	CCSprite *bg;
	CCMenu *menu;
	UITextField *myTextField;
}
-(void) addMenu;
-(void) menuCallback: (id) sender;
-(void) backCallback: (id) sender;
@end




@interface AboutLayer : CCLayer <PHRequestDelegate>  // implement the Playhaven delegate
{
	
}
-(void) menuCallback: (id) sender;
@end

@interface HistoryLayer : CCLayer
{
	
}
-(void) menuCallback: (id) sender;
@end

@interface HowToPlayLayer : CCLayer
{
	
}
-(void) menuCallback: (id) sender;
@end



