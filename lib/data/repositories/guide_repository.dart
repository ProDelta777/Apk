import '../models/document_guide.dart';

class GuideRepository {
  static const List<DocumentGuide> allGuides = [
    DocumentGuide(
      title: "Aadhaar Card",
      iconPath: "aadhaar",
      purpose: "Unique identity document for Indian residents.",
      eligibility: "Any resident of India, including minors.",
      requiredDocuments: [
        "Proof of Identity (Voter ID, Passport, PAN Card)",
        "Proof of Address (Ration Card, Utility Bill)",
        "Proof of Date of Birth (Birth Certificate)"
      ],
      processSteps: [
        "Locate an Aadhaar enrollment center near you.",
        "Book an appointment online or visit directly.",
        "Fill out the enrollment form.",
        "Provide biometric and demographic data.",
        "Collect the acknowledgment slip."
      ],
      estimatedTime: "15-30 days for generation.",
      importantNotes: "Keep the acknowledgment slip safe to track status.",
      commonMistakes: "Name mismatch across submitted documents.",
      faq: [
        {"Q": "Is Aadhaar mandatory?", "A": "It is required for most government schemes and subsidies."},
        {"Q": "Can I update details online?", "A": "Yes, address can be updated online. Biometrics require a visit to a center."}
      ]
    ),
    DocumentGuide(
      title: "PAN Card",
      iconPath: "pan",
      purpose: "Filing income tax returns and high-value transactions.",
      eligibility: "Indian citizens, NRIs, and foreign citizens paying tax in India.",
      requiredDocuments: [
        "Aadhaar Card (recommended)",
        "Passport size photographs",
        "Form 49A"
      ],
      processSteps: [
        "Visit NSDL or UTIITSL website.",
        "Fill Form 49A online.",
        "Upload required documents (or link via Aadhaar e-KYC).",
        "Pay the processing fee.",
        "Track application using acknowledgment number."
      ],
      estimatedTime: "7-15 days for physical copy. e-PAN in hours.",
      importantNotes: "Linking PAN with Aadhaar is mandatory.",
      commonMistakes: "Using initials in name instead of full expanded name.",
      faq: [
        {"Q": "How to apply for a minor?", "A": "A parent or guardian can apply on their behalf."}
      ]
    ),
    // Additional generic guides
    DocumentGuide(
      title: "Passport",
      iconPath: "passport",
      purpose: "International travel and strong identity proof.",
      eligibility: "Indian citizens.",
      requiredDocuments: ["Proof of Address", "Proof of DOB (Birth Certificate or 10th marksheet)"],
      processSteps: ["Register on Passport Seva portal", "Fill application", "Pay and schedule appointment", "Visit PSK", "Police Verification"],
      estimatedTime: "30-45 days",
      importantNotes: "Ensure address matches exactly with proofs.",
      commonMistakes: "Not carrying original documents to the PSK.",
      faq: []
    ),
    DocumentGuide(
      title: "Voter ID",
      iconPath: "voter",
      purpose: "Voting in elections and identity proof.",
      eligibility: "Indian citizen above 18 years.",
      requiredDocuments: ["Address Proof", "Age Proof", "Photograph"],
      processSteps: ["Visit NVSP portal or use Voter Helpline App", "Fill Form 6", "Submit and track status"],
      estimatedTime: "1-2 months",
      importantNotes: "Check draft roll periodically.",
      commonMistakes: "Applying twice without canceling previous one.",
      faq: []
    )
  ];
}
