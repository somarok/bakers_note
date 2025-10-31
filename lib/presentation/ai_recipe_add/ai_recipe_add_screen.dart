import 'dart:io';
import 'package:bakers_note/app_log_printer.dart';
import 'package:bakers_note/common/app_colors.dart';
import 'package:bakers_note/data/model/bakers_recipe.dart';
import 'package:bakers_note/data/model/ingredient.dart';
import 'package:bakers_note/data/repository/recipe_repository.dart';
import 'package:bakers_note/services/openai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class AiRecipeAddScreen extends StatefulWidget {
  const AiRecipeAddScreen({super.key});

  @override
  State<AiRecipeAddScreen> createState() => _AiRecipeAddScreenState();
}

class _AiRecipeAddScreenState extends State<AiRecipeAddScreen> {
  final TextEditingController _textController = TextEditingController();
  late final OpenAIService _aiService;
  final RecipeRepository _repository = RecipeRepository();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    _aiService = OpenAIService(apiKey);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _errorMessage = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _errorMessage = null;
      });
    }
  }

  Future<void> _analyzeText() async {
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '레시피 텍스트를 입력해주세요';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _aiService.analyzeRecipeText(_textController.text);
      await _saveRecipe(result);
    } catch (e) {
      setState(() {
        _errorMessage = 'AI 분석 실패: $e';
        log.e(_errorMessage);
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = '이미지를 선택해주세요';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _aiService.analyzeRecipeImage(_selectedImage!);
      await _saveRecipe(result);
    } catch (e) {
      setState(() {
        _errorMessage = 'AI 분석 실패: $e';
        log.e(_errorMessage);
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _saveRecipe(Map<String, dynamic> result) async {
    try {
      final ingredients = (result['ingredients'] as List).map((item) {
        return Ingredient(
          id: 0, // ID는 나중에 재설정됨
          name: item['name'] as String,
          weight: (item['weight'] as num).toInt(),
          percent: 0, // 백분율은 나중에 계산됨
          isFlour: item['isFlour'] as bool,
        );
      }).toList();

      // ID 재설정
      for (int i = 0; i < ingredients.length; i++) {
        ingredients[i] = ingredients[i].copyWith(id: i + 1);
      }

      final recipe = BakersRecipe(
        name: result['name'] as String?,
        description: result['description'] as String?,
        ingredients: ingredients,
        createdAt: DateTime.now(),
        imagePath: _selectedImage?.path,
      );

      await _repository.saveRecipe(recipe);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI로 레시피가 추가되었습니다'),
          duration: Duration(seconds: 1),
          backgroundColor: Color.fromARGB(255, 86, 86, 86),
        ),
      );

      Navigator.of(context).pop(true); // 성공 결과 반환
    } catch (e) {
      setState(() {
        _errorMessage = '레시피 저장 실패: $e';
        log.e(_errorMessage);
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI로 레시피 추가'),
        surfaceTintColor: AppColors.primaryColor90,
      ),
      body: _isAnalyzing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI가 레시피를 분석하고 있습니다...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '방법 1: 텍스트로 추가',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '레시피 텍스트를 입력하세요\n예: 강력분 300g, 물 180g, 소금 6g...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 8,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _analyzeText,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor10,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('텍스트 분석하기'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '방법 2: 이미지로 추가',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedImage != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              '레시피 이미지를 선택하세요',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('갤러리'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('카메라'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _analyzeImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor10,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('이미지 분석하기'),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
