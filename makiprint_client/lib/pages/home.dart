import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _carouselController;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(initialPage: 0);
    _startCarouselAutoScroll();
  }

  void _startCarouselAutoScroll() {
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _carouselController.hasClients) {
        _carouselController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startCarouselAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    // Placeholder for scroll-to-section functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Navigating to $section section')));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navbar
            _buildNavbar(context, isMobile),

            // Hero Carousel
            _buildHeroCarousel(context, isMobile),

            // Section 2: Philippines' Best Commercial Retail Printing Solution
            _buildSection2(context, isMobile),

            // Section 3: Make Printing Seamless
            _buildSection3(context, isMobile),

            // Section 4: Reduce Foot Traffic
            _buildSection4(context, isMobile),

            // Section 5: Make your Home Printer Print Money
            _buildSection5(context, isMobile),

            // Section 6: Make Retail Printing Accessible and Easy
            _buildSection6(context, isMobile),

            // Footer
            _buildFooter(context, isMobile),
          ],
        ),
      ),
    );
  }

  // Navbar Widget
  Widget _buildNavbar(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Text(
            'MakiPrint',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          // Desktop Navigation Menu
          if (!isMobile)
            Row(
              children: [
                TextButton(
                  onPressed: () => _scrollToSection('About Us'),
                  child: const Text('About us'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => _scrollToSection('Request a Demo'),
                  child: const Text('Request a Demo'),
                ),
              ],
            ),

          // Mobile: Print a Document button, Desktop: Print a Document button
          ElevatedButton(
            onPressed: () {
              // Navigate to printing app
              Navigator.pushNamed(context, '/print');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Print a Document'),
          ),
        ],
      ),
    );
  }

  // Hero Carousel Widget
  Widget _buildHeroCarousel(BuildContext context, bool isMobile) {
    final carouselItems = [
      _CarouselItem(
        title: 'Make Your Home Printer Print Money for You',
        subtitle:
            'Turn your idle printer into a passive income stream. Accept printing jobs from your community with MakiPrint and earn while you sleep.',
        buttonText: 'Start Your Small Printing Business',
        buttonAction: () => _scrollToSection('Home Printer'),
        iconPlaceholder: Icons.home_repair_service,
      ),
      _CarouselItem(
        title: 'Make Your Printing Service Autonomous',
        subtitle:
            'Automate pricing, payment collection, and job management. Perfect for printing shops and school bookstores looking to scale without hiring.',
        buttonText: 'Book a Demo',
        buttonAction: () => _scrollToSection('Book Demo'),
        iconPlaceholder: Icons.business,
      ),
      _CarouselItem(
        title: 'Print Anything, Anytime—No USB, No Hassle',
        subtitle:
            'Just a QR code and your phone. No USB drives, no email attachments, no waiting. Print retail services at your fingertips in seconds.',
        buttonText: 'Print a Document Now',
        buttonAction: () => Navigator.pushNamed(context, '/print'),
        iconPlaceholder: Icons.qr_code,
      ),
    ];

    return Container(
      height: isMobile ? 500 : 600,
      color: Colors.grey[100],
      child: Stack(
        children: [
          PageView(
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index % carouselItems.length;
              });
            },
            children: carouselItems
                .map((item) => _buildCarouselCard(context, item, isMobile))
                .toList(),
          ),
          // Carousel Indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                carouselItems.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentCarouselIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentCarouselIndex == index
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselCard(
    BuildContext context,
    _CarouselItem item,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Row(
        children: [
          // Text Content
          Expanded(
            flex: isMobile ? 1 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: item.buttonAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 32,
                      vertical: isMobile ? 12 : 16,
                    ),
                  ),
                  child: Text(
                    item.buttonText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          // Icon Placeholder (only on desktop)
          if (!isMobile)
            Expanded(
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.iconPlaceholder,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Section 2: Philippines' Best Commercial Retail Printing Solution
  Widget _buildSection2(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: isMobile ? 32 : 64,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "The Philippines' Best Commercial Retail Printing Solution is Here",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'We connect people with printers who want a passive income generator, printing shops with high foot traffic, and people who need retail printing services—making transactions seamless, hassle-free, and safe.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          // Photo/Clipart Placeholders
          GridView.count(
            crossAxisCount: isMobile ? 1 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            children: [
              _buildPlaceholderCard('Printers\nEarning\nPassive Income'),
              _buildPlaceholderCard('Printing Shops\nOptimizing\nOperations'),
              _buildPlaceholderCard('Users\nPrinting\nOn Demand'),
            ],
          ),
        ],
      ),
    );
  }

  // Section 3: Make Printing Seamless
  Widget _buildSection3(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: isMobile ? 32 : 64,
      ),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              // Icon/Photo Placeholder
              if (!isMobile)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              // Text Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: isMobile ? 0 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make Printing Seamless',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Need something printed ASAP? Don\'t have a flash drive/USB? MakiPrint-enabled printers don\'t need them—nor do you need to send emails. You\'re just one QR scan away from printing your files.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/print'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 32,
                            vertical: isMobile ? 12 : 16,
                          ),
                        ),
                        child: const Text('Print a Document'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section 4: Reduce Foot Traffic
  Widget _buildSection4(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: isMobile ? 32 : 64,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reduce Foot Traffic in Your Printing Shop',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Too many people waiting in queue? So much manual effort to serve all those customers? MakiPrint makes pricing, counting, and setting printing settings automated for you—all you need to do is collect their payment.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _scrollToSection('Request a Demo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 32,
                          vertical: isMobile ? 12 : 16,
                        ),
                      ),
                      child: const Text('Request a Demo'),
                    ),
                  ],
                ),
              ),
              // Icon/Photo Placeholder
              if (!isMobile)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.people, size: 80, color: Colors.blue),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Section 5: Make your Home Printer Print Money
  Widget _buildSection5(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: isMobile ? 32 : 64,
      ),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              // Icon/Photo Placeholder
              if (!isMobile)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.monetization_on,
                        size: 80,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              // Text Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: isMobile ? 0 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make Your Home Printer Print Money',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'If you want to make your printer generate passive income, MakiPrint can make it possible for you without the need to operate a computer. Just plug a dongle to your printer and you\'re ready to print cash.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _scrollToSection('Request a Demo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 32,
                            vertical: isMobile ? 12 : 16,
                          ),
                        ),
                        child: const Text('Request a Demo'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section 6: Make Retail Printing Accessible and Easy
  Widget _buildSection6(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: isMobile ? 48 : 80,
      ),
      color: Colors.green[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Make Retail Printing Accessible and Easy',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Discover how MakiPrint is revolutionizing the way people and businesses handle retail printing services.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _scrollToSection('About Us'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 32,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            child: const Text('Learn More About Us'),
          ),
        ],
      ),
    );
  }

  // Placeholder Card
  Widget _buildPlaceholderCard(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Footer Widget
  Widget _buildFooter(BuildContext context, bool isMobile) {
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
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            children: [
              _buildFooterColumn('Company', [
                'About Us',
                'Careers',
                'Blog',
                'Press',
              ]),
              _buildFooterColumn('Product', [
                'Features',
                'Pricing',
                'Security',
                'Updates',
              ]),
              _buildFooterColumn('Support', [
                'Documentation',
                'FAQ',
                'Contact Us',
                'Community',
              ]),
              _buildFooterColumn('Legal', [
                'Privacy Policy',
                'Terms of Service',
                'Cookie Policy',
                'Sitemap',
              ]),
            ],
          ),
          const SizedBox(height: 48),
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
          const SizedBox(height: 32),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
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

  Widget _buildFooterColumn(String title, List<String> items) {
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
              onTap: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Navigate to $item'))),
              child: Text(
                item,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
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
          onTap: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Open $label'))),
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

// Carousel Item Model
class _CarouselItem {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback buttonAction;
  final IconData iconPlaceholder;

  _CarouselItem({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonAction,
    required this.iconPlaceholder,
  });
}
