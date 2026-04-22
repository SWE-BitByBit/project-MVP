import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_audio_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_image_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';

void main() {
  group("NoteElement, NoteTextElement, NoteAudioElement, NoteImageElement", () {
    test("I getter funzionano correttamente", () {
      final NoteElement sampleText = NoteTextElement("sampleText");
      final NoteElement sampleImage = NoteImageElement("/image.png");
      final NoteElement sampleAudio = NoteAudioElement("/mixtape.wav");

      expect(sampleText.getContent(), "sampleText");
      expect(sampleText.getType(), "text");
      expect(sampleImage.getContent(), "/image.png");
      expect(sampleImage.getType(), "image");
      expect(sampleAudio.getContent(), "/mixtape.wav");
      expect(sampleAudio.getType(), "audio");
    });

    test("Setter funzionano correttamente", () {
      NoteElement sampleText = NoteTextElement("sampleText");
      NoteElement sampleImage = NoteImageElement("/image.png");
      NoteElement sampleAudio = NoteAudioElement("/mixtape.wav");
      sampleText.setContent("content");
      sampleImage.setContent("/otherPath");
      sampleAudio.setContent("/Moonsong.mp3");
      expect(sampleText.getContent(), "content");
      expect(sampleImage.getContent(), "/otherPath");
      expect(sampleAudio.getContent(), "/Moonsong.mp3");
    });
  });
}
