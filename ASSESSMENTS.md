# Reusable Question Banks

`assessments/index.yaml` lists banks in teaching order. Each bank uses schema
version 1 and the contract in `schemas/question-bank.schema.json`. This is an
authoring format for future application integration, not an existing Astrona
quiz API. No YAML question file is registered as a Markdown reading.

Each section has a quiz.yaml listed in astrona.yaml as a type: quiz entry after the capstone lab (pass_score 70), and sections/final-domain-quiz.yaml closes the course. Banks contain original single-choice questions scoped to concepts taught in the course. They remain draft for review.

## Fields And Rendering

- `id`: stable bank or question identity; preserve it when editing wording.
- `scope`: section or domain checkpoint.
- `placement`: relative reading path after which the checkpoint belongs.
- `learning_objective`: the measurable outcome checked by the question.
- `source_readings`: author traceability to the teaching; not learner navigation.
- `prompt`: learner-visible question text.
- `options`: stable option IDs, answer text and per-option feedback.
- `correct_option`: the ID of the single correct option.
- `explanation`: feedback reinforcing the supported answer.

The application should send only the question ID, prompt and option IDs/text to
the learner before submission. Keep `correct_option`, `explanation` and option
explanations on the server until feedback is permitted. Match answers by option
ID, not display position, so a later renderer can shuffle choices safely.

The banks contain answer keys and are public learning material, so this is not
a secure examination bank. Do not treat scores as an official CCA result.

## Hands-On Coverage

This course has 3 ungraded playgrounds and 4 independent draft labs. Tasks, launch entries and solutions follow their teaching reading. Guided practice precedes the summary. Static and offline checks are separate from live execution, which remains pending.

| Module | Labs in reading order |
| --- | --- |
| 010/01 | Find The Flow Observation Components |
| 020/01 | Create L7 Visibility With An HTTP Policy |
| 020/01 | Record A Real HTTP Flow From Hubble Relay |
| 030/01 | Discover The Relay Service For Hubble CLI |
