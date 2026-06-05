# docs-to-mailjet

Dart CLI script that automates a newsletter workflow: reads a Google Doc, parses its content and styles, and creates a ready-to-send campaign draft in MailJet.

## How it works

1. Fetches the Google Doc via the Google Docs API (authenticated via Service Account)
2. Splits the document into named sections using **H1 headings** as separators
3. Converts each section to HTML, preserving inline styles (bold, italic, underline, font sizes, colors, background colors, text alignment, bullet lists, links, tables)
4. Re-uploads inline images from Google (whose URLs are temporary) to MailJet Assets via the Content API, replacing them with permanent public URLs
5. Injects each section into `assets/template.html` via `{{section_name}}` placeholders
6. Creates a campaign draft in MailJet via the REST API (`/v3/REST/campaigndraft`)

## Google Doc conventions

- **H1 headings** act as section separators — they are not rendered in the output but determine which `{{variable}}` in the template receives the content below
- Each H1 must match a known rubrique name (see `utils/rubriques.dart`). If there is no match, content falls into the previous section
- **GIFs**: paste the URL as plain text in the doc — the script detects URLs ending in `.gif` and converts them to `<img>` tags automatically
- **Inline images**: automatically downloaded and re-uploaded to MailJet Assets; the Google URL is replaced with the permanent MailJet URL
- **Full-width images**: an image alone on its paragraph line gets `margin: 0 -32px` to break out of the container padding

## Project structure

```
lib/
├── main.dart
├── constants/
│   └── constants.dart
├── models/
│   └── google_client_account.dart
├── services/
│   ├── export_html.dart
│   ├── google_doc_service.dart
│   ├── mailjet_image_service.dart
│   └── mailjet_service.dart
└── utils/
    ├── build_html.dart
    ├── parse_doc.dart
    └── rubriques.dart
assets/
├── template.html
├── images/
└── <google-service-account>.json
.env
```

## Setup

### 1. Google Service Account

- Create a Service Account in [Google Cloud Console](https://console.cloud.google.com) with the **Google Docs API** enabled
- Download the JSON credentials file and place it at the root (e.g. `assets/my-project-credentials.json`)
- Share the Google Doc with the service account email (viewer access is enough)

### 2. Environment variables

Create a `.env` file at the root:

```env
# Google
google_credentials=my-project-credentials.json
googleDocumentId=your_google_doc_id

# MailJet
mailjet_api_key=your_api_key
mailjet_secret_key=your_api_secret
sender_email=your_sender@email.com
sender_name=Your Sender Name
newsletter_name=Your Newsletter Name
contact_id_list=your_contact_list_id
```

### 3. HTML template

Edit `assets/template.html` to match your newsletter's graphic charter. Use `{{section_name}}` placeholders where each section's HTML should be injected. Section names must match the keys defined in `utils/rubriques.dart`.

### 4. Rubriques

Edit `utils/rubriques.dart` to map your H1 heading texts to template variable names:

```dart
final rubriques = {
  'MY SECTION': 'my_section',
  // ...
};
```

### 5. Install & run

```bash
dart pub get
dart run main.dart
```

## Dependencies

- [`googleapis`](https://pub.dev/packages/googleapis) — Google Docs API client
- [`googleapis_auth`](https://pub.dev/packages/googleapis_auth) — Service Account authentication
- [`http`](https://pub.dev/packages/http) — HTTP client for MailJet API calls
- [`http_parser`](https://pub.dev/packages/http_parser) — Multipart content-type parsing
- [`dotenv`](https://pub.dev/packages/dotenv) — `.env` file loading