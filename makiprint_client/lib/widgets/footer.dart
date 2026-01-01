import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  final bool isMobile;

  const FooterWidget({Key? key, this.isMobile = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: isMobile ? 32 : 48,
      ),
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Footer Content Grid
          GridView.count(
            crossAxisCount: isMobile ? 1 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: isMobile ? 8 : 32,
            crossAxisSpacing: isMobile ? 8 : 32,
            children: [
              _buildFooterColumn(context, 'Company', [
                'About Us',
                'Careers',
                'Blog',
                'Press',
              ]),
              _buildFooterColumn(context, 'Product', [
                'Features',
                'Pricing',
                'Security',
                'Updates',
              ]),
              _buildFooterColumn(context, 'Support', [
                'Documentation',
                'FAQ',
                'Contact Us',
                'Community',
              ]),
              _buildFooterColumn(context, 'Legal', [
                'Privacy Policy',
                'Terms of Service',
                'Cookie Policy',
                'Sitemap',
              ]),
            ],
          ),
          SizedBox(height: isMobile ? 24 : 48),
          // Social Media Links
          Row(
            children: [
              _buildSocialIcon(Icons.facebook, 'Facebook'),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.business, 'LinkedIn'),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.camera_alt, 'Instagram'),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.mail, 'Twitter'),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 32),
          // Copyright
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[700]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '© 2025 MakiPrint. All rights reserved.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Revolutionizing retail printing, one print at a time.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigate to $item'))),
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String label) {
    return Tooltip(
      message: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
