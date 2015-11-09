# iBeacon例子

使用了KrBeacon 封装，较为简单的调用 ibeacon功能 nslog里面是详细信息，界面里的别看了。

初学 swift 感受到了转换的不易，代码可能有问题。ObjC代码用于生产环境。

## tips

* iBeacon 只能在真机上测试。就算mac支持 BLE4.0 也不行

* iBeacon 通过 蓝牙 BLE4.0 对外广播的帧，进行定位。同样wifi也可以做到，而且wifi由于功率大，信号会更稳定。但是 iBeacon 默认在后台打开。

* 资料说iBeacon设备可以管理10*10 区域，也就是说，10米放置一个点，不要超过20米，才能做到1米误差内的三方定位。

*  iBeacon 信号强度收到很多条件影响，尤其是人，穿人基本信号消失。

*  iBeacon是地理服务，不是蓝牙服务，不用background 蓝牙 BLE 支持。

*  iBeacon不是蓝牙服务，所以连不上，但是可以扫描到。本例子就有扫描。

*  EnterRegion 和 ExitRegion 系统直接调用，不用打开app。

*  didRangeBeacons 在后台和锁屏情况下都能使用，9.0后不用background location 支持，支持可能造成审核难以通过。

* 记得在info.plist 加入 NSLocationAlwaysUsageDescription string 类型 对应设置里面的提示语句

*  iBeacon 通过广播帧里的自定义数据段 加入特定的字段来区分
    - uuid Apple Certificated Beacon ID，不同於 Device UUID
    - major + minor 精确到单独的设备 FFFFFFFF个
    - accuracy 苹果推荐的距离，1米以内还算好，一米以外，漂移严重，10米以外，基本消失。
    - rssi 信号强度，上面的accuracy距离就是通过该强度计算获得，所以一样1米以外漂移严重，这里注意——iBeacon下获得rssi 和 蓝牙下获得rssi 会有偏差？？？？尤其在信号不好的情况下，iBeacon会直接出0，而蓝牙的rssi依然有值。如果精确定位情况，直接用蓝牙。

*  一个app只能监听 20个 uuid ，最好只监听一个，划分段落时候谨慎处理。

* IOS设备为了保护隐私，蓝牙只能获取到 自动生成的 Device UUID 这个 Device UUID 对于本系统是唯一的，但是不一定对于别的设备也是唯一。再说一次，iBeacon的 uuid 是设置的，这个Device UUID是系统产生的，两个不一样。

* IOS 为了保护隐私，无法直接取到蓝牙设备（包括iBeacon）的 MAC 地址，这样会造成物理唯一性的缺失，有的厂家已经考虑到了这点，所以在广播帧的数据端添加了MAC地址，但是这样的MAC地址无法通过官方API获取，可以和厂商联系，索取SDK文档

* 审核app时候，记得给一段使用录像，说明使用方式，传到优酷即可。

* 微信的摇一摇功能也用到了iBeacon功能，微信的UUID是固定的，major 和 minor 也只能申请，如果app和微信同时支持，按着微信为准，先申请，用申请下来的UUID，major 和 minor 直接找厂商，让出场设置直接设为这个。

* 本tips针对IOS9