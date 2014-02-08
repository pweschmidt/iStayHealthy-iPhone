//
//  BaseCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/11/2013.
//
//

#import "BaseCollectionViewController.h"
#import "CoreDataConstants.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "CustomToolbar.h"

@interface BaseCollectionViewController ()

@end

@implementation BaseCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.itemSize = CGSizeMake(150, 150);
    self.collectionViewLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width-40, 100);
    self.collectionViewLayout.minimumInteritemSpacing = 20;
    self.collectionViewLayout.minimumLineSpacing = 20;
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    CGRect frame = CGRectMake(20, 44, self.view.frame.size.width - 40, self.view.frame.size.height - 88);
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame
                                             collectionViewLayout:self.collectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    CGRect toolbarFrame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    CustomToolbar *toolbar = [[CustomToolbar alloc] initWithFrame:toolbarFrame];
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadSQLData:)
     name:kLoadedStoreNotificationKey
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleError:)
     name:kErrorStoreNotificationKey
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleStoreChanged:)
     name:NSPersistentStoreCoordinatorStoresDidChangeNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadSQLData:)
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:kLoadedStoreNotificationKey
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:kErrorStoreNotificationKey
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSPersistentStoreCoordinatorStoresDidChangeNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
    
}

#pragma mark Collection View delegate methods. Override in sub classes
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]                                 userInfo:nil];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]                                 userInfo:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]                                 userInfo:nil];
}

#pragma mark Core Data and other methods to override in subclasses
- (void)reloadSQLData:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}
- (void)startAnimation:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}
- (void)stopAnimation:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
    
}
- (void)handleError:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

@end
