
 *感谢[BARK](https://github.com/Finb/Bark) 的开源项目*

#### 什么是推送加密

推送加密是一种保护推送内容的方法，它使用自定义秘钥在发送和接收时对推送内容进行加密和解密。<br>这样，推送内容在传输过程中就不会被 Bark 服务器和苹果 APNs 服务器获取或泄露。

#### 设置自定义秘钥
1. 打开APP首页
2. 找到 “推送加密” ，点击加密设置
3. 选择加密算法，按要求填写KEY，点击完成保存自定义秘钥

#### 发送加密推送
要发送加密推送，首先需要把 Bark 请求参数转换成 json 格式的字符串，然后用之前设置的秘钥和相应的算法对字符串进行加密，最后把加密后的密文作为ciphertext参数发送到服务器。<br><br>

**示例：**

```python
import json
import base64
import requests
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad


def encrypt_AES_CBC(data, key, iv):
    cipher = AES.new(key, AES.MODE_CBC, iv)
    padded_data = pad(data.encode(), AES.block_size)
    encrypted_data = cipher.encrypt(padded_data)
    return encrypted_data


# JSON数据
json_string = json.dumps({"body": "test", "sound": "birdsong"})

# 必须32位
key = b"11111111111111111111111111111111"
# IV可以是随机生成的，但如果是随机的就需要放在 iv 参数里传递。
iv= b"1111211111112222"

# 加密
# 控制台将打印 "czVb6k4T3736wF8etTZWCmksWdBHoLIULYq+dKHe+jAK2wbZMzc2VKT3D1P+ZyPe"
encrypted_data = encrypt_AES_CBC(json_string, key, iv)

# 将加密后的数据转换为Base64编码
encrypted_base64 = base64.b64encode(encrypted_data).decode()

print("加密后的数据（Base64编码）：", encrypted_base64)

deviceKey = 'Ffy3BhTSHXN8FC6q7UhC5K'

res = requests.get(f"https://dev.twown.com/{deviceKey}/test",
                   params={"ciphertext": encrypted_base64, "iv": iv})

print(res.text)

```