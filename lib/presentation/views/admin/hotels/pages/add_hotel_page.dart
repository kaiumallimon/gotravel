import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/presentation/providers/add_hotel_provider.dart';
import 'package:gotravel/presentation/widgets/custom_button.dart';
import 'package:gotravel/presentation/widgets/custom_text_area.dart';
import 'package:gotravel/presentation/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminAddHotelPage extends StatelessWidget {
  const AdminAddHotelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addHotelProvider = Provider.of<AddHotelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: Consumer<AddHotelProvider>(
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
        title: const Text("Add Hotel"),
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
              // import from json
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: addHotelProvider.isLoading
                      ? null
                      : () async {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 25,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Import Hotel from JSON",
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Paste your JSON data in the text area below and click 'Import'.",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextArea(
                                      minLines: 7,
                                      maxLines: 15,
                                      controller:
                                          addHotelProvider.jsonController,
                                      labelText: "JSON Data"
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Consumer<AddHotelProvider>(
                                        builder: (context, provider, child) {
                                          return ElevatedButton.icon(
                                            onPressed: () {
                                              provider.importFromJson(context);
                                            },
                                            icon: const Icon(Icons.file_upload),
                                            label: const Text("Import"),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
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

              // Hotel Name
              CustomTextField(
                controller: addHotelProvider.hotelNameController,
                labelText: "Hotel Name",
              ),

              const SizedBox(height: 10),

              // Hotel Description
              CustomTextArea(
                controller: addHotelProvider.hotelDescriptionController,
                labelText: "Hotel Description",
              ),

              const SizedBox(height: 10),

              // Hotel Location
              CustomTextField(
                controller: addHotelProvider.hotelAddressController,
                labelText: "Hotel Location",
              ),

              const SizedBox(height: 10),

              // Hotel City
              CustomTextField(
                controller: addHotelProvider.hotelCityController,
                labelText: "City",
              ),

              const SizedBox(height: 10),

              // Hotel Country
              CustomTextField(
                controller: addHotelProvider.hotelCountryController,
                labelText: "Country",
              ),

              const SizedBox(height: 10),

              // Hotel Latitude - Longitude
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: addHotelProvider.hotelLattitudeController,
                      labelText: "Latitude",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: addHotelProvider.hotelLongitudeController,
                      labelText: "Longitude",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Hotel Contact Email
              CustomTextField(
                controller: addHotelProvider.hotelContactEmailController,
                labelText: "Contact Email",
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 10),

              // Hotel Phone
              CustomTextField(
                controller: addHotelProvider.hotelPhoneController,
                labelText: "Phone",
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 10),
              Consumer<AddHotelProvider>(
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

              // hotel images
              Consumer<AddHotelProvider>(
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
                            "Hotel Images",
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),

                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.images.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  mainAxisExtent: 150,
                                ),
                            itemBuilder: (context, index) {
                              final imageFile = provider.images[index];
                              return Stack(
                                children: [
                                  Image.file(
                                    File(imageFile.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),

                                  // Remove Image Button
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: provider.isLoading
                                          ? null
                                          : () {
                                              provider.removeImage(index);
                                            },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          // Add Image Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: Consumer<AddHotelProvider>(
                              builder: (context, provider, child) {
                                return ElevatedButton.icon(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          await addHotelProvider.pickImages(
                                            context,
                                          );
                                        },
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add Image"),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Rooms Section
              Consumer<AddHotelProvider>(
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
                          Text("Rooms", style: theme.textTheme.titleMedium),
                          const SizedBox(height: 10),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.roomControllers.length,
                            itemBuilder: (context, index) {
                              final room = provider.roomControllers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        controller: room["roomType"]!,
                                        labelText: "Room Type",
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextField(
                                        controller: room["pricePerNight"]!,
                                        labelText: "Price Per Night",
                                        keyboardType: TextInputType.number,
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextField(
                                        controller: room["currency"]!,
                                        labelText: "Currency (e.g., USD)",
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextField(
                                        controller: room["capacity"]!,
                                        labelText: "Capacity",
                                        keyboardType: TextInputType.number,
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextField(
                                        controller: room["bedType"]!,
                                        labelText: "Bed Type",
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextField(
                                        controller: room["amenities"]!,
                                        labelText:
                                            "Amenities (comma-separated)",
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextField(
                                        controller: room["availableCount"]!,
                                        labelText: "Available Count",
                                        keyboardType: TextInputType.number,
                                      ),

                                      // Remove Room Button
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: provider.isLoading
                                              ? null
                                              : () {
                                                  provider.removeRoom(index);
                                                },
                                          icon: const Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                          label: const Text(
                                            "Remove Room",
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Add Room Button (ONLY here)
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: provider.isLoading
                                  ? null
                                  : () {
                                      provider.addRoom();
                                    },
                              icon: const Icon(Icons.add),
                              label: const Text("Add Room"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Save Hotel Button
              Align(
                alignment: Alignment.centerRight,
                child: Consumer<AddHotelProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final error = provider.validateInputs();
                              if (error != null) {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: "Validation Error",
                                  text: error,
                                );
                                return;
                              } else {
                                await provider.saveHotelSupabase(context);
                              }
                              // Save hotel logic here
                            },
                      child: const Text("Save Hotel"),
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
