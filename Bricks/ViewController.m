//
//  ViewController.m
//  Bricks
//
//  Created by ABS on 24/12/14.
//  Copyright (c) 2014 ABS. All rights reserved.
//

#import "ViewController.h"
#import "BricksClass.h"
#import "BallClass.h"
#import "PaddleClass.h"



@interface ViewController ()<UICollisionBehaviorDelegate,UIAlertViewDelegate>
{

    BOOL Play;

}

@property (strong,nonatomic) UIDynamicAnimator *animator;
@property (strong,nonatomic) BallClass *MainBall;
@property (strong,nonatomic) PaddleClass *MainPaddle;
@property (strong,nonatomic) NSMutableArray *BricksArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self DrawBallAndPaddle];
    
    [self DrawBricksPattern];
    
    
    
}

-(void)DrawBallAndPaddle
{
    
    
    if (_MainPaddle) {
        [_MainPaddle removeFromSuperview];
    }
    
    if (_MainBall) {
        [_MainBall removeFromSuperview];
    }

    _MainPaddle = [[PaddleClass alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75,self.view.frame.size.height - 35.0,150.0,30.0)];
    
    [_MainPaddle setBackgroundColor:[UIColor orangeColor]];
    
    [_MainPaddle.layer setCornerRadius:5];
    
    
    [self.view addSubview:_MainPaddle];
    
    [_MainPaddle.layer setShadowOffset:CGSizeMake(-1, 2)];
    
    [_MainPaddle.layer setShadowOpacity:0.5];
    
    [_MainPaddle.layer setShadowRadius:5.0];
    
    [_MainPaddle.layer setShadowColor:[UIColor blackColor].CGColor];
    
    [_MainPaddle.layer setMasksToBounds:NO];
    
    [_MainPaddle.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:_MainPaddle.bounds cornerRadius:5].CGPath];
    
    
    
    
    _MainBall = [[BallClass alloc] initWithFrame:CGRectMake(_MainPaddle.center.x-15, _MainPaddle.center.y-45, 30, 30)];
    
    [_MainBall setBackgroundColor:[UIColor redColor]];
    
    
    [_MainBall.layer setCornerRadius:15];
    
    
    [self.view addSubview:_MainBall];
    
    [_MainBall.layer setShadowOffset:CGSizeMake(-1, 2)];
    
    [_MainBall.layer setShadowOpacity:0.5];
    
    [_MainBall.layer setShadowRadius:5.0];
    
    [_MainBall.layer setShadowColor:[UIColor blackColor].CGColor];
    
    [_MainBall.layer setMasksToBounds:NO];
    
    [_MainBall.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:_MainBall.bounds cornerRadius:15].CGPath];


}

