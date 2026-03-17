<img width="1371" alt="logo" src="https://github.com/user-attachments/assets/9e27f4e8-603b-4ec5-b0b0-e3d2f8d0d8d9">

## Description
Scout is a robust logging framework designed to provide comprehensive logging capabilities for your applications. It supports various logging levels, output formats, and destinations, making it easy to integrate and customize according to your needs. Whether you are developing a small project or a large-scale system, Scout ensures that you have detailed and organized logs to help you monitor and debug your applications effectively.

## Table of Contents
- [CloudKit Integration](#cloudkit-integration)
- [Logging & Metrics](#logging--metrics)
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

## Logging & Metrics
Scout builds on Apple’s observability facades:
- [swift-log](https://github.com/apple/swift-log) for structured logging
- [swift-metrics](https://github.com/apple/swift-metrics) for counters, gauges, and timers

Benefits:
- **📏 Standardization**: Use unified, community-adopted APIs for logs and metrics.
- **🔧 Flexibility**: Customize log handlers and formats to suit your specific needs.
- **🔍 Correlation**: Share labels/metadata to jump from a metric spike to the exact log events.
- **⚡ Insight + Performance**: Keep metrics lightweight on hot paths; use logs for rich context when needed.

Together, logs answer “what happened?” while metrics quantify “how often?” and “how fast?”.

## Installation
For detailed installation instructions, please refer to the [Installation Guide](https://github.com/kasianov-mikhail/scout/wiki).

## Usage

```swift
import Logging

let logger = Logger(label: "SOME_LOGGER_LABEL")

logger.warning(
    "Search_Performed",
    metadata: [
        "description": .string(error.localizedDescription),
        "ip": .string(ip),
    ]
)
```

## Visualizing the Logs

By integrating `HomeView` into your SwiftUI application, you can gain insights into your application's performance and issues through an intuitive and interactive interface. 
```swift
HomeView(container: container)
```
> This should be done only in debug mode to avoid exposing sensitive log data in production environments.

<img width="200" src="https://github.com/user-attachments/assets/0987c808-6d08-4e99-8ca7-1218d352e0bf"> <img width="200" src="https://github.com/user-attachments/assets/a70ae4d9-3680-48d3-8129-2febdc466030"> <img width="200" src="https://github.com/user-attachments/assets/6043911e-fd0b-4f6e-9785-c262dab1c6d7"> <img width="200" src="https://github.com/user-attachments/assets/52c03cd6-fb3a-43cf-a58c-ab82ff2ca47e">

## Example Project

You can find an example project demonstrating the integration of Scout with CloudKit in the [Scout IP repository](https://github.com/kasianov-mikhail/scout-ip). This project provides a comprehensive example of how to set up and use Scout for logging in a real-world application.

## License
Scout is released under the MIT License. See [LICENSE](LICENSE) for details.
