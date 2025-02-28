import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proj/services/cloudinary_services.dart';


class UploadArea extends StatefulWidget {
  const UploadArea({super.key});

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea> {
  @override
  Widget build(BuildContext context) {
    final selectedFile =
        ModalRoute.of(context)!.settings.arguments as FilePickerResult;
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Area"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              initialValue: selectedFile.files.first.name,
              decoration: InputDecoration(label: Text("Name")),
            ),
            TextFormField(
              readOnly: true,
              initialValue: selectedFile.files.first.extension,
              decoration: InputDecoration(label: Text("Exention")),
            ),
            TextFormField(
              readOnly: true,
              initialValue: "${selectedFile.files.first.size} bytes.",
              decoration: InputDecoration(label: Text("Size")),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel")),
                ),
                SizedBox(
                  width: 25,
                ),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () async {
                          final result = await uploadToCloudinary(selectedFile);

                          if (result) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("File Uploaded Successfully.")));
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Cannot Upload Your File.")));
                          }
                        },
                        child: Text("Upload")))
              ],
            )
          ],
        ),
      ),
    );
  }
}