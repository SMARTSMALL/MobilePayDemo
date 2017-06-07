

#import <Foundation/Foundation.h>
#import "WechatPayReadme.h"

@interface WechatPayManager : NSObject
{

}

//预支付网关url地址
@property (nonatomic,strong) NSString* payUrl;
//debug信息
@property (nonatomic,strong) NSMutableString *debugInfo;
@property (nonatomic,assign) NSInteger lastErrCode;//返回的错误码

//商户关键信息
@property (nonatomic,strong) NSString *appId,*mchId,*spKey, * notifyUrl ;//NOTIFY_URL;


//初始化函数
-(id)initWithAppID:(NSString*)appID
             mchID:(NSString*)mchID
             spKey:(NSString*)key
             notifyUrl:(NSString *)notifyUrl;

//获取当前的debug信息
-(NSString *) getDebugInfo;

//获取预支付订单信息（核心是一个prepayID）
- (NSMutableDictionary*)getPrepayWithOrderName:(NSString*)name
                                         price:(NSString*)price
                                         orderNo:(NSString*)orderNo;

@end
