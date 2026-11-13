import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../widgets/primary_button.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _picker = ImagePicker();
  
  File? _selectedImage;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryBlue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlue),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      // Successfully saved!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved ${_makeController.text} ${_modelController.text} successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      
      Navigator.pop(context, {
        'make': _makeController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'plate': _plateController.text,
        'image': _selectedImage,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Vehicle',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker Container (Rounded Square)
                Center(
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.file(
                                _selectedImage!,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.textSecondary,
                                  size: 32,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 28.0),

                // Make Label & Text Field
                _buildFieldLabel('Make'),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _makeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(hintText: 'e.g. Toyota'),
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the vehicle make';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20.0),

                // Model Label & Text Field
                _buildFieldLabel('Model'),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _modelController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(hintText: 'e.g. Corolla'),
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the vehicle model';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20.0),

                // Year Label & Text Field
                _buildFieldLabel('Year'),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(hintText: 'e.g. 2020'),
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the vehicle year';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1886 || year > 2100) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20.0),

                // License Plate Label & Text Field
                _buildFieldLabel('License Plate'),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _buildInputDecoration(hintText: 'e.g. ABC-1234'),
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your license plate number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
          child: PrimaryButton(
            text: 'Save Vehicle',
            iconPath: null, // No icon matching mockup
            onPressed: _saveVehicle,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: AppColors.faultRed,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: AppColors.faultRed,
          width: 1.5,
        ),
      ),
    );
  }
}
