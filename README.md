<img width="1371" alt="logo" src="https://github.com/user-attachments/assets/9e27f4e8-603b-4ec5-b0b0-e3d2f8d0d8d9">

## Description
Scout is a robust logging framework designed to provide comprehensive logging capabilities for your applications. It supports various logging levels, output formats, and destinations, making it easy to integrate and customize according to your needs. Whether you are developing a small project or a large-scale system, Scout ensures that you have detailed and organized logs to help you monitor and debug your applications effectively.

## Table of Contents
- [CloudKit Integration](#cloudkit-integration)
- [`swift-log` API](#swift-log-api)
- [Installation](#installation)
- [Visualizing the Logs](#visualizing-the-logs)
- [Example Project](#example-project)
- [License](#license)

## CloudKit Integration
Scout offers seamless integration with [CloudKit](https://developer.apple.com/icloud/cloudkit/), allowing you to store and manage your logs in the cloud effortlessly. By leveraging [CloudKit](https://developer.apple.com/icloud/cloudkit/), you can:

- **📊 Centralize Logs**: Store logs from multiple devices and applications in a single, centralized location.
- **⏱️ Real-time Access**: Access your logs in real-time from anywhere, ensuring you can monitor your applications' performance and issues promptly.
- **📈 Scalability**: Benefit from [CloudKit](https://developer.apple.com/icloud/cloudkit/)'s scalability to handle large volumes of log data without compromising performance.
- **🔒 Security**: Ensure your logs are securely stored and transmitted, adhering to industry-standard security practices.

## `swift-log` API
Scout leverages the power of [swift-log](https://github.com/apple/swift-log), Apple's official logging API, to provide a flexible and efficient logging solution. By using [swift-log](https://github.com/apple/swift-log), Scout ensures compatibility with other  libraries and tools, making it easier to integrate into your existing projects.

### Benefits of Using `swift-log` with Scout
- **📏 Standardization**: Utilize a standardized logging API that is widely adopted in the Swift community.
- **🔧 Flexibility**: Customize log handlers and formats to suit your specific needs.

By integrating [swift-log](https://github.com/apple/swift-log) with Scout, you can take advantage of a robust and standardized logging framework that enhances your application's logging capabilities.


## Installation
To integrate CloudKit with Scout, follow the steps below:

1. **Enable CloudKit**: Ensure CloudKit is enabled in your Apple Developer account and configured for your project [Enabling CloudKit in Your App](https://developer.apple.com/documentation/cloudkit/enabling_cloudkit_in_your_app)

    > It may take some time for the database to become fully operational.
2. **Upload you database scheme**:
To upload your database schema to CloudKit, follow these steps:

- Navigate to the [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/) and sign in with your Apple Developer account.

- Choose the CloudKit container associated with your project.

- In the CloudKit Dashboard, navigate to the "Schema" section and use the "Import Schema" option to upload your exported [schema file](Schema). 

- Once your schema is defined, deploy it to the production environment by clicking the "Deploy to Production" button. This ensures that your schema changes are applied and available for use in your application.

3. **Configure Scout**: Update Scout's configuration to include your CloudKit container identifier and any necessary authentication details.
```swift
import Scout
import Logging

let container = CKContainer(identifier: "YOUR_CONTAINER_ID")

LoggingSystem.bootstrap { label in
    CKLogHandler(label: label, container: container)
}
```

4. **Usage**: 

```swift
import Logging

let logger = Logger(label: "SOME_LOGGER_LABEL")

logger.warning(
    "event_need_to_know_about",
    metadata: [
        "description": .string(error.localizedDescription),
        "ip": .string(ip),
    ]
)
```

## Visualizing the Logs

By integrating `AnalyticsView` into your SwiftUI application, you can gain insights into your application's performance and issues through an intuitive and interactive interface. 
```swift
AnalyticsView(container: container)
```
> This should be done only in debug mode to avoid exposing sensitive log data in production environments.

| | | |
| ------------- | ------------- | ------------- |
| ![](https://github.com/user-attachments/assets/a7cf7126-d995-4fa8-a148-20670b1260f6)  | ![](https://github.com/user-attachments/assets/c84c0051-5dea-4669-9bd1-bc9bb9f7d321)  | ![](https://github.com/user-attachments/assets/2bcd1f75-86dd-4d43-b378-e402d376832a)  |

## Example Project

You can find an example project demonstrating the integration of Scout with CloudKit in the [Scout IP repository](https://github.com/kasianov-mikhail/scout-ip). This project provides a comprehensive example of how to set up and use Scout for logging in a real-world application.

## License
Scout is released under the MIT License. See [LICENSE](LICENSE) for details.
