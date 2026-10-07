import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../widgets/cosmic_ui.dart';

const _contactEmail = 'support@myfuture.app';
const _lastUpdated = 'September 8, 2026';
const _developer = 'MyFuture';
const _appName = 'MyFuture';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      title: 'Privacy Policy',
      heading: '$_appName Privacy Policy',
      sections: const [
        (
          'Who we are',
          '$_appName (“we”, “us”) provides AI-assisted Vedic astrology consultations via a mobile application. This Privacy Policy explains what personal data we collect, why we collect it, how we use it, and the choices you have. By using the app you agree to this policy.',
        ),
        (
          'Information we collect',
          '• Account identifiers: mobile number and/or email address used to sign in with a one-time password (OTP).\n'
              '• Profile & birth details: name, gender, date of birth, birth time, and birth place (including approximate latitude/longitude) needed to compute your Vedic chart (kundli).\n'
              '• Usage content: consultation chats, palm-reading images you upload, session summaries, and in-app support tickets.\n'
              '• Transaction data: subscription purchases, referral activity, and related payment references from our payment processor.\n'
              '• Device & technical data: basic app diagnostics (for example crash or connectivity errors) and language preference.',
        ),
        (
          'How we use your information',
          'We use your data to create and secure your account, compute and display your birth chart, generate astrology-related AI replies and palm readings, process subscription payments, provide customer support, prevent abuse/fraud, and improve product reliability. Birth details and chat content are used only to deliver the astrology service you request.',
        ),
        (
          'AI processing',
          'Questions and limited chart context may be sent to third-party AI providers (for example generative AI APIs) to produce responses. Do not share passwords, bank details, government IDs, or medical/legal secrets in chat. AI replies are interpretive guidance for entertainment and personal reflection — not professional advice.',
        ),
        (
          'Payments',
          'Payments for Monthly Pro subscriptions are processed by third-party payment providers (such as Razorpay). We do not store your full card or UPI credentials. Payment providers process data under their own privacy policies.',
        ),
        (
          'Sharing of information',
          'We do not sell your personal data. We may share limited data with:\n'
              '• Cloud hosting and database providers that store app data securely.\n'
              '• AI providers solely to generate requested readings.\n'
              '• Payment processors for checkout and verification.\n'
              '• Authorities when required by applicable law.\n'
              'Service providers are instructed to use data only to perform services for us.',
        ),
        (
          'Data retention',
          'We retain account, chart, chat, and transaction records while your account is active and as needed for billing, dispute resolution, security, and legal obligations. You may request deletion as described below.',
        ),
        (
          'Security',
          'We use industry-standard measures such as encrypted transport (where available), authenticated sessions (tokens), and access-controlled databases. No method of transmission or storage is 100% secure.',
        ),
        (
          'Your rights & choices',
          'Depending on your location, you may have rights to access, correct, or delete personal data, or withdraw consent where processing is consent-based. In the app you can edit birth details, end consultations, change language, sign out, and permanently delete your account from You → Delete account (this removes your profile, chart, chats, wallet history, and related data). For other privacy requests, contact us at $_contactEmail or send a Support ticket with subject “Privacy”. We will respond within a reasonable period as required by law.',
        ),
        (
          'Children',
          '$_appName is not directed to children under 13 (or the minimum age required in your country). We do not knowingly collect personal information from children. If you believe a child has provided data, contact $_contactEmail and we will take appropriate steps.',
        ),
        (
          'International processing',
          'Your information may be processed on servers located in India or other countries where our service providers operate. By using the app you understand that data may be transferred to those locations with appropriate safeguards.',
        ),
        (
          'Changes to this policy',
          'We may update this Privacy Policy from time to time. The “Last updated” date will change when we do. Continued use of the app after an update means you accept the revised policy. Material changes may also be notified in-app when practical.',
        ),
        (
          'Contact',
          'Developer: $_developer\n'
              'App: $_appName\n'
              'Email: $_contactEmail\n'
              'You can also open Profile → Help & support in the app.',
        ),
      ],
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      title: 'Terms of Service',
      heading: '$_appName Terms of Service',
      sections: const [
        (
          'Agreement',
          'These Terms of Service (“Terms”) govern your use of the $_appName mobile application and related services. By creating an account or using the app you agree to these Terms and our Privacy Policy. If you do not agree, do not use the app.',
        ),
        (
          'Eligibility',
          'You must be at least 13 years old (or the age of digital consent in your country) and capable of forming a binding contract. You are responsible for the accuracy of the mobile number or email you use to register.',
        ),
        (
          'Nature of the service',
          '$_appName provides AI-assisted Vedic astrology interpretation, kundli views, and related features for entertainment, cultural interest, and personal reflection only. Content is not medical, legal, financial, psychological, or other professional advice. Do not make life-critical decisions solely based on readings.',
        ),
        (
          'Accounts & OTP login',
          'Access is provided via one-time password (OTP) sent or displayed for the identifier you enter. You are responsible for keeping access to that phone/email secure. We may suspend accounts that show abuse, fraud, or Terms violations.',
        ),
        (
          'Birth data accuracy',
          'Chart quality depends on the birth date, time, and place you provide. Incorrect details can change readings. You are responsible for the information you submit.',
        ),
            (
              'Subscriptions & payments',
              'Access to palm reading and full Kundli (Bhagya, Yog, AI report) requires an active Monthly Pro subscription (€11/month, paid via Razorpay in INR). Chat is billed at €1 per minute from your wallet. Referral rewards may credit your in-app balance. Fees are generally non-refundable except where required by law or our support policy.',
            ),
        (
          'Acceptable use',
          'You agree not to: harass others; attempt unauthorized access; reverse engineer the service beyond legal rights; upload illegal or harmful content; misuse AI for non-astrology spam; or use the app in violation of applicable law. See also our Community Guidelines.',
        ),
        (
          'Intellectual property',
          'The app, branding, and software are owned by $_developer or its licensors. You receive a limited, non-exclusive, non-transferable license to use the app for personal, non-commercial purposes.',
        ),
        (
          'Disclaimers',
          'THE SERVICE IS PROVIDED “AS IS” AND “AS AVAILABLE” WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. We do not guarantee uninterrupted service, specific outcomes, or error-free AI responses.',
        ),
        (
          'Limitation of liability',
          'TO THE MAXIMUM EXTENT PERMITTED BY LAW, $_developer SHALL NOT BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS, DATA, OR GOODWILL ARISING FROM YOUR USE OF THE APP. OUR TOTAL LIABILITY FOR ANY CLAIM RELATING TO THE SERVICE IS LIMITED TO THE AMOUNT YOU PAID US FOR THE SERVICE IN THE THREE (3) MONTHS BEFORE THE CLAIM.',
        ),
        (
          'Termination',
          'You may stop using the app at any time. We may suspend or terminate access if you breach these Terms or if we discontinue the service. Provisions that by nature should survive (including disclaimers and liability limits) will survive termination.',
        ),
        (
          'Governing law',
          'These Terms are governed by the laws of India, without regard to conflict-of-law rules, unless mandatory consumer protections in your country require otherwise. Courts in India shall have exclusive jurisdiction, subject to applicable consumer rights.',
        ),
        (
          'Changes',
          'We may update these Terms as the product evolves. The “Last updated” date will change when we do. Continued use after updates constitutes acceptance of the revised Terms.',
        ),
        (
          'Contact',
          'Questions about these Terms: $_contactEmail or Profile → Help & support in the app.',
        ),
      ],
    );
  }
}

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      title: 'Community Guidelines',
      heading: '$_appName Community Guidelines',
      sections: const [
        (
          'Our community standard',
          '$_appName is a space for respectful, curiosity-driven astrology exploration. These Community Guidelines (also called our content / user conduct policy) explain what is allowed so the app stays safe and useful for everyone. By using $_appName you agree to follow them along with our Terms of Service and Privacy Policy.',
        ),
        (
          'Be respectful',
          'Do not use the service to harass, threaten, demean, or discriminate against any person or group. Astrology discussions should remain civil.',
        ),
        (
          'Allowed content',
          '• Questions about your own chart, life themes, compatibility as it relates to your chart, remedies, and general Vedic astrology learning.\n'
              '• Palm photos you own or have permission to share for your own reading.\n'
              '• Support requests about the app, billing, or account.',
        ),
        (
          'Prohibited content & conduct',
          'You must not:\n'
              '• Upload sexual, pornographic, or exploitative imagery — including of minors (zero tolerance).\n'
              '• Share content that promotes violence, terrorism, self-harm, or illegal activity.\n'
              '• Impersonate others, spread malware, or attempt to hack or disrupt the service.\n'
              '• Spam, scrape, or automate abuse of OTP, chat, or payment systems.\n'
              '• Request or provide medical diagnoses, illegal financial schemes, or doxxing.\n'
              '• Use the AI for purposes unrelated to the astrology product in a way that violates our Terms.',
        ),
        (
          'User-generated content',
          'Chats and images you submit remain your responsibility. You grant us a limited license to process that content to provide the service (generate replies, store history you can revisit, improve safety). We may remove content or restrict accounts that violate these Guidelines.',
        ),
        (
          'Safety & reporting',
          'If you encounter abusive behavior or content that violates these Guidelines, report it via Profile → Help & support with subject “Safety report”, or email $_contactEmail. We review reports and may remove content, warn users, or suspend accounts.',
        ),
        (
          'Enforcement',
          'Violations may result in content removal, feature limits, temporary suspension, or permanent account termination without refund where permitted by law. Serious illegal activity may be reported to authorities.',
        ),
        (
          'Updates',
          'We may update these Guidelines to reflect new features or legal requirements. Continued use after updates means you accept the revised Guidelines.',
        ),
        (
          'Contact',
          'Community / safety questions: $_contactEmail',
        ),
      ],
    );
  }
}

class _LegalScaffold extends StatelessWidget {
  const _LegalScaffold({
    required this.title,
    required this.heading,
    required this.sections,
  });

  final String title;
  final String heading;
  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          CosmicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(heading, style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.goldSoft)),
                const SizedBox(height: 6),
                Text('Last updated: $_lastUpdated', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 4),
                Text('Developer: $_developer · Contact: $_contactEmail',
                    style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...sections.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CosmicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.$1, style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.goldSoft)),
                    const SizedBox(height: 8),
                    Text(e.$2, style: GoogleFonts.sora(fontSize: 13, color: AppColors.muted, height: 1.55)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
