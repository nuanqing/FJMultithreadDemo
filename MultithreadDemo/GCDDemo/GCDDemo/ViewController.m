//
//  ViewController.m
//  GCDDemo
//
//  Created by webplus on 17/9/6.
//  Copyright © 2017年 sanyi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,assign) BOOL isCancel;
@property (nonatomic,assign) int number;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 同步执行（sync）：只能在当前线程中执行任务，不具备开启新线程的能力
    // 异步执行（async）：可以在新的线程中执行任务，具备开启新线程的能力
    //并行队列（Concurrent Dispatch Queue）：可以让多个任务并行（同时）执行（自动开启多个线程同时执行任务）
    //串行队列（Serial Dispatch Queue）：让任务一个接着一个地执行
    //串是一种链型结构，遵循的是FIFO原则，先进先出，同数组存取方式
    _isCancel = YES;
    _number = 4;
}

//同步串行队列,同步不开新队列,所以同步并行与串行都会串行执行,同时阻塞当前线程，若在直接在主队列中使用，会阻塞主线程,造成死锁,若在主线程中使用，需重新分配队列
//主线程最开始已经创建主队列，主队列已经存在于runloop中，主线程控制主队列，所以主线程不结束主队列不销毁， dispatch_sync会阻塞当前线程，然后把 Block 中的任务放到指定的队列中执行，此时队列还有其它任务执行时，会执行其他任务，只有等到 Block 中的任务完成后才会让当前线程继续往下运行，此时主队列已经存在而且一直执行直到主线程销毁，主队列任务没有执行完，它不执行block块，block不执行，主线程也一直执行不了，死锁
- (IBAction)TCtestClick:(id)sender {
    dispatch_queue_t serialQueue = dispatch_queue_create("TCtest.serial", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        NSLog(@"同步串行1：%@",[NSThread currentThread]);
    });
    dispatch_sync(serialQueue, ^{
        NSLog(@"同步串行2：%@",[NSThread currentThread]);
    });
    NSLog(@"执行我");
    
}
//异步串行队列
- (IBAction)YCTestClick:(id)sender {
    dispatch_queue_t serialQueue = dispatch_queue_create("YCtest.serial", DISPATCH_QUEUE_SERIAL);
    dispatch_async(serialQueue, ^{
        NSLog(@"异步串行1：%@",[NSThread currentThread]);
    });
    dispatch_async(serialQueue, ^{
        NSLog(@"异步串行2：%@",[NSThread currentThread]);
    });
    NSLog(@"执行我");
}
//异步并行队列
- (IBAction)YBTestClick:(id)sender {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("YBtest.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        NSLog(@"异步并行1：%@",[NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"异步并行2：%@",[NSThread currentThread]);
    });
    NSLog(@"执行我");
}
//异步主队列
- (IBAction)YZTestClick:(id)sender {
    //顺序执行
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"异步主队列1：%@",[NSThread currentThread]);
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"异步主队列2：%@",[NSThread currentThread]);
    });
    NSLog(@"执行我");
}
//同步全局队列
- (IBAction)TQTestClick:(id)sender {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(globalQueue, ^{
        NSLog(@"同步全局1：%@",[NSThread currentThread]);
    });
    dispatch_sync(globalQueue, ^{
        NSLog(@"同步全局2：%@",[NSThread currentThread]);
    });
    NSLog(@"执行我");
}
//异步全局队列
- (IBAction)YQTestClick:(id)sender {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSLog(@"异步全局1：%@",[NSThread currentThread]);
    });
    dispatch_async(globalQueue, ^{
        NSLog(@"异步全局2：%@",[NSThread currentThread]);
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"异步全局3优先：%@",[NSThread currentThread]);
    });
    NSLog(@"执行我");
}
//同步没有dispatch_group_sync方法，只能使用wait方法，阻塞主线程，异步拥有开辟新线程的能力，异步串行，在新线程中执行多个任务
- (IBAction)TZUTestClick:(id)sender {
    //同步使用wait的方法
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t groupQueue = dispatch_queue_create("YZtest.group", DISPATCH_QUEUE_SERIAL);
    dispatch_group_async(group, groupQueue, ^{
        NSLog(@"异步串行分组1：%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, groupQueue, ^{
        NSLog(@"异步串行分组2：%@",[NSThread currentThread]);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程...
        NSLog(@"异步分组所有任务执行完了");
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    //阻塞当前列
    NSLog(@"执行我");
}
//异步组队列，三个任务开始执行，执行完通知回到主线程刷新UI
- (IBAction)YZUTestClick:(id)sender {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t groupQueue = dispatch_queue_create("YZtest.group", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, groupQueue, ^{
        NSLog(@"异步分组1：%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, groupQueue, ^{
        NSLog(@"异步分组2：%@",[NSThread currentThread]);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程...
        NSLog(@"异步分组所有任务执行完了");
    });
    NSLog(@"执行我");
}
//延时执行
- (IBAction)YSTestClick:(id)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSLog(@"延时执行：%@",[NSThread currentThread]);
    });
    NSLog(@"执行我");
    
}
//循环执行
- (IBAction)XHTestClick:(id)sender {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("XHtest.apply", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(4, concurrentQueue, ^(size_t idx) {
        NSLog(@"循环次数:%zu",idx);
    });
    //阻塞当前线程
    NSLog(@"执行我1");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步全局3：%@",[NSThread currentThread]);
        dispatch_apply(4, concurrentQueue, ^(size_t idx) {
            NSLog(@"循环次数:%zu",idx);
        });
        //线程阻塞,执行完循环再执行打印
        NSLog(@"执行我2");
    });
    NSLog(@"执行我3");
}
//线程挂起
- (IBAction)GQTestClick:(id)sender {
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("XHtest.apply", DISPATCH_QUEUE_CONCURRENT);
    dispatch_suspend(concurrentQueue);
   dispatch_async(concurrentQueue, ^{
       NSLog(@"我被执行了");
   });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步全局3：%@",[NSThread currentThread]);
        //挂起了串行队列，可以挂起不同队列，不要挂起同步队列，会阻塞当前线程
        dispatch_resume(concurrentQueue);
    });
    NSLog(@"执行我3");
   
}
//定时器
- (IBAction)TMTtestClick:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置时间允许0纳秒偏差
    dispatch_source_set_timer(timerSource, DISPATCH_TIME_NOW, 1*NSEC_PER_SEC, 0);
   __block NSInteger time = 10;
    dispatch_source_set_event_handler(timerSource, ^{
        if (time<=0) {
            dispatch_source_cancel(timerSource);
        }else{
            NSLog(@"%ld",time);
            time = time-1;
        }
    });
    
    dispatch_source_set_cancel_handler(timerSource, ^{
        NSLog(@"结束");
    });
    //执行方法，不写不走
    dispatch_resume(timerSource);
}
//异步信号量
- (IBAction)YXHLTestClick:(id)sender {
    //信号量：就是一种可用来控制访问资源的数量的标识，设定了一个信号量，在线程访问之前，加上信号量的处理，则可告知系统按照我们指定的信号量数量来执行多个线程。使用场景：下载的时候，有三个资源，设置最大并发数信号量为2，开始执行两个，一个结束，第三个开始
    //crate的value表示，最多几个资源可访问
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //任务1
    dispatch_async(quene, ^{
        //信号量-1
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 1");
        sleep(1);
        NSLog(@"complete task 1");
        NSLog(@"异步信号量1：%@",[NSThread currentThread]);
        //信号量+1
        dispatch_semaphore_signal(semaphore);
    });
    //任务2
    dispatch_async(quene, ^{
        //信号量-1
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 2");
        sleep(4);//模拟耗时操作
        NSLog(@"complete task 2");
         NSLog(@"异步信号量2：%@",[NSThread currentThread]);
        //信号量+1
        dispatch_semaphore_signal(semaphore);
    });
    //任务3
    dispatch_block_cancel(^{
        
    });
    
    dispatch_async(quene, ^{
        //此时信号量为0,不执行,等信号量释放一个，为1时执行
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 3");
        sleep(1);
        NSLog(@"complete task 3");
         NSLog(@"异步信号量3：%@",[NSThread currentThread]);
        
        dispatch_semaphore_signal(semaphore);
    });
}
//异步栏栅
- (IBAction)YLSTestClick:(id)sender {
    //同dispatch_queue_create函数生成的concurrent Dispatch Queue队列一起使用
    //与信号量相似，但会进行插入栏栅块的操作
    dispatch_queue_t queue = dispatch_queue_create("YLStest.concurrent", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"异步并发1:%@", [NSThread currentThread]);
        sleep(1);
    });
    dispatch_async(queue, ^{
        NSLog(@"异步并发2:%@", [NSThread currentThread]);
        sleep(1);
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"异步栏栅:%@", [NSThread currentThread]);
        sleep(1);
    });
    
    dispatch_async(queue, ^{
       NSLog(@"异步并发3:%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"异步并发4:%@", [NSThread currentThread]);
    });
}
//任务取消
- (IBAction)YXHLCTestClick:(id)sender {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i=0; i<10; i++) {
        dispatch_async(quene, ^{
            //此时信号量为0,不执行,等信号量释放一个，为1时执行
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (_isCancel&&_number == i) {
                NSLog(@"任务%d还未执行被取消",i);
                _isCancel = NO;
                dispatch_semaphore_signal(semaphore);
                return ;
            }
            NSLog(@"run task %d",i);
            sleep(1);
            NSLog(@"complete task %d",i);
            NSLog(@"任务%d的线程：%@",i,[NSThread currentThread]);
            
            dispatch_semaphore_signal(semaphore);
        });
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
