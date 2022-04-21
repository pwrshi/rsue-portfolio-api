# API для работы с сервисом портфолио РГЭУ (РИНХ)
## Как начать использовать
Так как этот пакет отсутсвует в pub-е то его нужно подключать прямо с git. Просто допишите в pubspec.yaml следущее:
```yaml
dependencies:
  ...
  rsue_portfolio_api:
    git:
      url: https://github.com/pwrshi/rsue-portfolio-api.git
  ...
```
и теперь можете смело писать в заголовках
```dart
import 'package:rsue_portfolio_api/rsue_portfolio_api.dart';
```
## Информация о пользователе
```dart
Future<Map?> whoami({required String username, required String password})
```
![результат выполнения whoami](https://github.com/pwrshi/rsue-portfolio-api/raw/main/assets/whoami.jpg)
## Информация о оценках
```dart
Future<Map?> academicPerformance({required String username, required String password})
```
![результат выполнения academicPerformance](https://github.com/pwrshi/rsue-portfolio-api/raw/main/assets/academicPerfomance.jpg)
## Квитанции по общежитиям
```dart
Future<Map?> accounting({required String username, required String password})
```
![результат выполнения accounting](https://github.com/pwrshi/rsue-portfolio-api/raw/main/assets/accounting.jpg)
