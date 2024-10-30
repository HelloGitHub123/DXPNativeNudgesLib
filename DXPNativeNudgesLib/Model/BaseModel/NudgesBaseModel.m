//
//  NudgesBaseModel.m
//  DITOApp
//
//  Created by 李标 on 2022/5/12.
//

#import "NudgesBaseModel.h"
#import "NdHJHandelJson.h"
#import "UIImage+ndImgSize.h"

@implementation NudgesBaseModel

- (NSDictionary *)hj_replacedKeyFromPropertyName {
    //子类重写
    return @{
        @"ownPropModel":@"ownProp",
        @"positionModel":@"position",
        @"appExtInfoModel":@"appExtInfo",
        @"backgroundModel":@"background",
        @"borderModel":@"border",
        @"backdropModel":@"backdrop",
        @"titleModel":@"title",
        @"bodyModel":@"body",
        @"imageModel":@"image",
//        @"video":@"video",
        @"buttonsModel":@"buttons",
        @"dismissButtonModel":@"dismissButton",
    };
    return nil;
}

#pragma mark -- initWithMsgDic
- (id)initWithMsgDic:(NSDictionary *)rDic {
    self = [super init];
    if (self) {
        self.contactId = [NSString ndStringWithoutNil:[rDic objectForKey:@"contactId"]];
        self.campaignId = [[NSString ndStringWithoutNil:[rDic objectForKey:@"campaignId"]] integerValue];
        self.flowId = [[NSString ndStringWithoutNil:[rDic objectForKey:@"flowId"]] integerValue];
        self.processId = [[NSString ndStringWithoutNil:[rDic objectForKey:@"processId"]] integerValue];
        self.campaignExpDate = [NSString ndStringWithoutNil:[rDic objectForKey:@"campaignExpDate"]];
        self.nudgesId = [[NSString ndStringWithoutNil:[rDic objectForKey:@"nudgesId"]] integerValue];
        self.nudgesName = [NSString ndStringWithoutNil:[rDic objectForKey:@"nudgesName"]];
        self.remainTimes = [[NSString ndStringWithoutNil:[rDic objectForKey:@"remainTimes"]] integerValue];
        self.channelCode = [NSString ndStringWithoutNil:[rDic objectForKey:@"channelCode"]];
        self.adviceCode = [NSString ndStringWithoutNil:[rDic objectForKey:@"adviceCode"]];
        NSInteger type = [[NSString ndStringWithoutNil:[rDic objectForKey:@"nudgesType"]] integerValue];
        if (type > 11 || type < 1) {
            type = KNudgesType_None;
        } else {
            self.nudgesType = type;
        }
        self.pageName = [NSString ndStringWithoutNil:[rDic objectForKey:@"pageName"]];
        self.findIndex = [NSString ndStringWithoutNil:[rDic objectForKey:@"findIndex"]];
        // ownProp
        NSString *ownProp = [rDic objectForKey:@"ownProp"];
        if (!isEmptyString_Nd(ownProp)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:ownProp];
            OwnPropModel *model = [[OwnPropModel alloc] init];
            model.type = [[NSString ndStringWithoutNil:[dic objectForKey:@"style"]] integerValue];
            model.color = [NSString ndStringWithoutNil:[dic objectForKey:@"color"]];
            model.opacity = [[NSString ndStringWithoutNil:[dic objectForKey:@"opacity"]] integerValue];
            model.displayOption = [NSString ndStringWithoutNil:[dic objectForKey:@"displayOption"]];
            model.fontSize = [[NSString ndStringWithoutNil:[dic objectForKey:@"fontSize"]] integerValue];
            // nps
            model.npsType = [NSString ndStringWithoutNil:[dic objectForKey:@"npsType"]];
            LeftText *leftText = [[LeftText alloc] init];
            NSDictionary *dicLeft = [dic objectForKey:@"leftText"];
            if ([dicLeft allKeys] > 0) {
                leftText.color = [NSString ndStringWithoutNil:[dicLeft objectForKey:@"color"]];
                leftText.content = [NSString ndStringWithoutNil:[dicLeft objectForKey:@"content"]];
                model.leftText = leftText;
            }
            RightText *rightText = [[RightText alloc] init];
            NSDictionary *dicRight = [dic objectForKey:@"rightText"];
            if ([dicRight allKeys] > 0) {
                rightText.color = [NSString ndStringWithoutNil:[dicRight objectForKey:@"color"]];
                rightText.content = [NSString ndStringWithoutNil:[dicRight objectForKey:@"content"]];
                model.rightText = rightText;
            }
            ScaleColor *scaleColor = [[ScaleColor alloc] init];
            NSDictionary *dicScaleColor = [dic objectForKey:@"scaleColor"];
            if ([dicScaleColor allKeys] > 0) {
                scaleColor.selection = [NSString ndStringWithoutNil:[dicScaleColor objectForKey:@"selection"]];
                scaleColor.notSelection = [NSString ndStringWithoutNil:[dicScaleColor objectForKey:@"notSelection"]];
                model.scaleColor = scaleColor;
            }
            NpsColor *npsColor = [[NpsColor alloc] init];
            NSDictionary *dicNpsColor = [dic objectForKey:@"npsColor"];
            if ([dicNpsColor allKeys] > 0) {
                npsColor.selection = [NSString ndStringWithoutNil:[dicNpsColor objectForKey:@"selection"]];
                npsColor.notSelection = [NSString ndStringWithoutNil:[dicNpsColor objectForKey:@"notSelection"]];
                model.npsColor = npsColor;
            }
            // input area
            NSDictionary *dicInputArea = [dic objectForKey:@"inputArea"];
            if ([dicInputArea allKeys]>0) {
                model.enabled = [[NSString ndStringWithoutNil:[dicInputArea objectForKey:@"enabled"]] integerValue];
                // input
                NSDictionary *dicInput = [dicInputArea objectForKey:@"input"];
                if ([dicInput allKeys]>0) {
                    Input *inputModel = [[Input alloc] init];
                    inputModel.fontSize = [NSString ndStringWithoutNil:[dicInput objectForKey:@"fontSize"]];
                    inputModel.color = [NSString ndStringWithoutNil:[dicInput objectForKey:@"color"]];
                    NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[dicInput objectForKey:@"isBold"]]];
                    inputModel.isBold = isBold;
                    NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[dicInput objectForKey:@"isItalic"]]];
                    inputModel.isItalic = isItalic;
                    NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[dicInput objectForKey:@"hasDecoration"]]];
                    inputModel.hasDecoration = hasDecoration;
                    inputModel.style = [NSString ndStringWithoutNil:[dicInput objectForKey:@"style"]];
                    inputModel.rows = [[NSString ndStringWithoutNil:[dicInput objectForKey:@"rows"]] integerValue];
                    inputModel.maxLength = [[NSString ndStringWithoutNil:[dicInput objectForKey:@"maxLength"]] integerValue];
                    inputModel.format = [NSString ndStringWithoutNil:[dicInput objectForKey:@"format"]];
                    model.input = inputModel;
                }
                // hint
                NSDictionary *dicHint = [dicInputArea objectForKey:@"hint"];
                if ([dicHint allKeys]>0) {
                    Hint *hintModel = [[Hint alloc] init];
                    NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[dicHint objectForKey:@"isBold"]]];
                    hintModel.isBold = isBold;
                    NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[dicHint objectForKey:@"isItalic"]]];
                    hintModel.isItalic = isItalic;
                    NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[dicHint objectForKey:@"hasDecoration"]]];
                    hintModel.hasDecoration = hasDecoration;
                    hintModel.color = [NSString ndStringWithoutNil:[dicHint objectForKey:@"color"]];
                    hintModel.fontSize = [NSString ndStringWithoutNil:[dicHint objectForKey:@"fontSize"]];
                    hintModel.content = [NSString ndStringWithoutNil:[dicHint objectForKey:@"content"]];
                    model.hint = hintModel;
                }
            }
            // rateType
            NSString *rateType = [dic objectForKey:@"rateType"];
            if ([rateType isEqualToString:@"H"]) {
                model.rateType = KRateType_Heart;
            } else if ([rateType isEqualToString:@"T"]) {
                model.rateType = KRateType_Thumbs;
            } else {
                // 默认星星
                model.rateType = KRateType_Star;
            }
            NSDictionary *dicRate = [dic objectForKey:@"rateStyle"];
            if (dicRate.allKeys > 0) {
                RateStyle *rateStyleModel = [[RateStyle alloc] init];
                rateStyleModel.activeColor = [NSString ndStringWithoutNil:[dicRate objectForKey:@"activeColor"]];
                rateStyleModel.restColor = [NSString ndStringWithoutNil:[dicRate objectForKey:@"restColor"]];
                rateStyleModel.thumbsUpColor = [NSString ndStringWithoutNil:[dicRate objectForKey:@"thumbsUpColor"]];
                rateStyleModel.thumbsDownColor = [NSString ndStringWithoutNil:[dicRate objectForKey:@"thumbsDownColor"]];
                rateStyleModel.iconSize = [[NSString ndStringWithoutNil:[dicRate objectForKey:@"iconSize"]] integerValue];
                model.rateStyle = rateStyleModel;
            }
            
            // choice
            NSDictionary *titleDic = [dic objectForKey:@"title"];
            if (titleDic.allKeys > 0) {
                Title *title = [[Title alloc] init];
                title.fontFamily = [NSString ndStringWithoutNil:[titleDic objectForKey:@"fontFamily"]];
                title.fontSize = [[NSString ndStringWithoutNil:[titleDic objectForKey:@"fontSize"]] integerValue];
                NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[titleDic objectForKey:@"isBold"]]];
                title.isBold = isBold;
                NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"isItalic"]]];
                title.isItalic = isItalic;
                NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"hasDecoration"]]];
                title.hasDecoration = hasDecoration;
                title.content = [NSString ndStringWithoutNil:[titleDic objectForKey:@"content"]];
                model.title = title;
            }
            NSString *selectType = [dic objectForKey:@"selectType"];
            model.selectType = selectType;
            NSDictionary *textPropertiesDic = [dic objectForKey:@"textProperties"];
            if (textPropertiesDic.allKeys > 0) {
                TextProperties *textProperties = [TextProperties alloc];
                NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"isBold"]]];
                textProperties.isBold = isBold;
                NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"isItalic"]]];
                textProperties.isItalic = isItalic;
                NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"hasDecoration"]]];
                textProperties.hasDecoration = hasDecoration;
                textProperties.fontSize = [[NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"fontSize"]] integerValue];
                textProperties.fontFamily = [NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"fontFamily"]];
                textProperties.color = [NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"color"]];
                NSMutableArray *allOptions = [textPropertiesDic objectForKey:@"options"];
                textProperties.options = allOptions;
                model.textProperties = textProperties;
            }
            
            self.ownPropModel = model;
        }
        // Postion
        NSString *position = [rDic objectForKey:@"position"];
        if (!isEmptyString_Nd(position)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:position];
            PositionModel *model = [[PositionModel alloc] init];
            model.position = [[NSString ndStringWithoutNil:[dic objectForKey:@"position"]] integerValue];
            model.width = [[NSString ndStringWithoutNil:[dic objectForKey:@"width"]] integerValue];
            model.margin = [[NSString ndStringWithoutNil:[dic objectForKey:@"margin"]] integerValue];
            self.positionModel = model;
        }
        // appExtInfo
        NSString *appExtInfo = [rDic objectForKey:@"appExtInfo"];
        if (!isEmptyString_Nd(appExtInfo)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:appExtInfo];
            AppExtInfoModel *model = [[AppExtInfoModel alloc] init];
            model.parentClassName = [NSString ndStringWithoutNil:[dic objectForKey:@"parentClassName"]];
            model.itemPosition = [[NSString ndStringWithoutNil:[dic objectForKey:@"itemPosition"]] integerValue];
            model.isReuseView = [[NSString ndStringWithoutNil:[dic objectForKey:@"isReuseView"]] integerValue];
            model.reuseViewFindIndex = [NSString ndStringWithoutNil:[dic objectForKey:@"reuseViewFindIndex"]];
            model.accessibilityIdentifier = [NSString ndStringWithoutNil:[dic objectForKey:@"accessibilityIdentifier"]];
            self.appExtInfoModel = model;
        }
        // background
        NSString *background = [rDic objectForKey:@"background"];
        if (!isEmptyString_Nd(background)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:background];
            BackgroundModel *model = [[BackgroundModel alloc] init];
            // 是否设置背景色
            NSInteger flag = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enabled"]]];
            model.enabled = flag;
            model.type = [[NSString ndStringWithoutNil:[dic objectForKey:@"type"]] integerValue];
            model.backgroundColor = [NSString ndStringWithoutNil:[dic objectForKey:@"backgroundColor"]];
            model.opacity = [[NSString ndStringWithoutNil:[dic objectForKey:@"opacity"]] integerValue];
            model.gradientType = [[NSString ndStringWithoutNil:[dic objectForKey:@"gradientType"]] integerValue];
            model.gradientStartColor = [NSString ndStringWithoutNil:[dic objectForKey:@"gradientStartColor"]];
            model.gradientEndColor = [NSString ndStringWithoutNil:[dic objectForKey:@"gradientEndColor"]];
            model.imageType = [[NSString ndStringWithoutNil:[dic objectForKey:@"imageType"]] integerValue];
            model.imageUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"imageUrl"]];
            self.backgroundModel = model;
        }
        // border
        NSString *border = [rDic objectForKey:@"border"];
        if (!isEmptyString_Nd(border)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:border];
            BorderModel *model = [[BorderModel alloc] init];
            // 是否开启配置
            NSInteger flag = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enabled"]]];
            model.enabled = flag;
            model.borderWidth = [[NSString ndStringWithoutNil:[dic objectForKey:@"borderWidth"]] integerValue];
            model.borderStyle = [[NSString ndStringWithoutNil:[dic objectForKey:@"borderStyle"]] integerValue];
            model.borderColor = [NSString ndStringWithoutNil:[dic objectForKey:@"borderColor"]];
            model.radiusConfigType = [[NSString ndStringWithoutNil:[dic objectForKey:@"radiusConfigType"]] integerValue];
            model.all = [NSString ndStringWithoutNil:[dic objectForKey:@"all"]];
            model.topLeft = [[NSString ndStringWithoutNil:[dic objectForKey:@"topLeft"]] integerValue];
            model.topRight = [[NSString ndStringWithoutNil:[dic objectForKey:@"topRight"]] integerValue];
            model.bottomRight = [[NSString ndStringWithoutNil:[dic objectForKey:@"bottomRight"]] integerValue];
            model.bottomLeft = [[NSString ndStringWithoutNil:[dic objectForKey:@"bottomLeft"]] integerValue];
            self.borderModel = model;
        }
        // backdrop
        NSString *backdrop = [rDic objectForKey:@"backdrop"];
        if (!isEmptyString_Nd(backdrop)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:backdrop];
            BackdropModel *model = [[BackdropModel alloc] init];
            // 是否开启配置
            NSInteger flag = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enabled"]]];
            model.enabled = flag;
            model.type = [[NSString ndStringWithoutNil:[dic objectForKey:@"type"]] integerValue];
            model.backgroundColor = [NSString ndStringWithoutNil:[dic objectForKey:@"backgroundColor"]];
            model.opacity = [[NSString ndStringWithoutNil:[dic objectForKey:@"opacity"]] integerValue];
            model.gradientType = [[NSString ndStringWithoutNil:[dic objectForKey:@"gradientType"]] integerValue];
            model.gradientStartColor = [NSString ndStringWithoutNil:[dic objectForKey:@"gradientStartColor"]];
            model.gradientEndColor = [NSString ndStringWithoutNil:[dic objectForKey:@"gradientEndColor"]];
            model.imageType = [[NSString ndStringWithoutNil:[dic objectForKey:@"imageType"]] integerValue];
            model.imageUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"imageUrl"]];
            self.backdropModel = model;
        }
        // dismiss
        self.dismiss = [NSString ndStringWithoutNil:[rDic objectForKey:@"dismiss"]];
        // title
        NSString *title = [rDic objectForKey:@"title"];
        if (!isEmptyString_Nd(title)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:title];
            TitleModel *model = [[TitleModel alloc] init];
            // 是否开启配置
            NSInteger flag = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enable"]]];
            model.enable = flag;
            model.fontFamily = [NSString ndStringWithoutNil:[dic objectForKey:@"fontFamily"]];
            model.fontSize = [[NSString ndStringWithoutNil:[dic objectForKey:@"fontSize"]] integerValue];
            NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"isBold"]]];
            model.isBold = isBold;
            NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"isItalic"]]];
            model.isItalic = isItalic;
            NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"hasDecoration"]]];
            model.hasDecoration = hasDecoration;
            model.color = [NSString ndStringWithoutNil:[dic objectForKey:@"color"]];
            model.textAlign = [NSString ndStringWithoutNil:[dic objectForKey:@"textAlign"]];
            model.content = [NSString ndStringWithoutNil:[dic objectForKey:@"content"]];
            self.titleModel = model;
        }
        // body
        NSString *body = [rDic objectForKey:@"body"];
        if (!isEmptyString_Nd(body)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:body];
            BodyModel *model = [[BodyModel alloc] init];
            NSInteger flag = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enable"]]];
            model.enable = flag;
            model.fontFamily = [NSString ndStringWithoutNil:[dic objectForKey:@"fontFamily"]];
            model.fontSize = [[NSString ndStringWithoutNil:[dic objectForKey:@"fontSize"]] integerValue];
            NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"isBold"]]];
            model.isBold = isBold;
            NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"isItalic"]]];
            model.isItalic = isItalic;
            NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"hasDecoration"]]];
            model.hasDecoration = hasDecoration;
            model.color = [NSString ndStringWithoutNil:[dic objectForKey:@"color"]];
            model.textAlign = [NSString ndStringWithoutNil:[dic objectForKey:@"textAlign"]];
            model.content = [NSString ndStringWithoutNil:[dic objectForKey:@"content"]];
            self.bodyModel = model;
        }
        // image
        NSString *image = [rDic objectForKey:@"image"];
        if (!isEmptyString_Nd(image)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:image];
            ImageModel *model = [[ImageModel alloc] init];
            model.imageUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"imageUrl"]];
            NSString *position = [NSString ndStringWithoutNil:[dic objectForKey:@"position"]];
            if ([position isEqualToString:@"top"]) {
                model.position = KImagePositionType_Top;
            }
            if ([position isEqualToString:@"bottom"]) {
                model.position = KImagePositionType_Bottom;
            }
            if ([position isEqualToString:@"left"]) {
                model.position = KImagePositionType_Left;
            }
            if ([position isEqualToString:@"right"]) {
                model.position = KImagePositionType_Right;
            }
            NSInteger isAutoWidth = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"autoWidth"]]];
            model.autoWidth = isAutoWidth;
            model.width = [[NSString ndStringWithoutNil:[dic objectForKey:@"width"]] floatValue];
            model.opacity = [[NSString ndStringWithoutNil:[dic objectForKey:@"opacity"]] floatValue];
            NSInteger isPaddingSpace = [[dic objectForKey:@"paddingSpace"] integerValue];
            model.paddingSpace = isPaddingSpace;
            NSInteger isAllAides = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"allAides"]]];
            model.allAides = isAllAides;
            model.paddingLeft = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingLeft"]] integerValue];
            model.paddingTop = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingTop"]] integerValue];
            model.paddingRight = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingRight"]] integerValue];
            model.paddingBottom = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingBottom"]] integerValue];
            self.imageModel = model;
        }
        // video
        NSString *video = [rDic objectForKey:@"video"];
        if (!isEmptyString_Nd(video)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:video];
            VideoModel *model = [[VideoModel alloc] init];
            model.coverImageUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"coverImageUrl"]];
            model.videoUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"videoUrl"]];
            model.width = [[NSString ndStringWithoutNil:[dic objectForKey:@"width"]] integerValue];
            NSInteger paddingSpace = [[dic objectForKey:@"paddingSpace"] integerValue];
            model.paddingSpace = paddingSpace;
            NSInteger allSides = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"allSides"]]];
            model.allSides = allSides;
            model.paddingLeft = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingLeft"]] integerValue];
            model.paddingTop = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingTop"]] integerValue];
            model.paddingRight = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingRight"]] integerValue];
            model.paddingBottom = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingBottom"]] integerValue];
            self.video = model;
        }
        // button
        NSString *button = [rDic objectForKey:@"buttons"];
        if (!isEmptyString_Nd(button)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:button];
            ButtonsModel *model = [[ButtonsModel alloc] init];
            // layout
            NSString *layout = [dic objectForKey:@"layout"];
            if (!isEmptyString_Nd(layout)) {
                NSDictionary *layoutDic = [NdHJHandelJson dictionaryWithJsonString:layout];
                Layout *layoutModel = [[Layout alloc] init];
                layoutModel.type = [NSString ndStringWithoutNil:[layoutDic objectForKey:@"type"]];
                layoutModel.align = [NSString ndStringWithoutNil:[layoutDic objectForKey:@"align"]];
                model.layout = layoutModel;
            }
            // buttonList
            NSString *buttons = [dic objectForKey:@"buttonList"];
            if (!isEmptyString_Nd(buttons)) {
                NSMutableArray *buttonList = [[NSMutableArray alloc] init];
                NSArray *buttonsObjList = [buttons JSONValue];
                for (NSDictionary *dic in buttonsObjList) {
                    ButtonItem *item = [[ButtonItem alloc] init];
                    // text
                    NSDictionary *textDic = [dic objectForKey:@"text"];
                    HJText *textModel = [[HJText alloc] init];
                    textModel.fontFamily = [NSString ndStringWithoutNil:[textDic objectForKey:@"fontFamily"]];
                    textModel.fontSize = [[NSString ndStringWithoutNil:[textDic objectForKey:@"fontSize"]] integerValue];
                    NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[textDic objectForKey:@"isBold"]]];
                    textModel.isBold = isBold;
                    NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[textDic objectForKey:@"isItalic"]]];
                    textModel.isItalic = isItalic;
                    NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[textDic objectForKey:@"hasDecoration"]]];
                    textModel.hasDecoration = hasDecoration;
                    textModel.color = [NSString ndStringWithoutNil:[textDic objectForKey:@"color"]];
                    textModel.textAlign = [NSString ndStringWithoutNil:[textDic objectForKey:@"textAlign"]];
                    textModel.content = [NSString ndStringWithoutNil:[textDic objectForKey:@"content"]];
                    item.text = textModel;
                    // action
                    NSDictionary *actionDic = [dic objectForKey:@"action"];
                    ActionModel *actionModel = [[ActionModel alloc] init];
                    actionModel.type = [[NSString ndStringWithoutNil:[actionDic objectForKey:@"type"]] integerValue];
                    actionModel.url = [NSString ndStringWithoutNil:[actionDic objectForKey:@"url"]];
                    actionModel.urlJumpType = [[NSString ndStringWithoutNil:[actionDic objectForKey:@"urlJumpType"]] integerValue];
                    actionModel.invokeAction = [NSString ndStringWithoutNil:[actionDic objectForKey:@"invokeAction"]];
                    item.action = actionModel;
                    // buttonStyle
                    NSDictionary *buttonStyleDic = [dic objectForKey:@"buttonStyle"];
                    ButtonStyle *buttonStyleModel = [[ButtonStyle alloc] init];
                    buttonStyleModel.fillType = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"fillType"]] integerValue];
                    buttonStyleModel.fillColor = [NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"fillColor"]];
                    buttonStyleModel.borderWidth = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"borderWidth"]] integerValue];
                    buttonStyleModel.borderStyle = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"borderStyle"]] integerValue];
                    buttonStyleModel.borderColor = [NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"borderColor"]];
                    buttonStyleModel.radiusConfigType = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"radiusConfigType"]] integerValue];
                    buttonStyleModel.all = [NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"all"]];
                    buttonStyleModel.topLeft = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"topLeft"]] integerValue];
                    buttonStyleModel.topRight = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"topRight"]] integerValue];
                    buttonStyleModel.bottomRight = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"bottomRight"]] integerValue];
                    buttonStyleModel.bottomLeft = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"bottomLeft"]] integerValue];
                    buttonStyleModel.icon = [NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"icon"]];
                    item.buttonStyle = buttonStyleModel;

                    [buttonList addObject:item];
                }
                model.buttonList = buttonList;
            }
        }
        // dismissButton
        NSString *dismissButton = [rDic objectForKey:@"dismissButton"];
        if (!isEmptyString_Nd(dismissButton)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:dismissButton];
            DismissButtonModel *model = [[DismissButtonModel alloc] init];
            model.type = [[NSString ndStringWithoutNil:[dic objectForKey:@"type"]] integerValue];
            model.filledColor = [NSString ndStringWithoutNil:[dic objectForKey:@"filledColor"]];
            
            //iconStyle
            NSString *iconStyle = [dic objectForKey:@"iconStyle"];
            if (!isEmptyString_Nd(iconStyle)) {
                NSDictionary *iconStyleDic = [NdHJHandelJson dictionaryWithJsonString:iconStyle];
                IconStyle *iconStyleModel = [[IconStyle alloc] init];
                iconStyleModel.iconColor = [NSString ndStringWithoutNil:[iconStyleDic objectForKey:@"iconColor"]];
                iconStyleModel.iconSize = [[NSString ndStringWithoutNil:[iconStyleDic objectForKey:@"iconSize"]] integerValue];
                model.iconStyle = iconStyleModel;
            }
            // borderStyle
            NSString *borderStyle = [dic objectForKey:@"borderStyle"];
            if (!isEmptyString_Nd(borderStyle)) {
                NSDictionary *borderStyleDic = [NdHJHandelJson dictionaryWithJsonString:borderStyle];
                BorderStyle *borderStyleModel = [[BorderStyle alloc] init];
                borderStyleModel.borderColor = [NSString ndStringWithoutNil:[borderStyleDic objectForKey:@"borderColor"]];
                borderStyleModel.radiusConfigType = [[NSString ndStringWithoutNil:[borderStyleDic objectForKey:@"radiusConfigType"]] integerValue];
                borderStyleModel.all = [NSString ndStringWithoutNil:[borderStyleDic objectForKey:@"all"]];
                borderStyleModel.topLeft = [[NSString ndStringWithoutNil:[borderStyleDic objectForKey:@"topLeft"]] integerValue];
                borderStyleModel.topRight = [[NSString ndStringWithoutNil:[borderStyleDic objectForKey:@"topRight"]] integerValue];
                borderStyleModel.bottomRight = [[NSString ndStringWithoutNil:[borderStyleDic objectForKey:@"bottomRight"]] integerValue];
                borderStyleModel.bottomLeft = [[NSString ndStringWithoutNil:[borderStyleDic objectForKey:@"bottomLeft"]] integerValue];
                model.borderStyle = borderStyleModel;
            }
            // action
            NSString *action = [dic objectForKey:@"action"];
            if (!isEmptyString_Nd(action)) {
                NSDictionary *actionDic = [NdHJHandelJson dictionaryWithJsonString:action];
                ActionModel *actionModel = [[ActionModel alloc] init];
                actionModel.type = [[NSString ndStringWithoutNil:[actionDic objectForKey:@"type"]] integerValue];
                actionModel.url = [NSString ndStringWithoutNil:[actionDic objectForKey:@"url"]];
                actionModel.urlJumpType = [[NSString ndStringWithoutNil:[actionDic objectForKey:@"urlJumpType"]] integerValue];
                model.action = actionModel;
            }
            
            self.dismissButtonModel = model;
        }
    }
    return self;
}

