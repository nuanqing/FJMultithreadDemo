//
//  ViewController.m
//  NSOprationDemo
//
//  Created by webplus on 17/9/7.
//  Copyright © 2017年 sanyi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSOperation是GCD的封装
    //NSOperation单独执行使用主线程，没有开辟新线程的能力
    //NSOperation是个抽象类，并不能封装任务。我们只有使用它的子类来封装任务。我们有三种方式来封装任务。
    
    //使用子类NSInvocationOperation
    //使用子类NSBlockOperation
    //定义继承自NSOperation的子类，通过实现内部相应的方法来封装任务。
    //在不使用NSOperationQueue，单独使用NSOperation的情况下系统同步执行操作，下面我们学习以下任务的三种创建方式。
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(invoOperationCLick) object:nil];
    [op1 start];
    NSLog(@"执行我1");
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        // 在主线程
        NSLog(@"------%@", [NSThread currentThread]);
    }];
    
    [op2 addExecutionBlock:^{
        NSLog(@"2------%@", [NSThread currentThread]);
    }];
    [op2 addExecutionBlock:^{
        NSLog(@"3------%@", [NSThread currentThread]);
    }];
    [op2 addExecutionBlock:^{
        NSLog(@"4------%@", [NSThread currentThread]);
    }];
    
    
    [op2 start];
    //此方法造成线程阻塞
     NSLog(@"执行我2");
    //NSOperationQueue一共有两种队列：主队列、其他队列。其中其他队列同时包含了串行、并发功能。下边是主队列、其他队列的基本创建方法和特点。
    //主队列
    NSOperationQueue *queue1 = [NSOperationQueue mainQueue];
    //其他队列
    NSOperationQueue *queue2 = [[NSOperationQueue alloc]init];
    
}

- (void)invoOperationCLick{
    NSLog(@"invoOperation:%@",[NSThread currentThread]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self addOperationToQueue];
    [self addDependency];
    [self opetationQueue];
}

- (void)addOperationToQueue{
    //创建队列就是异步操作
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2. 创建操作
    // 创建NSInvocationOperation
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run) object:nil];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2------%@", [NSThread currentThread]);
    }];
    [queue addOperation:op1];
    [queue addOperation:op2];
//    [op1 start];
//    [op2 start];
    NSLog(@"执行我3");
}

- (void)run{
    NSLog(@"1-----%@", [NSThread currentThread]);
}

- (void)addDependency
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1-----%@", [NSThread  currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2-----%@", [NSThread  currentThread]);
    }];
    
    [op2 addDependency:op1];    // 让op2 依赖于 op1，则先执行op1，在执行op2
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    NSLog(@"执行我4");
}
- (void)opetationQueue
{
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 设置最大并发操作数
    //    queue.maxConcurrentOperationCount = 2;
    queue.maxConcurrentOperationCount = 1; // 就变成了串行队列
    
    // 添加操作
    [queue addOperationWithBlock:^{
        NSLog(@"1-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"2-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"3-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"4-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"5-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    
    [queue addOperationWithBlock:^{
        NSLog(@"6-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    NSLog(@"执行我5");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
