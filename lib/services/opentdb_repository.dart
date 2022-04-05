import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:quiz/services/question_repository.dart';
import 'package:quiz/models/question.dart';
import 'package:html_unescape/html_unescape.dart';

class OpentdbRepository implements QuestionRepository {
  final Uri _url;

  OpentdbRepository(this._url);

  @override
  Future<Question> fetch() async {
    final response = await http.get(_url);

    if (response.statusCode >= 300) {
      throw Exception('Please handle me');
    }

    // Unescape HTML entities
    var unescape = HtmlUnescape();

    Map<String, dynamic> json = jsonDecode(response.body)['results'][0];
    List<String> answers = json['incorrect_answers'].cast<String>();
    answers.add(json['correct_answer']);
    answers.map((element) => element = unescape.convert(element));
    answers.shuffle();

    return Question(
        unescape.convert(json['question']),
        answers,
        unescape.convert(json['correct_answer']),
        unescape.convert(json['category']));
  }
}
