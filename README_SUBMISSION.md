DigiVir — LSA Profile Verification

Submission Checklist
- [ ] Presentation (Google Slides / PDF, max 15 slides) with embedded demo video (2–3 minutes) on Slide 2 or 3
- [ ] Public code repository link (GitHub/GitLab) with this project
- [ ] README with run instructions and demo logs

How to run the headless demo (produces console logs):

```bash
flutter pub get
dart run tool/demo_runner.dart
```

Notes:
- `tool/demo_runner.dart` runs three cases: valid submission, missing lineage (demo-only override), and missing-fields fail-closed.
- The app UI also integrates friction logging (5s stall) — to see live UI behavior run `flutter run`.
- To record the demo: run the app on a device/emulator and use Loom or system screen recorder. Embed the shareable link in Slide 2.

Tips for publishing:
- Create a public GitHub repo, push this code, and set the repo README to include this `README_SUBMISSION.md` content.
- Ensure `pubspec.yaml` dependencies are present (`uuid`, `crypto`, `http`).

Contact:
- Add your name, email, and phone on the title slide of your presentation.