#pragma mark -- initwithMsgModel
- (id)initWithMsgModel:(NudgesModel *)model {
    self = [super init];
    if (self) {
        self.contactId = model.contactId;
        self.campaignId = model.campaignId;
        self.flowId = model.flowId;
        self.processId = model.processId;
        self.campaignExpDate = [NSString ndStringWithoutNil:model.campaignExpDate];
        self.nudgesId = model.nudgesId;
        self.nudgesName = [NSString ndStringWithoutNil:model.nudgesName];
        self.remainTimes = self.remainTimes;
        self.channelCode = [NSString ndStringWithoutNil:model.channelCode];
        self.adviceCode = [NSString ndStringWithoutNil:model.adviceCode];
        NSInteger type = model.nudgesType;
        if (type > 11 || type < 1) {
            type = KNudgesType_None;
        } else {
            self.nudgesType = type;
        }
        self.pageName = [NSString ndStringWithoutNil:model.pageName];
        self.findIndex = [NSString ndStringWithoutNil:model.findIndex];
        // ownProp
        NSString *ownProp = model.ownProp;
        if (!isEmptyString_Nd(ownProp)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:ownProp];
            OwnPropModel *model = [[OwnPropModel alloc] init];
            model.type = [[NSString ndStringWithoutNil:[dic objectForKey:@"style"]] integerValue];
            model.color = [NSString ndStringWithoutNil:[dic objectForKey:@"color"]];
            model.opacity = [[NSString ndStringWithoutNil:[dic objectForKey:@"opacity"]] integerValue];
            model.displayOption = [NSString ndStringWithoutNil:[dic objectForKey:@"displayOption"]];
            model.fontSize = [[NSString ndStringWithoutNil:[dic objectForKey:@"fontSize"]] integerValue];
            // nps
            model.npsType = [NSString ndStringWithoutNil:[dic objectForKey:@"npsType"]];
            LeftText *leftText = [[LeftText alloc] init];
            NSDictionary *dicLeft = [dic objectForKey:@"leftText"];
            if ([dicLeft allKeys] > 0) {
                leftText.color = [NSString ndStringWithoutNil:[dicLeft objectForKey:@"color"]];
                leftText.content = [NSString ndStringWithoutNil:[dicLeft objectForKey:@"content"]];
                model.leftText = leftText;
            }
            RightText *rightText = [[RightText alloc] init];
            NSDictionary *dicRight = [dic objectForKey:@"rightText"];
            if ([dicRight allKeys] > 0) {
                rightText.color = [NSString ndStringWithoutNil:[dicRight objectForKey:@"color"]];
                rightText.content = [NSString ndStringWithoutNil:[dicRight objectForKey:@"content"]];
                model.rightText = rightText;
            }
            ScaleColor *scaleColor = [[ScaleColor alloc] init];
            NSDictionary *dicScaleColor = [dic objectForKey:@"scaleColor"];
            if ([dicScaleColor allKeys] > 0) {
                scaleColor.selection = [NSString ndStringWithoutNil:[dicScaleColor objectForKey:@"selection"]];
                scaleColor.notSelection = [NSString ndStringWithoutNil:[dicScaleColor objectForKey:@"notSelection"]];
                model.scaleColor = scaleColor;
            }
            NpsColor *npsColor = [[NpsColor alloc] init];
            NSDictionary *dicNpsColor = [dic objectForKey:@"npsColor"];
            if ([dicNpsColor allKeys] > 0) {
                npsColor.selection = [NSString ndStringWithoutNil:[dicNpsColor objectForKey:@"selection"]];
                npsColor.notSelection = [NSString ndStringWithoutNil:[dicNpsColor objectForKey:@"notSelection"]];
                model.npsColor = npsColor;
            }
            // input area
            NSDictionary *dicInputArea = [dic objectForKey:@"inputArea"];
            if ([dicInputArea allKeys]>0) {
                model.enabled = [self convertBoolVal:[NSString ndStringWithoutNil:[dicInputArea objectForKey:@"enabled"]]];
                // input
                NSDictionary *dicInput = [dicInputArea objectForKey:@"input"];
                if ([dicInput allKeys]>0) {
                    Input *inputModel = [[Input alloc] init];
                    inputModel.fontSize = [NSString ndStringWithoutNil:[dicInput objectForKey:@"fontSize"]];
                    inputModel.color = [NSString ndStringWithoutNil:[dicInput objectForKey:@"color"]];
                    NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[dicInput objectForKey:@"isBold"]]];
                    inputModel.isBold = isBold;
                    NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[dicInput objectForKey:@"isItalic"]]];
                    inputModel.isItalic = isItalic;
                    NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[dicInput objectForKey:@"hasDecoration"]]];
                    inputModel.hasDecoration = hasDecoration;
                    inputModel.style = [NSString ndStringWithoutNil:[dicInput objectForKey:@"style"]];
                    inputModel.rows = [[NSString ndStringWithoutNil:[dicInput objectForKey:@"rows"]] integerValue];
                    inputModel.maxLength = [[NSString ndStringWithoutNil:[dicInput objectForKey:@"maxLength"]] integerValue];
                    inputModel.format = [NSString ndStringWithoutNil:[dicInput objectForKey:@"format"]];
                    model.input = inputModel;
                }
                // hint
                NSDictionary *dicHint = [dicInputArea objectForKey:@"hint"];
                if ([dicHint allKeys]>0) {
                    Hint *hintModel = [[Hint alloc] init];
                    NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[dicHint objectForKey:@"isBold"]]];
                    hintModel.isBold = isBold;
                    NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[dicHint objectForKey:@"isItalic"]]];
                    hintModel.isItalic = isItalic;
                    NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[dicHint objectForKey:@"hasDecoration"]]];
                    hintModel.hasDecoration = hasDecoration;
                    hintModel.color = [NSString ndStringWithoutNil:[dicHint objectForKey:@"color"]];
                    hintModel.fontSize = [NSString ndStringWithoutNil:[dicHint objectForKey:@"fontSize"]];
                    hintModel.content = [NSString ndStringWithoutNil:[dicHint objectForKey:@"content"]];
                    model.hint = hintModel;
                }
            }
            
            // rateType
            NSString *rateType = [dic objectForKey:@"rateType"];
            if ([rateType isEqualToString:@"H"]) {
                model.rateType = KRateType_Heart;
            } else if ([rateType isEqualToString:@"T"]) {
                model.rateType = KRateType_Thumbs;
            } else {
                // 默认星星
                model.rateType = KRateType_Star;
            }
            NSDictionary *dicRate = [dic objectForKey:@"rateStyle"];
            if (dicRate.allKeys > 0) {
                RateStyle *rateStyleModel = [[RateStyle alloc] init];
                rateStyleModel.activeColor = [NSString ndStringWithoutNil:[dicRate objectForKey:@"activeColor"]];
                rateStyleModel.restColor = [NSString ndStringWithoutNil:[dicRate objectForKey:@"restColor"]];
                rateStyleModel.thumbsUpColor = [NSString ndStringWithoutNil:[dicRate objectForKey:@"thumbsUpColor"]];
                rateStyleModel.thumbsDownColor = [NSString ndStringWithoutNil:[dicRate objectForKey:@"thumbsDownColor"]];
                rateStyleModel.iconSize = [[NSString ndStringWithoutNil:[dicRate objectForKey:@"iconSize"]] integerValue];
                model.rateStyle = rateStyleModel;
            }
            
            // choice
            NSDictionary *titleDic = [dic objectForKey:@"title"];
            if (titleDic.allKeys > 0) {
                Title *title = [[Title alloc] init];
                title.color = [NSString ndStringWithoutNil:[titleDic objectForKey:@"color"]];
                title.fontFamily = [NSString ndStringWithoutNil:[titleDic objectForKey:@"fontFamily"]];
                title.fontSize = [[NSString ndStringWithoutNil:[titleDic objectForKey:@"fontSize"]] integerValue];
                NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[titleDic objectForKey:@"isBold"]]];
                title.isBold = isBold;
                NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[titleDic objectForKey:@"isItalic"]]];
                title.isItalic = isItalic;
                NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[titleDic objectForKey:@"hasDecoration"]]];
                title.hasDecoration = hasDecoration;
                title.content = [NSString ndStringWithoutNil:[titleDic objectForKey:@"content"]];
                model.title = title;
            }
            NSString *selectType = [dic objectForKey:@"selectType"];
            model.selectType = selectType;
            NSDictionary *textPropertiesDic = [dic objectForKey:@"textProperties"];
            if (textPropertiesDic.allKeys > 0) {
                TextProperties *textProperties = [TextProperties alloc];
                NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"isBold"]]];
                textProperties.isBold = isBold;
                NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"isItalic"]]];
                textProperties.isItalic = isItalic;
                NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"hasDecoration"]]];
                textProperties.hasDecoration = hasDecoration;
                textProperties.fontSize = [[NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"fontSize"]] integerValue];
                textProperties.fontFamily = [NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"fontFamily"]];
                textProperties.color = [NSString ndStringWithoutNil:[textPropertiesDic objectForKey:@"color"]];
                NSMutableArray *allOptions = [textPropertiesDic objectForKey:@"options"];
                textProperties.options = allOptions;
                model.textProperties = textProperties;
            }
            self.ownPropModel = model;
        }
        // Postion
        NSString *position = model.position;
        if (!isEmptyString_Nd(position)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:position];
            PositionModel *model = [[PositionModel alloc] init];
            model.position = [[NSString ndStringWithoutNil:[dic objectForKey:@"position"]] integerValue];
            model.width = [[NSString ndStringWithoutNil:[dic objectForKey:@"width"]] integerValue];
            model.margin = [[NSString ndStringWithoutNil:[dic objectForKey:@"margin"]] integerValue];
            self.positionModel = model;
        }
        // appExtInfo
        NSString *appExtInfo = model.appExtInfo;
        if (!isEmptyString_Nd(appExtInfo)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:appExtInfo];
            AppExtInfoModel *model = [[AppExtInfoModel alloc] init];
            model.parentClassName = [NSString ndStringWithoutNil:[dic objectForKey:@"parentClassName"]];
            model.itemPosition = [[NSString ndStringWithoutNil:[dic objectForKey:@"itemPosition"]] integerValue];
            model.isReuseView = [[NSString ndStringWithoutNil:[dic objectForKey:@"isReuseView"]] integerValue];
            model.reuseViewFindIndex = [NSString ndStringWithoutNil:[dic objectForKey:@"reuseViewFindIndex"]];
            model.accessibilityIdentifier = [NSString ndStringWithoutNil:[dic objectForKey:@"accessibilityIdentifier"]];
			model.accessibilityLabel =  [NSString ndStringWithoutNil:[dic objectForKey:@"accessibilityLabel"]];
			
            self.appExtInfoModel = model;
        }
        // background
        NSString *background = model.background;
        if (!isEmptyString_Nd(background)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:background];
            BackgroundModel *model = [[BackgroundModel alloc] init];
            NSInteger isEnabled = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enabled"]]];
            model.enabled = isEnabled;
            model.type = [[NSString ndStringWithoutNil:[dic objectForKey:@"type"]] integerValue];
            model.backgroundColor = [NSString ndStringWithoutNil:[dic objectForKey:@"backgroundColor"]];
            model.opacity = [[NSString ndStringWithoutNil:[dic objectForKey:@"opacity"]] integerValue];
            model.gradientType = [[NSString ndStringWithoutNil:[dic objectForKey:@"gradientType"]] integerValue];
            model.gradientStartColor = [NSString ndStringWithoutNil:[dic objectForKey:@"gradientStartColor"]];
            model.gradientEndColor = [NSString ndStringWithoutNil:[dic objectForKey:@"gradientEndColor"]];
            model.imageType = [[NSString ndStringWithoutNil:[dic objectForKey:@"imageType"]] integerValue];
            model.imageUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"imageUrl"]];
            self.backgroundModel = model;
        }
        // border
        NSString *border = model.border;
        if (!isEmptyString_Nd(border)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:border];
            BorderModel *model = [[BorderModel alloc] init];
            NSInteger isEnabled = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enabled"]]];
            model.enabled = isEnabled;
            model.borderWidth = [[NSString ndStringWithoutNil:[dic objectForKey:@"borderWidth"]] integerValue];
            model.borderStyle = [[NSString ndStringWithoutNil:[dic objectForKey:@"borderStyle"]] integerValue];
            model.borderColor = [NSString ndStringWithoutNil:[dic objectForKey:@"borderColor"]];
            model.radiusConfigType = [[NSString ndStringWithoutNil:[dic objectForKey:@"radiusConfigType"]] integerValue];
            model.all = [NSString ndStringWithoutNil:[dic objectForKey:@"all"]];
            model.topLeft = [[NSString ndStringWithoutNil:[dic objectForKey:@"topLeft"]] integerValue];
            model.topRight = [[NSString ndStringWithoutNil:[dic objectForKey:@"topRight"]] integerValue];
            model.bottomRight = [[NSString ndStringWithoutNil:[dic objectForKey:@"bottomRight"]] integerValue];
            model.bottomLeft = [[NSString ndStringWithoutNil:[dic objectForKey:@"bottomLeft"]] integerValue];
            self.borderModel = model;
        }
        // backdrop
        NSString *backdrop = model.backdrop;
        if (!isEmptyString_Nd(backdrop)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:backdrop];
            BackdropModel *model = [[BackdropModel alloc] init];
            NSInteger isEnabled = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enabled"]]];
            model.enabled = isEnabled;
            model.type = [[NSString ndStringWithoutNil:[dic objectForKey:@"type"]] integerValue];
            model.backgroundColor = [NSString ndStringWithoutNil:[dic objectForKey:@"backgroundColor"]];
            model.opacity = [[NSString ndStringWithoutNil:[dic objectForKey:@"opacity"]] integerValue];
            model.gradientType = [[NSString ndStringWithoutNil:[dic objectForKey:@"gradientType"]] integerValue];
            model.gradientStartColor = [NSString ndStringWithoutNil:[dic objectForKey:@"gradientStartColor"]];
            model.gradientEndColor = [NSString ndStringWithoutNil:[dic objectForKey:@"gradientEndColor"]];
            model.imageType = [[NSString ndStringWithoutNil:[dic objectForKey:@"imageType"]] integerValue];
            model.imageUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"imageUrl"]];
            self.backdropModel = model;
        }
        // dismiss
        self.dismiss = isEmptyString_Nd(model.dismiss) ? @"": model.dismiss;
        // title
        NSString *title = model.title;
        if (!isEmptyString_Nd(title)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:title];
            TitleModel *model = [[TitleModel alloc] init];
            NSInteger isEnable = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enable"]]];
            model.enable = isEnable;
            model.fontFamily = [NSString ndStringWithoutNil:[dic objectForKey:@"fontFamily"]];
            model.fontSize = [[NSString ndStringWithoutNil:[dic objectForKey:@"fontSize"]] integerValue];
            NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"isBold"]]];
            model.isBold = isBold;
            NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"isItalic"]]];
            model.isItalic = isItalic;
            NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"hasDecoration"]]];
            model.hasDecoration = hasDecoration;
            model.color = [NSString ndStringWithoutNil:[dic objectForKey:@"color"]];
            model.textAlign = [NSString ndStringWithoutNil:[dic objectForKey:@"textAlign"]];
            model.content = [NSString ndStringWithoutNil:[dic objectForKey:@"content"]];
            self.titleModel = model;
        }
        // body
        NSString *body = model.body;
        if (!isEmptyString_Nd(body)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:body];
            BodyModel *model = [[BodyModel alloc] init];
            NSInteger isEnable = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"enable"]]];
            model.enable = isEnable;
            model.fontFamily = [NSString ndStringWithoutNil:[dic objectForKey:@"fontFamily"]];
            model.fontSize = [[NSString ndStringWithoutNil:[dic objectForKey:@"fontSize"]] integerValue];
            NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"isBold"]]];
            model.isBold = isBold;
            NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"isItalic"]]];
            model.isItalic = isItalic;
            NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"hasDecoration"]]];
            model.hasDecoration = hasDecoration;
            model.color = [NSString ndStringWithoutNil:[dic objectForKey:@"color"]];
            model.textAlign = [NSString ndStringWithoutNil:[dic objectForKey:@"textAlign"]];
            model.content = [NSString ndStringWithoutNil:[dic objectForKey:@"content"]];
            self.bodyModel = model;
        }
        // image
        NSString *image = model.image;
        if (!isEmptyString_Nd(image)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:image];
            ImageModel *model = [[ImageModel alloc] init];
            model.imageUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"imageUrl"]];
            NSString *position = [NSString ndStringWithoutNil:[dic objectForKey:@"position"]];
            if ([position isEqualToString:@"top"]) {
                model.position = KImagePositionType_Top;
            }
            if ([position isEqualToString:@"bottom"]) {
                model.position = KImagePositionType_Bottom;
            }
            if ([position isEqualToString:@"left"]) {
                model.position = KImagePositionType_Left;
            }
            if ([position isEqualToString:@"right"]) {
                model.position = KImagePositionType_Right;
            }
            NSInteger isAutoWidth = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"autoWidth"]]];
            model.autoWidth = isAutoWidth;
            model.width = [[NSString ndStringWithoutNil:[dic objectForKey:@"width"]] floatValue];
            model.opacity = [[NSString ndStringWithoutNil:[dic objectForKey:@"opacity"]] floatValue];
