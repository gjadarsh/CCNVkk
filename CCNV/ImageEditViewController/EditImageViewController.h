//
//  EditImageViewController.h
//  CCNV
//
//  Created by  Linksware Inc. on 12/21/2012.
//
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "SmoothLineView.h"
@class SmoothLineView,AlbumContent;
@interface EditImageViewController : UIViewController<UITextFieldDelegate>{
   
    SmoothLineView *canvas;
    IBOutlet UIImageView *imageView;
    IBOutlet UIView *captureview;
    AlbumContent *albumcontenclass;
    UIImage *img;
    IBOutlet UIButton *draw;
    IBOutlet UIButton *erase;
    NSMutableData *ResponseData;
    
    UIImage *updatedImage;
    
    NSURLConnection *Connection3;
    NSMutableData *ResponseData3;
    
    UILabel *lblTitle;
    UITextField *txtTitle;
     IBOutlet UIToolbar *toolbar;
}

@property(nonatomic,strong)NSString *selectedURl;
@property(nonatomic,strong)NSString *selectedImageName;
@property(nonatomic,strong)UIImage *img;
@property(nonatomic,strong)File *fileobj;
@property(nonatomic,strong)UIImage *updatedImage;
-(void)done_clicked;
-(IBAction)RenameClicked:(id)sender;
-(IBAction)draw_clicked:(id)sender;
-(IBAction)erase_clicked:(id)sender;

@end
