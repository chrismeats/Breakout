//
//  ViewController.m
//  Breakout
//
//  Created by ETC ComputerLand on 7/31/14.
//  Copyright (c) 2014 cmeats. All rights reserved.
//

#import "ViewController.h"
#import "PaddleView.h"
#import "BallView.h"
#import "BlockView.h"

@interface ViewController () <UICollisionBehaviorDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet PaddleView *paddleView;
@property (strong, nonatomic) IBOutlet BallView *ballView;
@property (strong, nonatomic) IBOutlet BlockView *blockView;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

@property UIDynamicAnimator *dynamicAnimator;
@property UIPushBehavior *pushBehavior;
@property UICollisionBehavior *collisionBehavior;
@property UIDynamicItemBehavior *paddleDynamicBehavior;
@property UIDynamicItemBehavior *ballDynamicBehavior;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self changeScore:0];

    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];

    self.pushBehavior.pushDirection = CGVectorMake(0.5, 1.0);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = 0.2;
    [self.dynamicAnimator addBehavior:self.pushBehavior];


    self.collisionItems = [[NSMutableArray alloc] initWithObjects:
                           self.ballView,
                           self.paddleView,
                           self.blockView,
                           nil];
    /* Add all block from storyboard */
    for (BlockView *blockView in self.view.subviews) {
        if ([blockView isKindOfClass:[BlockView class]]) {
           [self.collisionItems addObject:blockView];
            UIDynamicItemBehavior *newBlockDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[blockView]];
            newBlockDynamicBehavior.allowsRotation = NO;
            newBlockDynamicBehavior.density = 9999;
            [self.dynamicAnimator addBehavior:newBlockDynamicBehavior];
        }
    }
    // Add new row of blocks
    [self addNewBlock];
    [self addNewBlock];
    [self addNewBlock];
    [self addNewBlock];


    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:self.collisionItems];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.collisionDelegate = self;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [self.dynamicAnimator addBehavior:self.collisionBehavior];

    self.paddleDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddleView]];
    self.paddleDynamicBehavior.allowsRotation = NO;
    self.paddleDynamicBehavior.density = 1000;
    [self.dynamicAnimator addBehavior:self.paddleDynamicBehavior];

    self.ballDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ballView]];
    self.ballDynamicBehavior.allowsRotation = NO;
    self.ballDynamicBehavior.elasticity = 1.0;
    self.ballDynamicBehavior.friction = 0;
    self.ballDynamicBehavior.resistance = 0;
    [self.dynamicAnimator addBehavior:self.ballDynamicBehavior];
}

-(IBAction)dragPaddle:(UIPanGestureRecognizer *)panGesture
{
    self.paddleView.center = CGPointMake([panGesture locationInView:self.view].x, self.paddleView.center.y);
    [self.dynamicAnimator updateItemUsingCurrentState:self.paddleView];

}

/**
 * Ball Hit boundary
 */
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (p.y+1 > CGRectGetMaxY(self.view.frame)) {
        [self changeScore:self.score-5];
        self.ballView.center = self.view.center;
        [self.dynamicAnimator updateItemUsingCurrentState:self.ballView];
    }
}

/**
 * Ball Hit block
 */
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    if ([item2 isKindOfClass:[BlockView class]]) {
        BlockView *blockView = (BlockView *)item2;
        [self changeScore:++self.score];
        if (blockView.dificulty == 0) {
            blockView.alpha = 1.0f;
            [UIView animateWithDuration:1.0 animations:^{
                blockView.alpha = 0.0f;
            } completion:^(BOOL finished){
                // Remove block
                [blockView removeFromSuperview];
                [self.collisionBehavior removeItem:blockView];
                if ([self shouldStartAgain]) {
                    UIAlertView *alertView = [[UIAlertView alloc] init];
                    alertView.title = @"End of Round";
                    alertView.message = @"Do you want to play another round";
                    [alertView addButtonWithTitle:@"Play Again"];
                    [alertView addButtonWithTitle:@"Change to Player"];
                    alertView.delegate = self;
                    [self.dynamicAnimator removeBehavior:self.pushBehavior];
                    self.pushBehavior.active = NO;
                    [self.dynamicAnimator addBehavior:self.pushBehavior];
                    [alertView show];
//                    [self.dynamicAnimator add]
                    //Start Again
                    // [self startAgain];
                }
            }];
        } else {
            // Decrese difficulty and change color
            blockView.dificulty --;
            blockView.backgroundColor = blockView.colors[blockView.dificulty];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self startAgain];
    }
}

-(void)addNewBlock
{
    // get last collision item
    BlockView *block = [self.collisionItems objectAtIndex:self.collisionItems.count-4];
    CGRect bounds = CGRectMake(block.frame.origin.x, block.frame.origin.y+35, 60, 30);

    BlockView *newBlock = [[BlockView alloc] initWithFrame:bounds];
    [newBlock setBackgroundColor:[UIColor redColor]];
    newBlock.alpha = 1.0f;
    [self.view addSubview:newBlock];
    [self.collisionItems addObject:newBlock];

    UIDynamicItemBehavior *newBlockDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[newBlock]];
    newBlockDynamicBehavior.allowsRotation = NO;
    newBlockDynamicBehavior.density = 9999;
    [self.dynamicAnimator addBehavior:newBlockDynamicBehavior];
}

-(BOOL)shouldStartAgain
{
    for (BlockView *blockView in self.view.subviews) {
        if ([blockView isKindOfClass:[BlockView class]]) {
            return NO;
        }
    }
    return YES;
}

-(void)startAgain
{
    [self changeScore:self.score+5];
    for (BlockView *blockView in self.collisionItems) {
        if ([blockView isKindOfClass:[BlockView class]]) {
            blockView.alpha = 1.0f;
            blockView.dificulty = arc4random()%3;
            blockView.backgroundColor = blockView.colors[blockView.dificulty];
            [self.view addSubview:blockView];
            [self.collisionBehavior addItem:blockView];
        }
    }
    self.ballView.center = self.view.center;
    [self.dynamicAnimator updateItemUsingCurrentState:self.ballView];
}

-(void) changeScore:(int)score
{
    self.score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", score];
}

@end