//            NSInteger isPaddingSpace = [self convertBoolVal:[NSString ndStringWithoutNil:]];
            NSInteger isPaddingSpace = [[dic objectForKey:@"paddingSpace"] integerValue];
            model.paddingSpace = isPaddingSpace;
            NSInteger isAllAides = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"allAides"]]];
            model.allAides = isAllAides;
            model.paddingLeft = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingLeft"]] integerValue];
            model.paddingTop = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingTop"]] integerValue];
            model.paddingRight = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingRight"]] integerValue];
            model.paddingBottom = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingBottom"]] integerValue];
            // 计算图片的高度 和 宽度
            CGSize size = [UIImage getImageSizeWithURL:[NSURL URLWithString:model.imageUrl]];
            model.h_image = size.height;
            model.w_image = size.width;
            self.imageModel = model;
        }
        // video
        NSString *video = model.video;
        if (!isEmptyString_Nd(video)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:video];
            VideoModel *model = [[VideoModel alloc] init];
            model.coverImageUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"coverImageUrl"]];
            model.videoUrl = [NSString ndStringWithoutNil:[dic objectForKey:@"videoUrl"]];
            model.width = [[NSString ndStringWithoutNil:[dic objectForKey:@"width"]] integerValue];
            NSInteger paddingSpace = [[dic objectForKey:@"paddingSpace"] integerValue];
            model.paddingSpace = paddingSpace;
            NSInteger allSides = [self convertBoolVal:[NSString ndStringWithoutNil:[dic objectForKey:@"allSides"]]];
            model.allSides = allSides;
            model.paddingLeft = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingLeft"]] integerValue];
            model.paddingTop = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingTop"]] integerValue];
            model.paddingRight = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingRight"]] integerValue];
            model.paddingBottom = [[NSString ndStringWithoutNil:[dic objectForKey:@"paddingBottom"]] integerValue];
            // 计算封面图片的高度 和 宽度
            CGSize size = [UIImage getImageSizeWithURL:[NSURL URLWithString:model.coverImageUrl]];
            model.h_coverImage = size.height;
            model.w_coverImage = size.width;
            self.video = model;
        }
        // button
        NSString *button = model.buttons;
        if (!isEmptyString_Nd(button)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:button];
            ButtonsModel *model = [[ButtonsModel alloc] init];
            // layout
            NSDictionary *layout = [dic objectForKey:@"layout"];
            if ([layout allKeys] > 0) {
                Layout *layoutModel = [[Layout alloc] init];
                layoutModel.type = [NSString ndStringWithoutNil:[layout objectForKey:@"type"]];
                layoutModel.align = [NSString ndStringWithoutNil:[layout objectForKey:@"align"]];
                model.layout = layoutModel;
            }
            // buttonList
            NSArray *buttons = [dic objectForKey:@"buttonList"];
            if (!IsArrEmpty_Nd(buttons)) {
                NSMutableArray *buttonList = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in buttons) {
                    ButtonItem *item = [[ButtonItem alloc] init];
                    // text
                    NSDictionary *textDic = [dic objectForKey:@"text"];
                    HJText *textModel = [[HJText alloc] init];
                    textModel.fontFamily = [NSString ndStringWithoutNil:[textDic objectForKey:@"fontFamily"]];
                    textModel.fontSize = [[NSString ndStringWithoutNil:[textDic objectForKey:@"fontSize"]] integerValue];
                    NSInteger isBold = [self convertBoolVal:[NSString ndStringWithoutNil:[textDic objectForKey:@"isBold"]]];
                    textModel.isBold = isBold;
                    NSInteger isItalic = [self convertBoolVal:[NSString ndStringWithoutNil:[textDic objectForKey:@"isItalic"]]];
                    textModel.isItalic = isItalic;
                    NSInteger hasDecoration = [self convertBoolVal:[NSString ndStringWithoutNil:[textDic objectForKey:@"hasDecoration"]]];
                    textModel.hasDecoration = hasDecoration;
                    textModel.color = [NSString ndStringWithoutNil:[textDic objectForKey:@"color"]];
                    textModel.textAlign = [NSString ndStringWithoutNil:[textDic objectForKey:@"textAlign"]];
                    textModel.content = [NSString ndStringWithoutNil:[textDic objectForKey:@"content"]];
                    item.text = textModel;
                    // action
                    NSDictionary *actionDic = [dic objectForKey:@"action"];
                    ActionModel *actionModel = [[ActionModel alloc] init];
                    actionModel.type = [[NSString ndStringWithoutNil:[actionDic objectForKey:@"type"]] integerValue];
                    actionModel.url = [NSString ndStringWithoutNil:[actionDic objectForKey:@"url"]];
                    actionModel.urlJumpType = [[NSString ndStringWithoutNil:[actionDic objectForKey:@"urlJumpType"]] integerValue];
                    actionModel.invokeAction = [NSString ndStringWithoutNil:[actionDic objectForKey:@"invokeAction"]];
                    item.action = actionModel;
                    // buttonStyle
                    NSDictionary *buttonStyleDic = [dic objectForKey:@"buttonStyle"];
                    ButtonStyle *buttonStyleModel = [[ButtonStyle alloc] init];
                    buttonStyleModel.fillType = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"fillType"]] integerValue];
                    buttonStyleModel.fillColor = [NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"fillColor"]];
                    buttonStyleModel.borderWidth = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"borderWidth"]] integerValue];
                    buttonStyleModel.borderStyle = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"borderStyle"]] integerValue];
                    buttonStyleModel.borderColor = [NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"borderColor"]];
                    buttonStyleModel.radiusConfigType = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"radiusConfigType"]] integerValue];
                    buttonStyleModel.all = [NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"all"]];
                    buttonStyleModel.topLeft = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"topLeft"]] integerValue];
                    buttonStyleModel.topRight = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"topRight"]] integerValue];
                    buttonStyleModel.bottomRight = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"bottomRight"]] integerValue];
                    buttonStyleModel.bottomLeft = [[NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"bottomLeft"]] integerValue];
                    buttonStyleModel.icon = [NSString ndStringWithoutNil:[buttonStyleDic objectForKey:@"icon"]];
                    item.buttonStyle = buttonStyleModel;

                    [buttonList addObject:item];
                }
                model.buttonList = buttonList;
            }
            self.buttonsModel = model;
        }
        // dismissButton
        NSString *dismissButton = model.dismissButton;
        if (!isEmptyString_Nd(dismissButton)) {
            NSDictionary *dic = [NdHJHandelJson dictionaryWithJsonString:dismissButton];
            DismissButtonModel *model = [[DismissButtonModel alloc] init];
            model.type = [[NSString ndStringWithoutNil:[dic objectForKey:@"type"]] integerValue];
            model.filledColor = [NSString ndStringWithoutNil:[dic objectForKey:@"filledColor"]];
            
            //iconStyle
            NSDictionary *iconStyle = [dic objectForKey:@"iconStyle"];
            if ([iconStyle allKeys].count > 0) {
//                NSDictionary *iconStyleDic = [NdHJHandelJson dictionaryWithJsonString:iconStyle];
                IconStyle *iconStyleModel = [[IconStyle alloc] init];
                iconStyleModel.iconColor = [NSString ndStringWithoutNil:[iconStyle objectForKey:@"iconColor"]];
                iconStyleModel.iconSize = [[NSString ndStringWithoutNil:[iconStyle objectForKey:@"iconSize"]] integerValue];
                model.iconStyle = iconStyleModel;
            }
            // borderStyle
            NSDictionary *borderStyle = [dic objectForKey:@"borderStyle"];
            if ([borderStyle allKeys].count > 0) {
//                NSDictionary *borderStyleDic = [NdHJHandelJson dictionaryWithJsonString:borderStyle];
                BorderStyle *borderStyleModel = [[BorderStyle alloc] init];
                borderStyleModel.borderColor = [NSString ndStringWithoutNil:[borderStyle objectForKey:@"borderColor"]];
                borderStyleModel.radiusConfigType = [[NSString ndStringWithoutNil:[borderStyle objectForKey:@"radiusConfigType"]] integerValue];
                borderStyleModel.all = [NSString ndStringWithoutNil:[borderStyle objectForKey:@"all"]];
                borderStyleModel.topLeft = [[NSString ndStringWithoutNil:[borderStyle objectForKey:@"topLeft"]] integerValue];
                borderStyleModel.topRight = [[NSString ndStringWithoutNil:[borderStyle objectForKey:@"topRight"]] integerValue];
                borderStyleModel.bottomRight = [[NSString ndStringWithoutNil:[borderStyle objectForKey:@"bottomRight"]] integerValue];
                borderStyleModel.bottomLeft = [[NSString ndStringWithoutNil:[borderStyle objectForKey:@"bottomLeft"]] integerValue];
                model.borderStyle = borderStyleModel;
            }
            // action
            NSDictionary *action = [dic objectForKey:@"action"];
            if ([action allKeys].count > 0) {
//                NSDictionary *actionDic = [NdHJHandelJson dictionaryWithJsonString:action];
                ActionModel *actionModel = [[ActionModel alloc] init];
                actionModel.type = [[NSString ndStringWithoutNil:[action objectForKey:@"type"]] integerValue];
                actionModel.url = [NSString ndStringWithoutNil:[action objectForKey:@"url"]];
                actionModel.urlJumpType = [[NSString ndStringWithoutNil:[action objectForKey:@"urlJumpType"]] integerValue];
                model.action = actionModel;
            }
            self.dismissButtonModel = model;
        }
    }
    return self;
}


- (NSInteger)convertBoolVal:(NSString *)val {
    NSInteger reVal = 0;
    if ([val isEqualToString:@"true"]) {
        reVal = 1;
    }
    if ([val isEqualToString:@"false"]) {
        reVal = 0;
    }
    if ([val isEqualToString:@"N"]) {
        reVal = 0;
    }
    if ([val isEqualToString:@"Y"]) {
        reVal = 1;
    }
    return reVal;
}

@end
