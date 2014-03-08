//
//  MainShopViewController.m
//  mySMU
//
//  Created by Bob Cao on 1/3/14.
//  Copyright (c) 2014 Bob Cao. All rights reserved.
//

#define mySMUQueue dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "MainShopViewController.h"
#import "ShopSliderViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MYSMUConstants.h"
#import "TSSCategories.h"
#import "SubCategoryViewController.h"
#import "ProductsViewController.h"

@interface MainShopViewController ()

@property (strong, nonatomic) IBOutlet UITableView *categoryTableView;
@property (strong, nonatomic) NSMutableArray *sliderViewControllers;
@property (strong, nonatomic) UIPageViewController *sliderPageVC;
@property NSArray *sliderImages;
@property (strong, nonatomic) NSMutableArray *categories;

@end

@implementation MainShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.categories = [[NSMutableArray alloc] init];
    [self getSliders];
    [self getCategories];
}

- (void)getSliders {
    NSLog(@"get sldiers");
    // Do any additional setup after loading the view.
    
    //getting the array of banners
    //get an array of links...
    self.sliderImages = @[@"banner1.png",@"banner2.png",@"banner3.png"];
    self.sliderViewControllers = [[NSMutableArray alloc] init];
    
    //loop through and add relevant slider content view controllers
    for (NSString *slider in self.sliderImages) {
        ShopSliderViewController *sliderContentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SliderContentViewController"];
        sliderContentVC.sliderImage = [UIImage imageNamed:slider];
        [self.sliderViewControllers addObject:sliderContentVC];
    }
    
    self.sliderPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.sliderPageVC.dataSource = self;
    
    //NSLog(@"%lu",(unsigned long)self.sliderViewControllers.count);
    NSArray *array = @[[self.sliderViewControllers objectAtIndex:0]];
    
    [self.sliderPageVC setViewControllers:array direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    // Change the size of page view controller
    self.sliderPageVC.view.frame = CGRectMake(0, 64, 320, 160);
    
    [self addChildViewController:self.sliderPageVC];
    [self.view addSubview:self.sliderPageVC.view];
    [self.sliderPageVC didMoveToParentViewController:self];
}

- (void)getCategories{
    //must get all 
    NSLog(@"get all categories");
    
    //implement this if the json is huge
    //[NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@index.php?route=%@&key=%@",ShopDomain,@"feed/web_api/categories",RESTfulKey,Nil];
    //NSLog(@"and the calling url is .. %@",urlString);
    NSURL *categoryURL = [NSURL URLWithString:urlString];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:categoryURL] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"fetching categories data failed");
        } else {
            NSError *localError = nil;
            id parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if([parsedObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *results = parsedObject;
                //construct objects and pass to array
                
                for (NSObject *ob in [results valueForKey:@"categories"]){
                    TSSCategories *category = [[TSSCategories alloc] init];
                    [category setCategoryName:[ob valueForKey:@"name"] CategoryID:[ob valueForKey:@"category_id"] parentID:[ob valueForKey:@"parent_id"] andImageURLString:[ob valueForKey:@"image"]];
                    NSLog(@"%@",[ob valueForKey:@"image"]);
                    
                    [self.categories addObject:category];
                }
            } else {
                NSLog(@"what we get is not a kind of clss nsdictionary class");
            }
        }
        NSLog(@"reload data");
        [self.categoryTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    int vcIndex = [self.sliderViewControllers indexOfObject:viewController];
    
    if (vcIndex == 0) {
        vcIndex = self.sliderViewControllers.count - 1;
    } else {
       vcIndex--;
    }
    
    return self.sliderViewControllers[vcIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    int vcIndex = [self.sliderViewControllers indexOfObject:viewController];
    
    if (vcIndex == (self.sliderViewControllers.count - 1)) {
        vcIndex = 0;
    } else {
        vcIndex++;
    }
    
    return self.sliderViewControllers[vcIndex];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //static NSString *CellIdentifier = @"subcategorycell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    //get corresponding category object from the array
    TSSCategories *cateogry = (TSSCategories *)[self.categories objectAtIndex:indexPath.row];
    
    //config the cell
    cell.textLabel.text = cateogry.name;
    [cell.textLabel sizeToFit];
    
    if ([cateogry.imageURLString isKindOfClass:[NSString class]])  {
        NSURL *imageURL = [NSURL URLWithString:cateogry.imageURLString];
        [cell.imageView setImageWithURL:imageURL];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *parentID = [self.categories[indexPath.row] categoryID];
    
    NSString *urlString = [NSString stringWithFormat:@"%@index.php?route=feed/web_api/%@&key=%@&id=%@",ShopDomain,@"getCategoriesByParentId",RESTfulKey,parentID];
    
    //NSLog(@"and the calling url is .. %@",urlString);
    NSURL *categoryURL = [NSURL URLWithString:urlString];
    
    //asking for information
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:categoryURL] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"fetching sub categories data failed");
        } else {
            NSError *localError = nil;
            id parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if([parsedObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *results = parsedObject;
                if ([[results valueForKey:@"count"] isEqual:@0]) {
                    //initialize collection view
                    NSLog(@"and the count is %@", [results valueForKey:@"count"]);
                    [self performSelectorOnMainThread:@selector(pushProductCollectionsVC:) withObject:self.categories[indexPath.row] waitUntilDone:NO];
                } else {
                    //initialize subcategory view
                    NSMutableArray *subCategories = [[NSMutableArray alloc] init];
                    //code for constructing new categories objects
                    for (NSObject *ob in [results valueForKey:@"categories"]){
                        TSSCategories *category = [[TSSCategories alloc] init];
                        [category setCategoryName:[ob valueForKey:@"name"] CategoryID:[ob valueForKey:@"category_id"] parentID:[ob valueForKey:@"parent_id"] andImageURLString:[ob valueForKey:@"image"]];
                        [subCategories addObject:category];
                    }
                    [self performSelectorOnMainThread:@selector(pushSubCategoryVC:) withObject:subCategories waitUntilDone:NO];
                }
            } else {
                NSLog(@"what we get is not a kind of clss nsdictionary class");
            }
        }
    }];
}

- (void)pushSubCategoryVC:(NSMutableArray *)subCategories {
    //initialize
    SubCategoryViewController *subCategoriesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"subCategories"];
    //set sub categories
    subCategoriesVC.categories = [NSArray arrayWithArray:subCategories];
    NSLog(@"%lu",subCategoriesVC.categories.count);
    [self.navigationController pushViewController:subCategoriesVC animated:YES];
}

- (void)pushProductCollectionsVC:(TSSCategories *)selectedCategory {
    //initialize
    ProductsViewController *productsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
    //set category
    productsVC.selectedCategory = selectedCategory;
    //NSLog(selectedCategory);
    [self.navigationController pushViewController:productsVC animated:YES];
}

@end