-(void)DrawBricksPattern
{

    _BricksArray =[[NSMutableArray alloc] init];
    
    float x= 10;
    
    float y= 74;
    
    CGSize ScreenSize = [[UIScreen mainScreen] bounds].size;
    
    
    for (UIView *view in [self.view subviews]) {
        
        if ([view isKindOfClass:[BricksClass class]]) {
            [view removeFromSuperview];
        }
        
        
    }
    
    
    for (int i = 0; i<24; i++) {
        
        
        BricksClass *brick=[[BricksClass alloc] initWithFrame:CGRectMake(x, y, 50, 30)];
        
        [brick setBackgroundColor:[UIColor lightGrayColor]];
        
        brick.Type=0;
        
        if (i%10==0) {
            
            brick.Type=1;
            [brick setBackgroundColor:[UIColor purpleColor]];
            
        }
        
        UIBezierPath *Path=[UIBezierPath bezierPathWithRoundedRect:brick.bounds byRoundingCorners:UIRectCornerTopLeft cornerRadii:CGSizeMake(15, 15)];
        
        CAShapeLayer *layer=[[CAShapeLayer alloc] init];
        
        layer.path=Path.CGPath;
        
        [brick.layer setMask:layer];
        
        [self.view addSubview:brick];
        
        [_BricksArray addObject:brick];
        
        
        
        x=x+60;
        
        if (x>= ScreenSize.width-10) {
            
            x=10;
            
            y=y+50;
            
        }
        
        
    }


}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (!Play) {
        
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[_MainBall]];
        
        gravity.magnitude = 0.5;
        
        //[_animator addBehavior:gravity];
        
        NSMutableArray *CollisionArray=[[NSMutableArray alloc] initWithObjects:_MainBall,_MainPaddle, nil];
        
        [CollisionArray addObjectsFromArray:_BricksArray];
        
        
        UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:CollisionArray];
        
        [collision setTranslatesReferenceBoundsIntoBoundary:YES];
        
        [collision setCollisionMode:UICollisionBehaviorModeEverything];
        
        [collision setCollisionDelegate:self];
        
        [collision addBoundaryWithIdentifier:@"GameOver" fromPoint:CGPointMake(0, [[UIScreen mainScreen] bounds].size.height) toPoint:CGPointMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        
        
        [_animator addBehavior:collision];
        
        
        UIDynamicItemBehavior *BricksBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:_BricksArray];
        
        
        BricksBehaviour.density = 100000;
        
        BricksBehaviour.allowsRotation = NO;
        
        [_animator addBehavior:BricksBehaviour];
        
        
        
        UIDynamicItemBehavior *PaddleBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[_MainPaddle]];
        
        
        PaddleBehaviour.density = 100000;
        
        PaddleBehaviour.allowsRotation = NO;
        
        
        [_animator addBehavior:PaddleBehaviour];
        
        
        
        UIDynamicItemBehavior *BallBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[_MainBall]];
        
        BallBehaviour.elasticity = 1.0;
        
        BallBehaviour.resistance = 0;
        
        BallBehaviour.friction = 0;
        
        
        BallBehaviour.allowsRotation = NO;
        
        
        [_animator addBehavior:BallBehaviour];
        
        
        UIPushBehavior *StartingPush = [[UIPushBehavior alloc] initWithItems:@[_MainBall] mode:UIPushBehaviorModeInstantaneous];
        
        StartingPush.active = YES;
        
        StartingPush.pushDirection = CGVectorMake(-1, -1);
        
        StartingPush.magnitude = 0.7f;
        
        [_animator addBehavior:StartingPush];
        
        
        
        Play=YES;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint TouchPoint = [touch locationInView:self.view];
    
    
    
    _MainPaddle.center = CGPointMake(TouchPoint.x, _MainPaddle.center.y);
    
    
    [_animator updateItemUsingCurrentState:_MainPaddle];


}


- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    
    if (item1==_MainBall && item2==_MainPaddle) {
        
        
        
        
//        UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[_MainBall] mode:UIPushBehaviorModeInstantaneous];
//        
//        pushBehavior.magnitude = 0.50;
//        
//        
//        if (p.x>_MainPaddle.center.x) {
//            pushBehavior.pushDirection=CGVectorMake(1, -1);
//        }
//        else if (p.x==_MainPaddle.center.x)
//        {
//            
//            pushBehavior.pushDirection=CGVectorMake(0, -1);
//            
//        }
//        else if (p.x<_MainPaddle.center.x)
//        {
//            
//            pushBehavior.pushDirection=CGVectorMake(-1, -1);
//            
//        }
//        
//        [_animator addBehavior:pushBehavior];
        
    }
    else if([item2 isKindOfClass:[BricksClass class]])
    {
        
        BricksClass *HitView=(BricksClass *)item2;
        
        if (HitView.Type==1) {
            HitView.Type--;
            [HitView setBackgroundColor:[UIColor lightGrayColor]];
        }
        else
        {
            
            
            [HitView setHidden:YES];
            
            
            [behavior removeItem:item2];
            
            
            [_BricksArray removeObject:HitView];
            
            
            
            if ([_BricksArray count]==0) {
                
                [_animator removeAllBehaviors];
                
                UIAlertView *WinnerAlert = [[UIAlertView alloc] initWithTitle:@"Winner" message:@"Congratulation you win the game.....!" delegate:self cancelButtonTitle:@"Replay" otherButtonTitles:@"Close", nil];
                
                [WinnerAlert show];
                
            }
        
        
        }
        
        
        
    }
    
}


- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier atPoint:(CGPoint)p
{

    NSString *ind = (NSString *)identifier;

    if (item== _MainBall &&[ind isEqualToString:@"GameOver"]) {
        
        [_animator removeAllBehaviors];
        
        UIAlertView *GameOverAlert = [[UIAlertView alloc] initWithTitle:@"Game Over..." message:@"Do you wish to retry ?" delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"No", nil];
        
        [GameOverAlert show];
        
    }


}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 0) {
        
        
        
        [self DrawBallAndPaddle];
        
        [self DrawBricksPattern];
        
        
        Play=NO;
        
        
        
    }


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
