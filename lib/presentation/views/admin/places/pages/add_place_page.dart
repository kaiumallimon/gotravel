import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/presentation/providers/admin_places_provider.dart';
import 'package:gotravel/presentation/widgets/custom_text_area.dart';
import 'package:gotravel/presentation/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class AddPlacePage extends StatefulWidget {
  final PlaceModel? placeToEdit;
  
  const AddPlacePage({super.key, this.placeToEdit});

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ratingController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _bestTimeController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _languageController = TextEditingController();
  final _timeZoneController = TextEditingController();
  final _famousForController = TextEditingController();
  final _activitiesController = TextEditingController();
  
  String _selectedCategory = 'Beach';
  bool _isActive = true;
  bool _isFeatured = false;
  int _popularRanking = 0;
  int _visitCount = 0;
  List<String> _existingImageUrls = [];
  
  final List<String> _categories = ['Beach', 'Forest', 'Mountain', 'Suburban', 'Urban'];

  @override
  void initState() {
    super.initState();
    if (widget.placeToEdit != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final place = widget.placeToEdit!;
    _nameController.text = place.name;
    _countryController.text = place.country;
    _cityController.text = place.city ?? '';
    _descriptionController.text = place.description ?? '';
    _ratingController.text = place.rating.toString();
    _latitudeController.text = place.latitude?.toString() ?? '';
    _longitudeController.text = place.longitude?.toString() ?? '';
    _bestTimeController.text = place.bestTimeToVisit ?? '';
    _temperatureController.text = place.averageTemperature ?? '';
    _languageController.text = place.localLanguage ?? '';
    _timeZoneController.text = place.timeZone ?? '';
    _famousForController.text = place.famousFor.join(', ');
    _activitiesController.text = place.activities.join(', ');
    _selectedCategory = place.category ?? 'Beach';
    _isActive = place.isActive;
    _isFeatured = place.isFeatured;
    _popularRanking = place.popularRanking;
    _visitCount = place.visitCount;
    _existingImageUrls = [...place.images];
  }

  void _populateFromJson(Map<String, dynamic> data) {
    setState(() {
      _nameController.text = data['name'] ?? '';
      _countryController.text = data['country'] ?? '';
      _cityController.text = data['city'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _ratingController.text = (data['rating'] ?? 0.0).toString();
      _latitudeController.text = data['latitude']?.toString() ?? '';
      _longitudeController.text = data['longitude']?.toString() ?? '';
      _bestTimeController.text = data['best_time_to_visit'] ?? '';
      _temperatureController.text = data['average_temperature'] ?? '';
      _languageController.text = data['local_language'] ?? '';
      _timeZoneController.text = data['time_zone'] ?? '';
      
      // Handle arrays - join with commas
      if (data['famous_for'] != null && data['famous_for'] is List) {
        _famousForController.text = (data['famous_for'] as List).join(', ');
      }
      if (data['activities'] != null && data['activities'] is List) {
        _activitiesController.text = (data['activities'] as List).join(', ');
      }
      
      // Category dropdown
      if (data['category'] != null && _categories.contains(data['category'])) {
        _selectedCategory = data['category'];
      }
      
      // Boolean values
      _isActive = data['is_active'] ?? true;
      _isFeatured = data['is_featured'] ?? false;
      
      // Integer values
      _popularRanking = data['popular_ranking'] ?? 0;
      _visitCount = data['visit_count'] ?? 0;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _bestTimeController.dispose();
    _temperatureController.dispose();
    _languageController.dispose();
    _timeZoneController.dispose();
    _famousForController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.placeToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Place' : 'Add New Place'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(CupertinoIcons.xmark),
        ),
        actions: [
          Consumer<AdminPlacesProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return TextButton(
                onPressed: _submitForm,
                child: Text(
                  isEditing ? 'Update' : 'Save',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // JSON Import Button
              Align(
                alignment: Alignment.center,
                child: Consumer<AdminPlacesProvider>(
                  builder: (context, provider, child) {
                    return TextButton.icon(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Import Place from JSON",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          CustomTextArea(
                                            controller: provider.jsonController,
                                            labelText: "Paste JSON data here",
                                            maxLines: 8,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final jsonData = provider.importFromJson(context);
                                                  if (jsonData != null) {
                                                    _populateFromJson(jsonData);
                                                  }
                                                },
                                                child: const Text("Import"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                      icon: const Icon(Icons.file_upload),
                      label: const Text("Import from JSON"),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Basic Information Section
              Text(
                'Basic Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Place Name
              CustomTextField(
                controller: _nameController,
                labelText: "Place Name *",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter place name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Country and City Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _countryController,
                      labelText: "Country *",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter country';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      labelText: "City",
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Category Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      border: InputBorder.none,
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              CustomTextArea(
                controller: _descriptionController,
                labelText: "Description",
                maxLines: 4,
              ),
              
              const SizedBox(height: 16),
              
              // Location Information
              Text(
                'Location Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Latitude and Longitude
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _latitudeController,
                      labelText: "Latitude",
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _longitudeController,
                      labelText: "Longitude",
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Additional Information
              Text(
                'Additional Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Rating
              CustomTextField(
                controller: _ratingController,
                labelText: "Rating (0.0 - 5.0)",
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final rating = double.tryParse(value);
                    if (rating == null || rating < 0 || rating > 5) {
                      return 'Rating must be between 0.0 and 5.0';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Best Time to Visit and Temperature
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _bestTimeController,
                      labelText: "Best Time to Visit",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _temperatureController,
                      labelText: "Average Temperature",
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Language and Time Zone
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _languageController,
                      labelText: "Local Language",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _timeZoneController,
                      labelText: "Time Zone",
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Famous For
              CustomTextField(
                controller: _famousForController,
                labelText: "Famous For (comma separated)",
              ),
              
              const SizedBox(height: 16),
              
              // Activities
              CustomTextField(
                controller: _activitiesController,
                labelText: "Activities (comma separated)",
              ),
              
              const SizedBox(height: 16),
              
              // Popular Ranking
              TextFormField(
                initialValue: _popularRanking.toString(),
                decoration: InputDecoration(
                  labelText: "Popular Ranking",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _popularRanking = int.tryParse(value) ?? 0;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Visit Count (for editing)
              if (isEditing)
                TextFormField(
                  initialValue: _visitCount.toString(),
                  decoration: InputDecoration(
                    labelText: "Visit Count",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _visitCount = int.tryParse(value) ?? 0;
                  },
                ),
              
              if (isEditing) const SizedBox(height: 16),
              
              // Toggle Switches
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text('Active'),
                        subtitle: Text('Place is visible to users'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                        secondary: Icon(
                          _isActive ? CupertinoIcons.checkmark_circle : CupertinoIcons.xmark_circle,
                          color: _isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                      Divider(),
                      SwitchListTile(
                        title: Text('Featured'),
                        subtitle: Text('Place appears in featured section'),
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value;
                          });
                        },
                        secondary: Icon(
                          _isFeatured ? CupertinoIcons.star_fill : CupertinoIcons.star,
                          color: _isFeatured ? Colors.amber : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Images Section
              Text(
                'Images',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Cover Image Section
              Consumer<AdminPlacesProvider>(
                builder: (context, provider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cover Image',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Cover Image Display
                          if (provider.coverImage != null)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(provider.coverImage!.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        provider.coverImage = null;
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          CupertinoIcons.xmark,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 12),
                          
                          // Select Cover Image Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                provider.pickCoverImage(context);
                              },
                              icon: Icon(CupertinoIcons.camera),
                              label: Text(provider.coverImage == null 
                                  ? 'Select Cover Image' 
                                  : 'Change Cover Image'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Additional Images Section
              Consumer<AdminPlacesProvider>(
                builder: (context, provider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Images (${provider.additionalImages.length})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Images Grid
                          if (provider.additionalImages.isNotEmpty)
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: provider.additionalImages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: FileImage(File(provider.additionalImages[index].path)),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              provider.removeAdditionalImage(index);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                CupertinoIcons.xmark,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          
                          if (provider.additionalImages.isNotEmpty) 
                            const SizedBox(height: 12),
                          
                          // Select Images Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                provider.pickAdditionalImages(context);
                              },
                              icon: Icon(CupertinoIcons.photo_on_rectangle),
                              label: Text(provider.additionalImages.isEmpty 
                                  ? 'Select Images' 
                                  : 'Add More Images'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // Existing Images (for editing)
              if (isEditing && _existingImageUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Images',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _existingImageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _existingImageUrls[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[300],
                                            child: Icon(CupertinoIcons.photo),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _existingImageUrls.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            CupertinoIcons.xmark,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final place = PlaceModel(
        id: widget.placeToEdit?.id ?? '',
        name: _nameController.text,
        country: _countryController.text,
        city: _cityController.text.isEmpty ? null : _cityController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        category: _selectedCategory,
        latitude: double.tryParse(_latitudeController.text),
        longitude: double.tryParse(_longitudeController.text),
        rating: double.tryParse(_ratingController.text) ?? 0.0,
        isActive: _isActive,
        isFeatured: _isFeatured,
        popularRanking: _popularRanking,
        visitCount: _visitCount,
        bestTimeToVisit: _bestTimeController.text.isEmpty ? null : _bestTimeController.text,
        averageTemperature: _temperatureController.text.isEmpty ? null : _temperatureController.text,
        localLanguage: _languageController.text.isEmpty ? null : _languageController.text,
        timeZone: _timeZoneController.text.isEmpty ? null : _timeZoneController.text,
        famousFor: _famousForController.text.isEmpty 
            ? [] 
            : _famousForController.text.split(',').map((e) => e.trim()).toList(),
        activities: _activitiesController.text.isEmpty 
            ? [] 
            : _activitiesController.text.split(',').map((e) => e.trim()).toList(),
        coverImage: widget.placeToEdit?.coverImage ?? '',
        images: _existingImageUrls,
        createdAt: widget.placeToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final provider = Provider.of<AdminPlacesProvider>(context, listen: false);
      bool success;

      if (widget.placeToEdit != null) {
        success = await provider.updatePlace(place);
      } else {
        success = await provider.addPlace(place);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.placeToEdit != null 
                ? 'Place updated successfully' 
                : 'Place added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save place'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}