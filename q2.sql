SELECT
    p_answer.Id AS AnswerId,
    p_answer.Score,
    p_answer.Body,
    u.DisplayName AS AnswerAuthor,
    p_question.Id AS QuestionId,
    p_question.Title AS QuestionTitle,
    p_question.Tags AS QuestionTags
FROM
    stackexchange.posts p_answer
INNER JOIN
    stackexchange.posts p_question
    ON p_answer.Id = p_question.AcceptedAnswerId
INNER JOIN
    stackexchange.users u
    ON p_answer.OwnerUserId = u.Id
WHERE
    p_answer.PostTypeId = 2
    AND p_question.Tags LIKE '%|postgresql|%'
ORDER BY
    p_answer.Score ASC;