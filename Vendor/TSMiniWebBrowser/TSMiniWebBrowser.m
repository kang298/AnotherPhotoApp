//
//  TSMiniWebBrowser.m
//  TSMiniWebBrowserDemo
//
//  Created by Toni Sala Echaurren on 18/01/12.
//  Copyright 2012 Toni Sala. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "TSMiniWebBrowser.h"

@implementation TSMiniWebBrowser

@synthesize showURLStringOnActionSheetTitle;
@synthesize showPageTitleOnTitleBar;
@synthesize showReloadButton;
@synthesize showActionButton;
@synthesize isModal;
@synthesize barStyle;
@synthesize modalDismissButtonTitle;

#pragma mark - Private Methods

-(void) toggleBackForwardButtons {
    buttonGoBack.enabled = webView.canGoBack;
    buttonGoForward.enabled = webView.canGoForward;
}

-(void) checkIsLoading {
    if (webView.loading) {
        [activityIndicator setHidden:NO];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        [activityIndicator setHidden:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

-(void) dismissController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Init

-(void) initTitleBar {
    //UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(dismissController)];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithTitle:modalDismissButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(dismissController)];
    
    UINavigationItem *titleBar = [[UINavigationItem alloc] initWithTitle:@""];
    titleBar.rightBarButtonItem = buttonDone;
    
    CGFloat width = self.view.frame.size.width;
    navigationBarModal = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, width, 44)] autorelease];
    //navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    navigationBarModal.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    navigationBarModal.barStyle = barStyle;
    [navigationBarModal pushNavigationItem:titleBar animated:NO];
    
    [self.view addSubview:navigationBarModal];
    
    [titleBar release];
    [buttonDone release];
}

-(void) initToolBar {
    if (!isModal) {
        self.navigationController.navigationBar.barStyle = barStyle;
    }
    
    CGSize viewSize = self.view.frame.size;
    toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-kToolBarHeight, viewSize.width, kToolBarHeight)] autorelease];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    toolBar.barStyle = barStyle;
    [self.view addSubview:toolBar];
    
    buttonGoBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTouchUp:)];
    
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    fixedSpace.width = 30;
    
    buttonGoForward = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonTouchUp:)] autorelease];
    
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]autorelease];
    
    UIBarButtonItem *buttonReload = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(reloadButtonTouchUp:)]autorelease];
    
    UIBarButtonItem *fixedSpace2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    fixedSpace2.width = 20;
    
    UIBarButtonItem *buttonAction = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(buttonActionTouchUp:)] autorelease];
    
    // Activity indicator is a bit special
    activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    activityIndicator.frame = CGRectMake(11, 7, 20, 20);
    [activityIndicator startAnimating];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 43, 33)];
    [containerView addSubview:activityIndicator];
    UIBarButtonItem *buttonContainer = [[[UIBarButtonItem alloc] initWithCustomView:containerView] autorelease];
    
    // Add butons to an array
    NSMutableArray *toolBarButtons = [[NSMutableArray alloc] init];
    [toolBarButtons addObject:buttonGoBack];
    [toolBarButtons addObject:fixedSpace];
    [toolBarButtons addObject:buttonGoForward];
    [toolBarButtons addObject:flexibleSpace];
    [toolBarButtons addObject:buttonContainer];
    if (showReloadButton) { 
        [toolBarButtons addObject:buttonReload];
    }
    if (showActionButton) {
        [toolBarButtons addObject:fixedSpace2];
        [toolBarButtons addObject:buttonAction];
    }
    
    // Set buttons to tool bar
    [toolBar setItems:toolBarButtons animated:YES];
    
    [toolBarButtons release];
}

-(void) initWebView {
    CGSize viewSize = self.view.frame.size;
    if (isModal) {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kToolBarHeight, viewSize.width, viewSize.height-kToolBarHeight*2)];
    } else {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, viewSize.height-kToolBarHeight)];
    }
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    
    webView.scalesPageToFit = YES;
    
    webView.delegate = self;
    
    // Load the URL in the webView
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlToLoad];
    [webView loadRequest:requestObj];
}

