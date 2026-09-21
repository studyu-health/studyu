import 'package:studyu_core/core.dart';

class MockupStudies() {
  static late Study study;

  static void init(String userID) {
    study = Study.withId(userID);
  }

  static Study study1() {
    final mockContact = Contact()
      ..organization = 'Test Organization, Inc.'
      ..institutionalReviewBoard = 'IRB of Test Organization, Inc.'
      ..institutionalReviewBoardNumber = '456-112-324'
      ..researchers = 'Test First Name, Test Last Name'
      ..email = 'test@email.com'
      ..website = 'test-study.org'
      ..phone = '+491112221122';

    final mockInterventions = List<Intervention>.of([
      Intervention.withId()
        ..name = 'Test Intervention A'
        ..description = 'Test Intervention Description A'
        ..tasks = [
          CheckmarkTask.withId()
            ..title = 'Task A1'
            ..header = 'Task A1 Description',
        ],
      Intervention.withId()
        ..name = 'Test Intervention B'
        ..description = 'Test Intervention Description B'
        ..tasks = [
          CheckmarkTask.withId()
            ..title = 'Task B1'
            ..header = 'Task B1 Description',
        ],
    ]);

    final mockQuestionnaireB = StudyUQuestionnaire()
      ..questions = [
        ChoiceQuestion.withId()
          ..prompt = 'Test Question B'
          ..rationale = ''
          ..choices = [
            Choice.withId()..text = 'Test Option B1',
            Choice.withId()..text = 'Test Option B2',
          ],
      ];

    final mockObserations = List<Observation>.of([
      QuestionnaireTask.withId()
        ..questions = mockQuestionnaireB
        ..title = 'Test Survey'
        ..header = 'Test Intro'
        ..footer = 'Test Outro',
    ]);

    study
      ..title = 'Publish Test Study'
      ..description = 'Test study description'
      // ..participation = Participation.invite
      // ..resultSharing
      ..contact = mockContact
      //..iconName
      ..status = StudyStatus.running
      ..registryPublished = true
      //..questionnaire = mockQuestionnaireA
      //..eligibilityCriteria
      //..consent
      ..interventions = mockInterventions
      ..observations = mockObserations;
    //...schedule
    //..reportSpecification
    //..results
    //..collaboratorEmails
    //..registryPublished

    return study;
  }
}
