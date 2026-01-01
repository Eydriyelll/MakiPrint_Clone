import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';

class RequestDemoPage extends StatelessWidget {
  const RequestDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: NavbarWidget(isMobile: isMobile),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us or Request a Demo',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tell us about your printing needs and we\'ll arrange a demo. We\'ll reach out quickly to schedule a live walkthrough and answer any questions.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: WebViewWidget(
                      controller: WebViewController()
                        ..loadRequest(Uri.parse('https://forms.gle/fiFdo9n3W5HbYdSm9')),
                    ),
                  ),
                ],
              ),
            ),
            FooterWidget(isMobile: isMobile),
          ],
        ),
      ),
    );
  }
}
