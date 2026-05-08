import 'package:flutter/material.dart';
import 'career_model.dart';
import 'career_repository.dart';

class CareerProvider extends ChangeNotifier {
  final CareerRepository _repository = CareerRepository();
  List<Career> _careers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Career> get careers => _careers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCareers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _careers = await _repository.getCareers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCareer(String title, String description, String iconName, String hexColor) async {
    try {
      await _repository.createCareer({
        'title': title,
        'description': description,
        'icon_name': iconName,
        'hex_color': hexColor,
      });
      await fetchCareers(); 
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCareer(String id) async {
    try {
      await _repository.deleteCareer(id);
      await fetchCareers(); 
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}