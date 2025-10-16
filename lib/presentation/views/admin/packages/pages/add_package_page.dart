import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/presentation/providers/add_package_provider.dart';
import 'package:gotravel/presentation/providers/places_provider.dart';
import 'package:gotravel/presentation/widgets/custom_button.dart';
import 'package:gotravel/presentation/widgets/custom_text_area.dart';
import 'package:gotravel/presentation/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class AdminAddPackagePage extends StatefulWidget {
  const AdminAddPackagePage({super.key});

  @override
  State<AdminAddPackagePage> createState() => _AdminAddPackagePageState();
}

class _AdminAddPackagePageState extends State<AdminAddPackagePage> {
  @override
  void initState() {
    super.initState();
    // Load places when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlacesProvider>(context, listen: false).loadPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addPackageProvider = Provider.of<AddPackageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: Consumer<AddPackageProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: provider.isLoading
                  ? null
                  : () {
                      GoRouter.of(context).pop();
                    },
            );
          },
        ),
        title: const Text("Add Package"),
        centerTitle: false,
        surfaceTintColor: theme.colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Import from JSON
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: addPackageProvider.isLoading
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
                                        "Import Package from JSON",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      CustomTextArea(
                                        controller: addPackageProvider.jsonController,
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
                                              addPackageProvider.importFromJson(context);
                                              Navigator.pop(context);
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
                ),
              ),

              const SizedBox(height: 15),

              // Package Name
              CustomTextField(
                controller: addPackageProvider.packageNameController,
                labelText: "Package Name",
              ),

              const SizedBox(height: 10),

              // Package Description
              CustomTextArea(
                controller: addPackageProvider.packageDescriptionController,
                labelText: "Package Description",
              ),

              const SizedBox(height: 10),

              // Destination
              CustomTextField(
                controller: addPackageProvider.destinationController,
                labelText: "Destination",
              ),

              const SizedBox(height: 10),

              // Country
              CustomTextField(
                controller: addPackageProvider.countryController,
                labelText: "Country",
              ),

              const SizedBox(height: 10),

              // Place Selection
              Consumer<PlacesProvider>(
                builder: (context, placesProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Associated Place (Optional)",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: addPackageProvider.selectedPlaceId,
                            hint: const Text("Select a place (optional)"),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              addPackageProvider.selectedPlaceId = newValue;
                            },
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text("No place selected"),
                              ),
                              ...placesProvider.places.map<DropdownMenuItem<String>>((place) {
                                return DropdownMenuItem<String>(
                                  value: place.id,
                                  child: Text(
                                    "${place.name} - ${place.country}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Link this package to a specific place for better organization",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),

              // Category
              CustomTextField(
                controller: addPackageProvider.categoryController,
                labelText: "Category (e.g., Adventure, Cultural, Relaxation)",
              ),

              const SizedBox(height: 10),

              // Duration and Price Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: addPackageProvider.durationController,
                      labelText: "Duration (Days)",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: addPackageProvider.priceController,
                      labelText: "Price",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: addPackageProvider.currencyController,
                      labelText: "Currency",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Participants and Slots Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: addPackageProvider.maxParticipantsController,
                      labelText: "Max Participants",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: addPackageProvider.availableSlotsController,
                      labelText: "Available Slots",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Difficulty Level and Minimum Age Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: addPackageProvider.difficultyLevelController,
                      labelText: "Difficulty (Optional)",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: addPackageProvider.minimumAgeController,
                      labelText: "Minimum Age",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Included Services
              CustomTextArea(
                controller: addPackageProvider.includedServicesController,
                labelText: "Included Services (comma-separated)",
              ),

              const SizedBox(height: 10),

              // Excluded Services
              CustomTextArea(
                controller: addPackageProvider.excludedServicesController,
                labelText: "Excluded Services (comma-separated)",
              ),

              const SizedBox(height: 10),

              // Contact Information Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: addPackageProvider.contactEmailController,
                      labelText: "Contact Email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: addPackageProvider.contactPhoneController,
                      labelText: "Contact Phone",
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Cover Image Button
              Consumer<AddPackageProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: provider.coverImage == null
                        ? "Select Cover Image"
                        : "Selected: ${provider.coverImage!.name}",
                    width: double.infinity,
                    isOutlined: true,
                    isLoading: provider.isLoading,
                    onPressed: () async {
                      await provider.pickCoverImage(context);
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              // Package Images Section
              Consumer<AddPackageProvider>(
                builder: (context, provider, child) {
                  return Card(
                    elevation: 0,
                    color: theme.colorScheme.primary.withAlpha(100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Package Images (${provider.images.length})",
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),

                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: provider.images.length + 1,
                            itemBuilder: (context, index) {
                              if (index == provider.images.length) {
                                return GestureDetector(
                                  onTap: () async {
                                    await provider.pickImages(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.colorScheme.primary,
                                        style: BorderStyle.solid,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                );
                              }

                              return Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(provider.images[index].path),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await provider.removeImage(index);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          CustomButton(
                            text: "Add Images",
                            width: double.infinity,
                            isOutlined: true,
                            onPressed: () async {
                              await provider.pickImages(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Activities Section
              Consumer<AddPackageProvider>(
                builder: (context, provider, child) {
                  return Card(
                    elevation: 0,
                    color: theme.colorScheme.primary.withAlpha(100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Activities (${provider.activityControllers.length})",
                                style: theme.textTheme.titleMedium,
                              ),
                              IconButton(
                                onPressed: () {
                                  provider.addActivity();
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),

                          if (provider.activityControllers.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No activities added yet"),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.activityControllers.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Activity ${index + 1}",
                                              style: theme.textTheme.titleSmall,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                provider.removeActivity(index);
                                              },
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: CustomTextField(
                                                controller: provider.activityControllers[index]["dayNumber"]!,
                                                labelText: "Day",
                                                keyboardType: TextInputType.number,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              flex: 2,
                                              child: CustomTextField(
                                                controller: provider.activityControllers[index]["activityName"]!,
                                                labelText: "Activity Name",
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 10),
                                        
                                        CustomTextArea(
                                          controller: provider.activityControllers[index]["description"]!,
                                          labelText: "Description",
                                        ),
                                        
                                        const SizedBox(height: 10),
                                        
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                controller: provider.activityControllers[index]["location"]!,
                                                labelText: "Location",
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: CustomTextField(
                                                controller: provider.activityControllers[index]["activityType"]!,
                                                labelText: "Type",
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 10),
                                        
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                controller: provider.activityControllers[index]["startTime"]!,
                                                labelText: "Start Time (Optional)",
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: CustomTextField(
                                                controller: provider.activityControllers[index]["endTime"]!,
                                                labelText: "End Time (Optional)",
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 10),
                                        
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                controller: provider.activityControllers[index]["additionalCost"]!,
                                                labelText: "Additional Cost",
                                                keyboardType: TextInputType.number,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: provider.activityControllers[index]["isOptional"]!.text == "true" ? "true" : "false",
                                                decoration: const InputDecoration(
                                                  labelText: "Optional?",
                                                  border: OutlineInputBorder(),
                                                ),
                                                items: const [
                                                  DropdownMenuItem(value: "false", child: Text("Required")),
                                                  DropdownMenuItem(value: "true", child: Text("Optional")),
                                                ],
                                                onChanged: (value) {
                                                  provider.activityControllers[index]["isOptional"]!.text = value ?? "false";
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Package Dates Section
              Consumer<AddPackageProvider>(
                builder: (context, provider, child) {
                  return Card(
                    elevation: 0,
                    color: theme.colorScheme.primary.withAlpha(100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Package Dates (${provider.packageDateControllers.length})",
                                style: theme.textTheme.titleMedium,
                              ),
                              IconButton(
                                onPressed: () {
                                  provider.addPackageDate();
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),

                          if (provider.packageDateControllers.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No dates added yet"),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.packageDateControllers.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Date ${index + 1}",
                                              style: theme.textTheme.titleSmall,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                provider.removePackageDate(index);
                                              },
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                controller: provider.packageDateControllers[index]["departureDate"]!,
                                                labelText: "Departure Date (YYYY-MM-DD)",
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: CustomTextField(
                                                controller: provider.packageDateControllers[index]["returnDate"]!,
                                                labelText: "Return Date (YYYY-MM-DD)",
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 10),
                                        
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                controller: provider.packageDateControllers[index]["availableSlots"]!,
                                                labelText: "Available Slots",
                                                keyboardType: TextInputType.number,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: CustomTextField(
                                                controller: provider.packageDateControllers[index]["priceOverride"]!,
                                                labelText: "Price Override (Optional)",
                                                keyboardType: TextInputType.number,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Save Package Button
              Align(
                alignment: Alignment.centerRight,
                child: Consumer<AddPackageProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              await provider.savePackageSupabase(context);
                            },
                      child: provider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Save Package"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}