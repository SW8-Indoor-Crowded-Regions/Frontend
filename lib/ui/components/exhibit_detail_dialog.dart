import 'package:flutter/material.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/data_extractor.dart';
import '../../utils/date_formatter.dart';
import '../../utils/dimension_formatter.dart';
import 'exhibit_detail_row.dart';
import 'color_section.dart';

/// A dialog that displays detailed information about an exhibit
class ExhibitDetailDialog extends StatelessWidget {
  final dynamic exhibit;

  const ExhibitDetailDialog({super.key, required this.exhibit});

  @override
  Widget build(BuildContext context) {
    final String title = DataExtractor.extractTitle(exhibit);
    final String artist = _formatArtist(DataExtractor.extractArtist(exhibit));
    final String? thumbnail = exhibit["image_thumbnail"];
    final String location = DataExtractor.extractLocation(exhibit);
    final String dating = DateFormatter.formatDating(exhibit);
    final List<String> materials =
        DataExtractor.extractListValues(exhibit, "materials");
    final List<String> techniques =
        DataExtractor.extractListValues(exhibit, "techniques");
    final List<String> colors =
        DataExtractor.extractListValues(exhibit, "colors");
    final String dimensions =
        DimensionFormatter.formatNettoDimensions(exhibit) ??
            'Dimensions Not Available';
    final String description =
        DataExtractor.extractValue(exhibit, "content_description");
    final String? frontendUrl = exhibit["frontend_url"];

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.orange.shade500, // Orange border
          width: 1, // Border thickness
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: IntrinsicHeight(
          // <-- Automatically adapts to content height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (thumbnail != null)
                _buildHeaderWithImage(context, thumbnail, title, artist),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (thumbnail == null)
                        _buildHeaderWithoutImage(title, artist),
                      ExhibitDetailRow(label: "Location", value: location),
                      if (dating != "Unknown")
                        ExhibitDetailRow(label: "Dating", value: dating),
                      if (materials.isNotEmpty)
                        ExhibitDetailRow(
                            label: "Materials", value: materials.join(", ")),
                      if (techniques.isNotEmpty)
                        ExhibitDetailRow(
                            label: "Techniques", value: techniques.join(", ")),
                      if (dimensions.isNotEmpty)
                        ExhibitDetailRow(
                            label: "Dimensions", value: dimensions),
                      if (colors.isNotEmpty)
                        ColorSection(label: "Colors", colors: colors),
                      if (description.isNotEmpty && description != "Unknown")
                        _buildDescriptionSection(description),
                      const ExhibitDetailRow(
                          label: "Source",
                          value: "Statens Museums for Kunst, open.smk.dk"),
                      if (frontendUrl != null) _buildLinkButton(frontendUrl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatArtist(String artist) =>
      artist == 'Ubekendt' ? 'Unknown' : artist;

  Widget _buildHeaderWithImage(
      BuildContext context, String thumbnail, String title, String artist) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.broken_image,
                    size: 40, color: Colors.grey.shade400),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    artist,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithoutImage(String title, String artist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade500, // Brighter orange for dark mode
            ),
          ),
          const SizedBox(height: 4),
          Text(
            artist,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70, // Light text for dark mode
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade500, // Brighter orange for dark mode
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70, // Light text for dark mode
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            await launchUrl(Uri.parse(url));
          } catch (e) {
            ErrorToast.show("Failed to access URL");
          }
        },
        icon: const Icon(Icons.open_in_new),
        label: const Text("View on Website"),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor:
              Colors.orange.shade500, // Brighter orange for dark mode
        ),
      ),
    );
  }
}
