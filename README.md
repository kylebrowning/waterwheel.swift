###Drupal iOS SDK - Connect your iOS/OS X app to Drupal
-----
###### built by [Kyle Browning](http://kylebrowning.com) 

![Travis CI](https://travis-ci.org/kylebrowning/drupal-ios-sdk.svg)

####Introduction
----

The Drupal iOS SDK is a standard set of libraries for communicating to Drupal from any iOS device. Its extremely simple, and is basically a wrapper for AFNetworking. It combines the most used commands to communicate with Drupal and handles session managment for you(minus oauth)

### Requirements

| DIOS Version | Drupal Version  | Min iOS Target  |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
|          [4.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/4.x)         |            Drupal 8 (Swift)            | iOS 9.0   
|          [3.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/master)         |            Drupal 8 (Obj-C)            |           iOS 7.0          |  |
|          [2.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/2.x)         |            Drupal 6-7 (Obj-C)            |         iOS 5.0        |        Requires [Services](http://drupal.org/project/services) module                                                                    |


####Installation
----
Create a pod file with (this will keep you on the 4.0 releases which is Drupal 8 specific) 
```
 pod 'drupal-ios-sdk', '~> 4.0'
```
Then run 
```
pod install
```

####Configuration

`Coming soon`

####Usage

```swift 
let dios = DIOS()
dios.setUserNameAndPassword("kylebrowning", password: "KCg-bz5-CBe-BFH")
dios.sendRequest("node/1", method: .GET, params: nil) { (success, response, error) in
    if (success) {
        print(response)
    } else {
        print(error)
    }
}
 ```
