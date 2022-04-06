import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

const academicPerformanceURL =
    'https://portfolio.rsue.ru/portfolio/index.php?section=23';
const loginURL = 'https://portfolio.rsue.ru/login/index.php';
const reportURL = 'https://portfolio.rsue.ru/portfolio/index.php?view=1';
const whoamiURL = 'https://portfolio.rsue.ru/portfolio/index.php?section=11';

bool? _checkAuthByDataRaw(String data) {
  if (data.contains(
      '<script type="text/javascript">document.location.replace("/login/index.php");</script>')) {
    return false;
  }
  if (data.contains(
      "document.documentElement.style.backgroundImage = \"url('/style/images/background.png')\";")) {
    return true;
  }
  return null;
}

Future<String?> _getRaw(String url,
    {required String username, required String password}) async {
  try {
    // set up cookie storage
    var dio = Dio();
    var cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    // the request which send PHPSESSID cookie with the status of successful
    // authorization to cookie storage
    await dio.post(loginURL,
        data: {'password': password, 'username': username, 'loginbtn': 'Вход'},
        options: Options(contentType: "application/x-www-form-urlencoded"));

    var response = await dio.get(url);
    if (_checkAuthByDataRaw(response.data) == true) {
      return response.data;
    }
  } catch (e) {
    print(e);
  }
  return null;
}

Map<String, String>? _whoamiParser(String raw) {
  Map<String, String> result = {};

  var document = parse(raw);

  List<String> keys = document
      .getElementsByClassName("grid-cell-left")
      .map((e) => e.text)
      .toList();

  List<String> values =
      document.getElementsByClassName("grid-cell").map((e) => e.text).toList();

  if (keys.length != values.length) {
    throw Exception("Количество ключей и значений не совпадает");
  } else {
    for (var i = 0; i < keys.length; i++) {
      result[keys[i]] = values[i];
    }
    return result;
  }
}

class SubjectPerfomance {
  SubjectPerfomance();
  late String name;
  late int statement;
  late String teacher;
  late bool isClosed;
  late String type;
  late int controlPoint1;
  late int controlPoint2;

  factory SubjectPerfomance.fromRaw(Element raw) {
    String text = raw.children[0].children[0].text;

    String name, type, teacher;
    int statement, controlPoint1, controlPoint2;
    bool isClosed = true;

    if (text.contains(" (Экзамен)")) {
      name = text.replaceAll(" (Экзамен)", "");
      type = "Экзамен";
    } else if (text.contains(" (Зачет)")) {
      name = text.replaceAll(" (Зачет)", "");
      type = "Зачет";
    } else {
      name = text;
      type = "";
    }

    text = raw.children[0].children[2].text;

    if (text.contains("не закрыта")) {
      isClosed = false;
    }
    statement = int.parse(RegExp(r'\d+').firstMatch(text)?[0] ?? '0');

    teacher = RegExp(r'<i>Преподаватель:<\/i> ([^\n]+)')
            .firstMatch(raw.children[0].innerHtml)?[1] ??
        '';

    controlPoint1 = int.parse(
        RegExp(r'КТ1 = (\d+)').firstMatch(raw.children[0].innerHtml)?[1] ??
            '0');
    controlPoint2 = int.parse(
        RegExp(r'КТ2 = (\d+)').firstMatch(raw.children[0].innerHtml)?[1] ??
            '0');
    print(raw.children[0].innerHtml);
    print(RegExp(r'КТ2 = (\d+)').firstMatch(raw.children[0].innerHtml));

    //
    return SubjectPerfomance()
      ..name = name
      ..type = type
      ..isClosed = isClosed
      ..statement = statement
      ..teacher = teacher
      ..controlPoint1 = controlPoint1
      ..controlPoint2 = controlPoint2;
  }
}

Map? _academicPerformanceParser(String raw) {
  List<Element>? tbody = parse(raw).getElementsByTagName('tbody')[0].children;
  tbody.removeAt(0);
  Map result = {};
  String? key;
  List<SubjectPerfomance> value = [];
  for (var element in tbody) {
    if (element.children[0].className == "cell-style-1") {
      if (key != null) {
        result[key] = value;
      }
      key = element.text;
      value = [];
    } else {
      value.add(SubjectPerfomance.fromRaw(element));
    }
  }
  if ((key != null) && !result.containsKey(key)) {
    result[key] = value;
  }
  return result;
}

Future<Map?> academicPerformance(
    {required String username, required String password}) async {
  var academicPerformance = await _getRaw(academicPerformanceURL,
      username: username, password: password);
  if (academicPerformance != null) {
    var a = _academicPerformanceParser(academicPerformance);
    return a;
  }
  return null;
}

Future<Map?> whoami(
    {required String username, required String password}) async {
  var whoami = await _getRaw(whoamiURL, username: username, password: password);
  if (whoami != null) {
    var a = _whoamiParser(whoami);
    return a;
  }
  return null;
}
