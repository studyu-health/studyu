import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

MedicationProductSnapshot buildSnapshot() => const MedicationProductSnapshot(
  pzn: '03752864',
  officialName: 'Ibuprofen Test 400 mg Filmtabletten',
  activeIngredientCount: 1,
  dosageForm: MedicationDosageForm(
    patientFriendlyShort: 'Tablet',
    bfarmName: 'Tablette',
    bfarmTermId: 'T1',
  ),
  components: [
    MedicationComponent(
      key: 'rpp-1',
      number: 1,
      dosageForm: MedicationDosageForm(
        patientFriendlyShort: 'Tablet',
        bfarmName: 'Tablette',
        bfarmTermId: 'T1',
      ),
      activeIngredients: [
        MedicationActiveIngredient(
          key: 'rse-1',
          name: 'Ibuprofen',
          strength: '400 mg',
          rank: 1,
        ),
      ],
    ),
    MedicationComponent(
      key: 'rpp-2',
      number: 2,
      dosageForm: MedicationDosageForm(
        patientFriendlyShort: 'Coated tablet',
        patientFriendlyLong: 'Long form',
        bfarmName: 'Überzug',
        bfarmTermId: 'T2',
      ),
      description: 'Second component',
      activeIngredients: [
        MedicationActiveIngredient(
          key: 'rse-2',
          name: 'Other ingredient',
          rank: 1,
        ),
      ],
    ),
  ],
  source: MedicationSource(
    name: 'BfArM Referenzdatenbank gemäß § 31b SGB V',
    releaseDate: '2026-09-15',
  ),
);

void main() {
  test('MedicationQuestion round-trips inherited fields', () {
    final question = MedicationQuestion.withId()
      ..prompt = 'Which medication did you take?'
      ..rationale = 'Record the selected product.';

    final restored = MedicationQuestion.fromJson(question.toJson());

    expect(restored.type, MedicationQuestion.questionType);
    expect(restored.id, question.id);
    expect(restored.prompt, question.prompt);
    expect(restored.rationale, question.rationale);
    final parsed = Question.fromJson(question.toJson());
    expect(parsed, isA<MedicationQuestion>());
    expect(parsed.id, question.id);
  });

  test('MedicationAnswer round-trips the complete snapshot and quantity', () {
    final answer = MedicationAnswer(medication: buildSnapshot(), quantity: 0.5);

    final restored = MedicationAnswer.fromJson(answer.toJson());

    expect(restored.toJson(), answer.toJson());
    expect(restored.medication.pzn, '03752864');
    expect(restored.medication.components, hasLength(2));
    expect(
      restored.medication.components[0].activeIngredients[0].strength,
      '400 mg',
    );
    expect(
      restored.medication.components[1].activeIngredients[0].strength,
      isNull,
    );
    expect(restored.quantity, 0.5);
    expect(restored.medication.source.releaseDate, '2026-09-15');
  });

  test(
    'Answer uses MedicationAnswer discriminator and restores nested value',
    () {
      final question = MedicationQuestion.withId();
      final answer = question.constructAnswer(
        MedicationAnswer(medication: buildSnapshot(), quantity: 0.5),
      );

      final json = answer.toJson();
      expect(json[Answer.keyResponseType], 'MedicationAnswer');
      expect(json[Answer.keyResponse], isA<Map<String, dynamic>>());

      final restored = Answer.fromJson(json) as Answer<MedicationAnswer>;
      expect(restored.question, answer.question);
      expect(restored.timestamp, answer.timestamp);
      expect(restored.response.toJson(), answer.response.toJson());
      expect(restored.response.quantity, 0.5);
    },
  );

  test('legacy primitive and DateTime answers remain compatible', () {
    final timestamp = DateTime.utc(2026, 9, 15, 12, 30);
    final answers = <Answer<dynamic>>[
      Answer<bool>('bool', timestamp)..response = true,
      Answer<String>('string', timestamp)..response = 'value',
      Answer<num>('number', timestamp)..response = 3.5,
      Answer<List<String>>('list', timestamp)..response = ['a', 'b'],
      Answer<DateTime>('date', timestamp)..response = timestamp,
    ];

    for (final answer in answers) {
      final restored = Answer.fromJson(answer.toJson());
      expect(restored.question, answer.question);
      expect(restored.timestamp, timestamp);
      expect(
        restored.toJson()[Answer.keyResponse],
        answer.toJson()[Answer.keyResponse],
      );
    }

    final legacyDate = {
      'question': 'legacy-date',
      'timestamp': timestamp.toIso8601String(),
      'response': timestamp.toIso8601String(),
    };
    final restoredLegacy = Answer.fromJson(legacyDate);
    expect(restoredLegacy.response, timestamp);
  });
}
