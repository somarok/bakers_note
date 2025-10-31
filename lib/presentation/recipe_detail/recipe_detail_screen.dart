import 'dart:io';
import 'package:bakers_note/common/app_colors.dart';
import 'package:bakers_note/data/model/bakers_recipe.dart';
import 'package:bakers_note/data/repository/recipe_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class RecipeDetailScreen extends StatefulWidget {
  final BakersRecipe recipe;
  final int recipeIndex;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.recipeIndex,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeRepository _repository = RecipeRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _imagePath;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.recipe.name ?? '';
    _descriptionController.text = widget.recipe.description ?? '';
    _imagePath = widget.recipe.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
        _imagePath = image.path;
      });
    }
  }

  Future<void> _saveChanges() async {
    final updatedRecipe = widget.recipe.copyWith(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      imagePath: _imagePath,
    );

    await _repository.updateRecipe(widget.recipeIndex, updatedRecipe);

    if (!mounted) return;

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('레시피가 수정되었습니다'),
        duration: Duration(seconds: 1),
        backgroundColor: Color.fromARGB(255, 86, 86, 86),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '레시피 수정' : '레시피 상세'),
        surfaceTintColor: AppColors.primaryColor90,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('저장'),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(_imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imagePath == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isEditing ? Icons.add_photo_alternate : Icons.image,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isEditing ? '사진 추가하기' : '사진 없음',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // 레시피 이름
            if (_isEditing)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '레시피 이름',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            else
              Text(
                widget.recipe.name ?? '이름 없는 레시피',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),

            // 생성일
            Text(
              '생성일: ${DateFormat('yyyy.MM.dd HH:mm').format(widget.recipe.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // 설명
            const Text(
              '설명',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: '레시피 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              )
            else
              Text(
                widget.recipe.description ?? '설명이 없습니다',
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 24),

            // 재료 목록
            const Text(
              '재료 목록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.recipe.ingredients.map((ingredient) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${ingredient.name}${ingredient.isFlour ? ' 🌾' : ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Text(
                        '${ingredient.weight}g',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${ingredient.percent}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
