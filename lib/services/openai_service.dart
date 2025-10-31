import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey;
  static const String _baseUrl = 'https://api.openai.com/v1/responses';
  static const String _model = 'gpt-3.5-turbo';

  OpenAIService(this._apiKey);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

  /// 공통: API 호출 및 output_text 파싱
  Future<String> _callResponsesApi(Map<String, dynamic> payload) async {
    final res = await http
        .post(Uri.parse(_baseUrl), headers: _headers, body: jsonEncode(payload))
        .timeout(const Duration(seconds: 45));

    if (res.statusCode != 200) {
      throw Exception('OpenAI API 호출 실패: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes));

    // 1) 권장: output_text
    final outputText = data['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    // 2) 폴백: output[0].content[0].text
    try {
      final output = data['output'] as List<dynamic>?;
      if (output != null && output.isNotEmpty) {
        final content = output.first['content'] as List<dynamic>?;
        if (content != null && content.isNotEmpty) {
          final text = content.first['text'];
          if (text is String && text.trim().isNotEmpty) {
            return text.trim();
          }
        }
      }
    } catch (_) {
      // ignore and fallthrough
    }

    throw Exception('OpenAI 응답 파싱 실패: output_text가 비어있거나 구조가 예상과 다릅니다.');
  }

  /// 텍스트로 레시피 분석
  Future<Map<String, dynamic>> analyzeRecipeText(String text) async {
    const systemPrompt = '당신은 베이킹 레시피 분석 전문가입니다.';
    final userPrompt = '''
다음 레시피 텍스트를 분석하여 JSON 형식으로 재료 목록을 추출해주세요:

{
  "name": "레시피 이름",
  "description": "레시피 설명 (있다면)",
  "ingredients": [
    {
      "name": "재료명",
      "weight": 숫자 (그램 단위, 정수),
      "isFlour": true/false (밀가루 계열이면 true)
    }
  ]
}

규칙:
- weight는 반드시 그램(g) 단위의 숫자로 변환
- 밀가루, 강력분, 중력분, 박력분 등은 isFlour=true
- 다른 재료는 isFlour=false
- 레시피 이름이 없으면 "추출된 레시피"
- description이 없으면 빈 문자열
- JSON 형식만 반환(추가 텍스트 금지)

레시피 텍스트:
$text
''';

    final payload = {
      'model': _model,
      'input': [
        {
          'role': 'system',
          'content': [
            {'type': 'input_text', 'text': systemPrompt}
          ]
        },
        {
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': userPrompt}
          ]
        }
      ],
      'max_output_tokens': 800,
    };

    final jsonString = await _callResponsesApi(payload);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// 이미지로 레시피 분석
  Future<Map<String, dynamic>> analyzeRecipeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final b64 = base64Encode(bytes);
    final dataUrl = 'data:image/${_inferImageExt(imageFile.path)};base64,$b64';

    const systemPrompt = '당신은 베이킹 레시피 분석 전문가입니다.';
    const instruction = '''
이미지에서 레시피를 분석하여 다음 JSON 형식으로 재료 목록을 추출해주세요:

{
  "name": "레시피 이름",
  "description": "레시피 설명 (있다면)",
  "ingredients": [
    {
      "name": "재료명",
      "weight": 숫자 (그램 단위, 정수),
      "isFlour": true/false (밀가루 계열이면 true)
    }
  ]
}

규칙:
- weight는 반드시 그램(g) 단위의 숫자로 변환
- 밀가루, 강력분, 중력분, 박력분 등은 isFlour=true
- 다른 재료는 isFlour=false
- 레시피 이름이 없으면 "이미지에서 추출된 레시피"
- description이 없으면 빈 문자열
- JSON 형식만 반환(추가 텍스트 금지)
''';

    // 이미지 입력은 content 배열에 input_image 타입으로 넣어야 합니다.
    final payload = {
      'model': _model,
      'input': [
        {
          'role': 'system',
          'content': [
            {'type': 'input_text', 'text': systemPrompt}
          ]
        },
        {
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': instruction},
            {'type': 'input_image', 'image_url': dataUrl},
          ]
        }
      ],
      'max_output_tokens': 800,
    };

    final jsonString = await _callResponsesApi(payload);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// 간단한 확장자 유추 (jpeg/png/webp 등)
  String _inferImageExt(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.gif')) return 'gif';
    if (lower.endsWith('.bmp')) return 'bmp';
    // 기본 jpeg
    return 'jpeg';
  }
}