#pragma mark -

- (id)initWithUrl:(NSURL*)url {
    self = [self init];
    if(self)
    {
        urlToLoad = url;
        
        // Defaults
        showURLStringOnActionSheetTitle = YES;
        showPageTitleOnTitleBar = YES;
        showReloadButton = YES;
        showActionButton = YES;
        isModal = NO;
        modalDismissButtonTitle = NSLocalizedString(@"Done", nil);
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Store the current navigationBar bar style to be able to restore it later.
    if (!isModal) {
        originalBarStyle = self.navigationController.navigationBar.barStyle;
    }
    
    // Init web view
    [self initWebView];
    
    // Init tool bar
    [self initToolBar];
    
    // Init title bar if presented modally
    if (isModal) {
        [self initTitleBar];
    }
    
    // UI state
    activityIndicator.hidden = NO;
    buttonGoBack.enabled = NO;
    buttonGoForward.enabled = NO;
    
    // Set callback for activity indicator status.
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkIsLoading) userInfo:nil repeats:YES];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Restore navigationBar bar style.
    if (!isModal) {
        self.navigationController.navigationBar.barStyle = originalBarStyle;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

/* Fix for landscape + zooming webview bug.
 * If you experience perfomance problems on old devices ratation, comment out this method.
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat ratioAspect = webView.bounds.size.width/webView.bounds.size.height;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            // Going to Portrait mode
            for (UIScrollView *scroll in [webView subviews]) { //we get the scrollview 
                // Make sure it really is a scroll view and reset the zoom scale.
                if ([scroll respondsToSelector:@selector(setZoomScale:)]){
                    scroll.minimumZoomScale = scroll.minimumZoomScale/ratioAspect;
                    scroll.maximumZoomScale = scroll.maximumZoomScale/ratioAspect;
                    [scroll setZoomScale:(scroll.zoomScale/ratioAspect) animated:YES];
                }
            }
            break;
        default:
            // Going to Landscape mode
            for (UIScrollView *scroll in [webView subviews]) { //we get the scrollview 
                // Make sure it really is a scroll view and reset the zoom scale.
                if ([scroll respondsToSelector:@selector(setZoomScale:)]){
                    scroll.minimumZoomScale = scroll.minimumZoomScale *ratioAspect;
                    scroll.maximumZoomScale = scroll.maximumZoomScale *ratioAspect;
                    [scroll setZoomScale:(scroll.zoomScale*ratioAspect) animated:YES];
                }
            }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - Action Sheet

- (void)showActionSheet {
    NSString *urlString = @"";
    if (showURLStringOnActionSheetTitle) {
        NSURL* url = [webView.request URL];
        urlString = [url absoluteString];
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:urlString
															 delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Open in Safari", nil),  nil];
    
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
    
    [actionSheet release];
    
    // ** Use this code instead to present the action sheet if you have a tab bar. Import AppDelegate.h
    //AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //[actionSheet showInView:appDelegate.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0:
			// Open in Safari
            [[UIApplication sharedApplication] openURL:[webView.request URL]];
			break;
		default:
			break;
	}
}

#pragma mark - Actions

- (void)backButtonTouchUp:(id)sender {
    [webView goBack];
    
    [self toggleBackForwardButtons];
}

- (void)forwardButtonTouchUp:(id)sender {
    [webView goForward];
    
    [self toggleBackForwardButtons];
}

- (void)reloadButtonTouchUp:(id)sender {
    [webView reload];
    
    [self toggleBackForwardButtons];
}

- (void)buttonActionTouchUp:(id)sender {
    [self showActionSheet];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self toggleBackForwardButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    // Show page title on title bar?
    if (showPageTitleOnTitleBar) {
        NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (isModal) {
            navigationBarModal.topItem.title = pageTitle;
        } else {
            if(pageTitle) [[self navigationItem] setTitle:pageTitle];
        }
    }
}

-(void)dealloc {
    
    [webView release];
    [super dealloc];
}

@end
