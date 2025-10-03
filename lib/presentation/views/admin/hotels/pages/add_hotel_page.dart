import 'package:flutter/material.dart';
import 'package:gotravel/presentation/views/admin/hotels/providers/add_hotel_provider.dart';
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

              const SizedBox(height: 20),

              // Rooms Section
              Card(
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
                        itemCount: addHotelProvider.roomControllers.length,
                        itemBuilder: (context, index) {
                          final room = addHotelProvider.roomControllers[index];
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
                                    labelText: "Amenities (comma-separated)",
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
                                      onPressed: () {
                                        addHotelProvider.removeRoom(index);
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
                          onPressed: () {
                            addHotelProvider.addRoom();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Room"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Save Hotel Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    final error = addHotelProvider.validateInputs();
                    if (error != null) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: "Validation Error",
                        text: error,
                      );
                      return;
                    }
                    // Save hotel logic here
                  },
                  child: const Text("Save Hotel"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
