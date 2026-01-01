import 'package:flutter/material.dart';
import '../pages/request_demo.dart';
import '../pages/document_dashboard.dart';
import '../pages/about_us.dart';
import '../pages/home.dart';
import '../pages/howitworks.dart';
import '../pages/blog.dart';

class NavbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;

  const NavbarWidget({Key? key, this.isMobile = false}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo (clickable to go back home)
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                'MakiPrint',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
              ),
            ),
          ),

          // Desktop Navigation Menu
          if (!isMobile)
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutUsPage()),
                  ),
                  child: const Text('About us'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RequestDemoPage()),
                  ),
                  child: const Text('Request a Demo'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BlogPage()),
                  ),
                  child: const Text('Blog'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RequestDemoPage()),
                  ),
                  child: const Text('Contact Us'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HowItWorksPage()),
                  ),
                  child: const Text('How it Works'),
                ),
              ],
            ),

          // Mobile: Hamburger Menu
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      color: Colors.white,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            title: const Text('About us'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AboutUsPage()),
                              );
                            },
                          ),
                          ListTile(
                            title: const Text('Request a Demo'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RequestDemoPage()),
                              );
                            },
                          ),
                          ListTile(
                            title: const Text('Blog'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BlogPage()),
                              );
                            },
                          ),
                          ListTile(
                            title: const Text('Contact Us'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RequestDemoPage()),
                              );
                            },
                          ),
                          ListTile(
                            title: const Text('How it Works'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HowItWorksPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Mobile & Desktop: Print a Document button
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DocumentDashboard()),
            ),
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
}
