 *感谢[BARK](https://github.com/Finb/Bark) 的开源项目*

## 发送推送 
1. 打开APP，复制测试URL 

<img src="../_media/example.jpg" width=365 />

2. 修改内容，请求这个URL。<br>
可以发 GET 或者 POST 请求 ，请求成功会立即收到推送 

## URL格式
URL由推送key、参数 title、参数 body 组成。有下面两种组合方式

```
/:key/:body 
/:key/:title/:body 
```

## 请求方式
##### GET 请求参数拼接在 URL 后面，例如：
```sh
curl https://push.twown.com/your_key/推送内容?group=分组&copy=复制
```
*手动拼接参数到URL上时，请注意URL编码问题，可以参考阅读[常见问题：URL编码](/faq?id=%e6%8e%a8%e9%80%81%e7%89%b9%e6%ae%8a%e5%ad%97%e7%ac%a6%e5%af%bc%e8%87%b4%e6%8e%a8%e9%80%81%e5%a4%b1%e8%b4%a5%ef%bc%8c%e6%af%94%e5%a6%82-%e6%8e%a8%e9%80%81%e5%86%85%e5%ae%b9%e5%8c%85%e5%90%ab%e9%93%be%e6%8e%a5%ef%bc%8c%e6%88%96%e6%8e%a8%e9%80%81%e5%bc%82%e5%b8%b8-%e6%af%94%e5%a6%82-%e5%8f%98%e6%88%90%e7%a9%ba%e6%a0%bc)*

##### POST 请求参数放在请求体中，例如：
```sh
curl -X POST https://push.twown.com/your_key \
     -d'body=推送内容&group=分组&copy=复制'
```
##### POST 请求支持JSON，例如：
```sh
curl -X "POST" "//https://push.twown.com/your_key" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "body": "Test newbear Server",
  "title": "Test Title",
  "badge": 1,
  "category": "myNotificationCategory",
  "sound": "minuet.caf",
  "icon": "https://day.app/assets/images/avatar.jpg",
  "group": "test",
  "url": "https://mritd.com"
}'
```

##### JSON 请求 key 可以放进请求体中,URL 路径须为 /push，例如
```sh
curl -X "POST" "https://push.twown.com/push" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "body": "Test newbear Server",
  "title": "Test Title",
  "device_key": "your_key"
}'
```

## 请求参数
支持的参数列表，具体效果可在APP内预览。

| 参数 | 说明 |
| ----- | ----------- |
| title | 推送标题 |
| body | 推送内容 |
| level | 推送中断级别。 <br>active：默认值，系统会立即亮屏显示通知<br>timeSensitive：时效性通知，可在专注状态下显示通知。<br>passive：仅将通知添加到通知列表，不会亮屏提醒。 |
| badge | 推送角标，可以是任意数字 |
| autoCopy | iOS14.5以下自动复制推送内容，iOS14.5以上需手动长按推送或下拉推送 |
| copy | 复制推送时，指定复制的内容，不传此参数将复制整个推送内容。 |
| sound | 可以为推送设置不同的铃声 |
| icon | 为推送设置自定义图标，设置的图标将替换默认Bark图标。<br>图标会自动缓存在本机，相同的图标 URL 仅下载一次。 |
| group | 对消息进行分组，推送将按group分组显示在通知中心中。<br>也可在历史消息列表中选择查看不同的群组。 |
| isArchive | 传 1 保存推送，传其他的不保存推送，不传按APP内设置来决定是否保存。 |
| url | 点击推送时，跳转的URL ，支持URL Scheme 和 Universal Link |
| image | 一张图片的连接, 可以在通知里直接查看 ｜
| active | 与ios捷径完成连接运行自动化 |