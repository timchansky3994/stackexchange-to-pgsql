WITH QuestionsWithTags AS (
    SELECT
        p.Id AS QuestionId,
        p.CreationDate AS QuestionDate,
        (SELECT array_agg(DISTINCT tag)
         FROM unnest(string_to_array(p.Tags, '|')) AS tag
         WHERE tag <> '' AND tag <> 'postgresql') AS OtherTags
    FROM
        stackexchange.Posts p
    WHERE
        p.PostTypeId = 1
        AND p.Tags LIKE '%|postgresql|%'
),
TagPairs AS (
    SELECT
        'postgresql' AS Tag1,
        tag AS Tag2,
        QuestionId,
        QuestionDate
    FROM
        QuestionsWithTags,
        unnest(OtherTags) AS tag
    WHERE
        tag IS NOT NULL
),
PairCounts AS (
    SELECT
        Tag1,
        Tag2,
        COUNT(*) AS PairFrequency
    FROM
        TagPairs
    GROUP BY
        Tag1, Tag2
    ORDER BY
        PairFrequency DESC
    LIMIT 10
),
QuestionAnswers AS (
    SELECT
        pc.Tag1,
        pc.Tag2,
        pc.PairFrequency,
        tp.QuestionId,
        q.CreationDate AS QuestionDate,
        a.Id AS AnswerId,
        a.CreationDate AS AnswerDate,
        a.OwnerUserId AS AnswererUserId,
        u.Reputation AS AnswererReputation
    FROM
        PairCounts pc
    JOIN TagPairs tp ON pc.Tag1 = tp.Tag1 AND pc.Tag2 = tp.Tag2
    JOIN stackexchange.Posts q ON tp.QuestionId = q.Id
    JOIN stackexchange.Posts a ON q.Id = a.ParentId AND a.PostTypeId = 2
    LEFT JOIN stackexchange.Users u ON a.OwnerUserId = u.Id
)
SELECT
    qa.Tag1,
    qa.Tag2,
    qa.PairFrequency,
    AVG(EXTRACT(EPOCH FROM (qa.AnswerDate - qa.QuestionDate))) AS AvgResponseTimeSeconds,
    AVG(qa.AnswererReputation) AS AvgAnswererReputation,
    COUNT(DISTINCT qa.QuestionId) AS QuestionsCount,
    COUNT(qa.AnswerId) AS AnswersCount
FROM
    QuestionAnswers qa
GROUP BY
    qa.Tag1, qa.Tag2, qa.PairFrequency
ORDER BY
    qa.PairFrequency DESC;