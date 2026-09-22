import 'package:studyu_core/core.dart';

import '../mockup/mockup_loader.dart';
import '../mockup/mockup_studies.dart';
import 'robots/robots.dart';
import 'study_validator.dart';

abstract class StudyIntegrationActions() {
  Future<void> fillTitle();
  Future<void> fillInfoPage();
  Future<void> fillInterventions(
    List<Intervention> Function(List<Intervention> interventionList)
    interventionsToCreate,
  );
  Future<void> fillObservations(
    List<Observation> Function(List<Observation> observationList)
    observationsToCreate,
  );
}

class StudyIntegrationController(super.$, final Study Function() _mockStudyRef)
    extends StudyRobots
    implements StudyIntegrationActions {
  // Only available after login
  late final String userID;
  late final MockupLoader mockupLoader;
  late final Study _intermediateMockStudy;
  late final Study mockStudy;

  Future<void> init(String userID_) async {
    userID = userID_;
    mockupLoader = MockupLoader(userID, _mockStudyRef);
    _intermediateMockStudy = mockupLoader.emptyMockupStudy();
    mockStudy = MockupStudies.study;
  }

  @override
  Future<void> fillTitle() async {
    await studyInfoRobot.enterStudyName(mockStudy.title!);

    _intermediateMockStudy.title = mockStudy.title;
    // await _endActions(); // does not work
    await studyDesignRobot.validateChangesSaved();
  }

  @override
  Future<void> fillInfoPage() async {
    await studyInfoRobot.enterStudyDescription(mockStudy.description!);
    await studyInfoRobot.enterResponsibleOrg(mockStudy.contact.organization);
    await studyInfoRobot.enterInstitutionalReviewBoard(
      mockStudy.contact.institutionalReviewBoard!,
    );
    await studyInfoRobot.enterIRBProtocolNumber(
      mockStudy.contact.institutionalReviewBoardNumber!,
    );
    await studyInfoRobot.enterResponsiblePerson(mockStudy.contact.researchers!);
    await studyInfoRobot.enterWebsite(mockStudy.contact.website);
    await studyInfoRobot.enterContactEmail(mockStudy.contact.email);
    await studyInfoRobot.enterContactPhone(mockStudy.contact.phone);

    _intermediateMockStudy.contact = mockStudy.contact;
    await _endActions();
  }

  @override
  Future<void> fillInterventions(
    List<Intervention> Function(List<Intervention> interventionList)
    interventionsToCreate,
  ) async {
    final interventions = interventionsToCreate(mockStudy.interventions);

    for (final intervention in interventions) {
      await studyInterventionsRobot.createIntervention(
        interventionName: intervention.name!,
        interventionDescription: intervention.description!,
        taskName: intervention.tasks[0].title!,
        taskDescription: intervention.tasks[0].header!,
      );
    }

    _intermediateMockStudy.interventions.addAll(interventions);
    await _endActions();
  }

  @override
  Future<void> fillObservations(
    List<Observation> Function(List<Observation> observationList)
    observationsToCreate,
  ) async {
    final observations = observationsToCreate(mockStudy.observations);

    for (final observation in observations) {
      await studyMeasurementsRobot.createObservation(
        observationTitle: observation.title!,
        observationHeader: observation.header!,
        observationFooter: observation.footer!,
      );
      // todo support other question types
      for (final (question as ChoiceQuestion)
          in (observation as QuestionnaireTask).questions.questions) {
        await studyMeasurementsRobot.createObservationQuestion(
          questionText: question.prompt!,
          option1: question.choices[0].text,
          option2: question.choices[1].text,
        );
      }
    }
    await studyMeasurementsRobot.tapSaveSurveyQuestionButton();
    await studyMeasurementsRobot.tapSaveSurveyButton();

    _intermediateMockStudy.observations.addAll(observations);
    await _endActions();
  }

  Future<void> _endActions() async {
    await studyDesignRobot.validateChangesSaved();
    // todo find a way to validate the changes directly after auto-save
    // await validateIntermediate();
  }

  Future<bool> validateIntermediate() {
    return StudyValidator(userID).compare(_intermediateMockStudy);
  }

  Future<bool> validateFinal() async {
    final res = await StudyValidator(userID).compare(mockStudy);
    if (res) {
      print('Final validation succeeded!');
    }
    return res;
  }
}
