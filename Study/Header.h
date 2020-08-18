最近学习SDWegImage源码时，对NSURLSession的didReceiveChallenge相关的delegate方法有些不明白如何使用，故学习了下官方文档，记录了一些笔记。

参考链接：

处理服务器身份验证质询 Handling an Authentication Challenge
验证服务器身份 Performing Manual Server Trust Authentication
NSURLSession有两种delegate回调，系统会优先调用task的回调，假如没有处理，会继续调用session的回调处理。

1.1 NSURLSessionDelegate
URLSession:didReceiveChallenge:completionHandler:

通过该方法处理会话层面(session-wide)的质询，如TLS(Transport Layer Security)验证。验证成功后对该session后续的请求都有效。

1.2 NSURLSessionTaskDelegate
URLSession:task:didReceiveChallenge:completionHandler:

处理特定任务的质询，如HTTP Basic authentication的用户名和密码验证。从不同session创建的task可能会发出各自的质询。

1.3 判断质询类型
delegate方法传入的NSURLAuthenticationChallenge对象，描述了本次质询的相关信息。其中的protectionSpace属性包含一个authenticationMethod状态指定了质询的类型。

通过传入NSURLSessionAuthChallengeDisposition到block来继续处理，可参考该链接AutoChallengeDisposition，一般以下几种类型：

提供一个证书(Credential)到服务器进行验证
取消本次请求
不处理，让系统按照默认方式处理
其中，通过用户名和密码可以创建NSURLCredential对象。

重点

回调block可以暂时保存起来，以供异步的情况使用(如界面弹窗输入密码等交互)，但后续必须执行该block才可以继续或取消本次请求。

1.4 失败处理
当凭证被服务器拒绝时，系统会再次回调delegate方法，会传入被拒绝的凭证(proposedCredential)，以及失败次数(previousFailureCount)。通过这些参数决定该如何继续下一步。

1.5 验证服务器身份
当使用https时，NSURLSessionDelegate会收到一个服务器身份验证(NSURLAuthenticationMethodServerTrust)，不像其他质询都是server要求验证app的身份，该质询是app可以验证服务器身份的时机。

1.5.1 处理该质询的情况
一般情况下，系统会自动验证服务器身份。在以下两种情况，我们可以拦截服务器身份验证回调：

当希望允许会被系统拒绝的服务器。比如app连接一个使用自签名证书的开发服务器，一般情况下这个自签名证书不在系统的信任证书库中。
当希望拒绝会被系统允许的凭证。比如你希望控制你的app只允许特定的一些key或证书，而不是允许任意一个合法的凭证。
1.5.2 如何处理
处理方式

判断当前质询是否为ServerTrust

判断质询的域名是否是希望手动评估的域名

1.6 例子
看一个实际的例子，代码来自SDWebImage中SDWebImageDownloaderOperation类：


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;  // 默认为由系统默认处理
    __block NSURLCredential *credential = nil;  // 证书
    
    // 判断是否为服务器身份验证质询
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // SD可以支持外部配置允许任意SSL证书，若没有设置该参数，则使用系统默认处理方式
        if (!(self.options & SDWebImageDownloaderAllowInvalidSSLCertificates)) {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        } else { // 直接信任该服务器
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    } else {
        // 未失败过
        if (challenge.previousFailureCount == 0) {
            if (self.credential) { // 使用外部配置的证书
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else { // 取消本次请求
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else { // 失败一次后就取消请求
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    
    // 调用回包
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

作者：wilsonhan
链接：https://www.jianshu.com/p/f66b858347ac
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
